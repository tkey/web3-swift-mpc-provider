import BigInt
import Foundation
import secp256k1
import tss_client_swift
import web3

public enum CustomSigningError: Error {
    case generalError(error: String = "")

    public var errorDescription: String {
        switch self {
        case let .generalError(err):
            return err
        }
    }
}

enum EthereumSignerError: Error {
    case emptyRawTransaction
    case unknownError
}

public final class EthereumTssAccount: EthereumAccountProtocol {
    public var address: web3.EthereumAddress
    public var ethAccountParams: EthTssAccountParams

    public required init(params: EthTssAccountParams) throws {
        ethAccountParams = params
        address = EthereumAddress(KeyUtil.generateAddress(from: Data(hex: ethAccountParams.publicKey).suffix(64)).toChecksumAddress())
    }

    /// hash and sign data
    public func sign(data: Data) throws -> Data {
        let hash = data.sha3(.keccak256)
        let signature = try sign(message: hash)
        return signature
    }

    /// hash and sign hex string
    public func sign(hex: String) throws -> Data {
        if let data = Data(hex: hex) {
            return try sign(data: data)
        } else {
            throw EthereumAccountError.signError
        }
    }

    /// Signing hashed string
    public func sign(hash: String) throws -> Data {
        if let data = hash.web3.hexData {
            return try sign(message: data)
        } else {
            throw EthereumAccountError.signError
        }
    }

    /// Signing Data without hashing
    public func sign(message: Data) throws -> Data {
        // Create tss Client using helper
        let (client, coeffs) = try bootstrapTssClient(params: ethAccountParams)

        // Wait for sockets to be connected
        let connected = try client.checkConnected()
        if !connected {
            throw EthereumSignerError.unknownError
        }

        let precompute = try client.precompute(serverCoeffs: coeffs, signatures: ethAccountParams.authSigs)

        let ready = try client.isReady()
        if !ready {
            throw EthereumSignerError.unknownError
        }

        let signingMessage = message.base64EncodedString()

        let (s, r, v) = try client.sign(message: signingMessage, hashOnly: true, original_message: nil, precompute: precompute, signatures: ethAccountParams.authSigs)

        try client.cleanup(signatures: ethAccountParams.authSigs)

        let verified = TSSHelpers.verifySignature(msgHash: signingMessage, s: s, r: r, v: v, pubKey: Data(hex: ethAccountParams.publicKey))
        if !verified {
            throw EthereumSignerError.unknownError
        }
        guard let signature = Data(hexString: try TSSHelpers.hexSignature(s: s, r: r, v: v)) else { throw EthereumSignerError.unknownError }

        return signature
    }

    /// Signing utf8 encoded message String
    public func sign(message: String) throws -> Data {
        if let data = message.data(using: .utf8) {
            return try sign(data: data)
        } else {
            throw EthereumAccountError.signError
        }
    }

    /// prefix message and hash it before signing
    public func signMessage(message: Data) throws -> String {
        let prefix = "\u{19}Ethereum Signed Message:\n\(String(message.count))"
        guard var data = prefix.data(using: .ascii) else {
            throw EthereumAccountError.signError
        }
        data.append(message)
        let hash = data.web3.keccak256

        var signed = try sign(message: hash)

        // Check last char (v)
        guard var last = signed.popLast() else {
            throw EthereumAccountError.signError
        }

        if last < 27 {
            last += 27
        }

        signed.append(last)
        return signed.web3.hexString
    }

    /// signing TypedData
    public func signMessage(message: TypedData) throws -> String {
        let hash = try message.signableHash()

        var signed = try sign(message: hash)
        
        // Check last char (v)
        guard var last = signed.popLast() else {
            throw EthereumAccountError.signError
        }

        if last < 27 {
            last += 27
        }

        signed.append(last)
        return signed.web3.hexString
    }

    /// Signing EthereumTransaction
    public func sign(transaction: EthereumTransaction) throws -> SignedTransaction {
        guard let raw = transaction.raw else {
            throw EthereumSignerError.emptyRawTransaction
        }

        // hash and sign data
        let signed = try sign(data: raw)

        return SignedTransaction(transaction: transaction, signature: signed)
    }

    private func bootstrapTssClient(params: EthTssAccountParams) throws -> (TSSClient, [String: String]) {
        if params.publicKey.count < 128 || params.publicKey.count > 130 {
            throw CustomSigningError.generalError(error: "Public Key should be in uncompressed format")
        }

        // generate a random nonce for sessionID
        guard let randomKey = SECP256K1.generatePrivateKey() else {
            throw CustomSigningError.generalError(error: "Could not generate random key for sessionID nonce")
        }
        let randomKeyBigUint = BigUInt(randomKey)
        let random = BigInt(sign: .plus, magnitude: randomKeyBigUint) + BigInt(Date().timeIntervalSince1970)
        let sessionNonce = TSSHelpers.base64ToBase64url(base64: TSSHelpers.hashMessage(message: String(random)))
        // create the full session string
        let session = TSSHelpers.assembleFullSession(verifier: params.verifier, verifierId: params.verifierID, tssTag: params.selectedTag, tssNonce: String(params.tssNonce), sessionNonce: sessionNonce)

        let userTssIndex = BigInt(params.tssIndex, radix: 16) ?? BigInt.zero
        // total parties, including the client
        let parties = params.nodeIndexes.count > 0 ? params.nodeIndexes.count + 1 : 4

        // index of the client, last index of partiesIndexes
        let clientIndex = Int32(parties - 1)

        let (urls, socketUrls, partyIndexes, nodeInd) = try TSSHelpers.generateEndpoints(parties: parties, clientIndex: Int(clientIndex), nodeIndexes: params.nodeIndexes, urls: params.tssEndpoints)

        let coeffs = try TSSHelpers.getServerCoefficients(participatingServerDKGIndexes: nodeInd.map({ BigInt($0) }), userTssIndex: userTssIndex)

        let shareUnsigned = BigUInt(params.tssShare, radix: 16) ?? BigUInt.zero
        let share = BigInt(sign: .plus, magnitude: shareUnsigned)
        let denormalizeShare = try TSSHelpers.denormalizeShare(participatingServerDKGIndexes: nodeInd.map({ BigInt($0) }), userTssIndex: userTssIndex, userTssShare: share)

        let client = try TSSClient(session: session, index: Int32(clientIndex), parties: partyIndexes.map({ Int32($0) }),
                                   endpoints: urls.map({ URL(string: $0 ?? "") }), tssSocketEndpoints: socketUrls.map({ URL(string: $0 ?? "") }),
                                   share: TSSHelpers.base64Share(share: denormalizeShare), pubKey: try TSSHelpers.base64PublicKey(pubKey: Data(hex: params.publicKey)))

        return (client, coeffs)
    }
}
