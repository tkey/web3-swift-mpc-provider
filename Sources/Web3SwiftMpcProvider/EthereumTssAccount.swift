import BigInt
import Foundation
import curveSecp256k1
import tss_client_swift
import web3

enum CustomSigningError: Error {
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

    /// Instantiates an EtheriumTssAccount
    ///
    /// - Parameters:
    ///   - params : Parameters used to initialize the account
    ///
    public required init(params: EthTssAccountParams) throws {
        ethAccountParams = params
        guard let publicKey = Data(hexString: ethAccountParams.publicKey) else {
            throw CustomSigningError.generalError(error: "Cannot convert public key to data")
        }
        // swiftlint:disable:next line_length
        address = EthereumAddress(KeyUtil.generateAddress(from: publicKey.suffix(64)).toChecksumAddress())
    }

    /// Signs using provided Data
    ///
    /// - Parameters:
    ///   - data : Data to be signed
    ///
    /// - Returns: `Data`
    ///
    /// - Throws: On signing failure
    public func sign(data: Data) throws -> Data {
        let hash = try keccak256(data: data)
        let signature = try sign(message: hash)
        return signature
    }

    /// Signs using provided Hex String
    ///
    /// - Parameters:
    ///   - hex : Hex string to be signed
    ///
    /// - Returns: `Data`
    ///
    /// - Throws: On signing failure
    public func sign(hex: String) throws -> Data {
        if let data = Data(hexString: hex) {
            return try sign(data: data)
        } else {
            throw EthereumAccountError.signError
        }
    }

    /// Signs using provided hash
    ///
    /// - Parameters:
    ///   - hash : Hash to be used for signing
    ///
    /// - Returns: `Data`
    ///
    /// - Throws: On signing failure
    public func sign(hash: String) throws -> Data {
        if let data = hash.web3.hexData {
            return try sign(message: data)
        } else {
            throw EthereumAccountError.signError
        }
    }

    /// Signs using provided message data
    ///
    /// - Parameters:
    ///   - message : message to be used for signing
    ///
    /// - Returns: `Data`
    ///
    /// - Throws: On signing failure
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

        // swiftlint:disable:next identifier_name line_length
        let (s, r, v) = try client.sign(message: signingMessage, hashOnly: true, original_message: nil, precompute: precompute, signatures: ethAccountParams.authSigs)

        try client.cleanup(signatures: ethAccountParams.authSigs)

        guard let pk = Data(hexString: ethAccountParams.publicKey) else {
            throw CustomSigningError.generalError(error: "Unable to convert public key to data")
        }
        // swiftlint:disable:next line_length
        let verified = TSSHelpers.verifySignature(msgHash: signingMessage, s: s, r: r, v: v, pubKey: pk)
        if !verified {
            throw EthereumSignerError.unknownError
        }

        // swiftlint:disable:next line_length
        guard let signature = Data(hexString: try TSSHelpers.hexSignature(s: s, r: r, v: v)) else { throw EthereumSignerError.unknownError }

        return signature
    }

    /// Signs using provided message string
    ///
    /// - Parameters:
    ///   - message : message to be used for signing
    ///
    /// - Returns: `Data`
    ///
    /// - Throws: On signing failure
    public func sign(message: String) throws -> Data {
        if let data = message.data(using: .utf8) {
            return try sign(data: data)
        } else {
            throw EthereumAccountError.signError
        }
    }

    /// Signs using provided message data, prefixing the data first
    ///
    /// - Parameters:
    ///   - message : message to be used for signing
    ///
    /// - Returns: `String`
    ///
    /// - Throws: On signing failure
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

    /// Signs using provided structured typed message (EIP712)
    ///
    /// - Parameters:
    ///   - message : message to be used for signing
    ///
    /// - Returns: `String`
    ///
    /// - Throws: On signing failure
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

    /// Signs an ethereum transaction
    ///
    /// - Parameters:
    ///   - transaction : Transaction to be signed
    ///
    /// - Returns: `SignedTransaction`
    ///
    /// - Throws: On signing failure
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
        let randomKey = try SecretKey().serialize()
        guard let randomKeyBigUint = BigUInt(hex: randomKey) else {
            throw CustomSigningError.generalError(error: "Could not generate random key for sessionID nonce")
        }
        let random = BigInt(sign: .plus, magnitude: randomKeyBigUint) + BigInt(Date().timeIntervalSince1970)
        let sessionNonce = TSSHelpers.base64ToBase64url(base64: try TSSHelpers.hashMessage(message: String(random)))
        // create the full session string
        // swiftlint:disable:next line_length
        let session = TSSHelpers.assembleFullSession(verifier: params.verifier, verifierId: params.verifierID, tssTag: params.selectedTag, tssNonce: String(params.tssNonce), sessionNonce: sessionNonce)

        let userTssIndex = BigInt(params.tssIndex, radix: 16) ?? BigInt.zero
        // total parties, including the client
        let parties = params.nodeIndexes.count > 0 ? params.nodeIndexes.count + 1 : 4

        // index of the client, last index of partiesIndexes
        let clientIndex = Int32(parties - 1)
        // swiftlint:disable:next line_length
        let (urls, socketUrls, partyIndexes, nodeInd) = try TSSHelpers.generateEndpoints(parties: parties, clientIndex: Int(clientIndex), nodeIndexes: params.nodeIndexes, urls: params.tssEndpoints)
        // swiftlint:disable:next line_length
        let coeffs = try TSSHelpers.getServerCoefficients(participatingServerDKGIndexes: nodeInd.map({ BigInt($0) }), userTssIndex: userTssIndex)

        let shareUnsigned = BigUInt(params.tssShare, radix: 16) ?? BigUInt.zero
        let share = BigInt(sign: .plus, magnitude: shareUnsigned)
        // swiftlint:disable:next line_length
        let denormalizeShare = try TSSHelpers.denormalizeShare(participatingServerDKGIndexes: nodeInd.map({ BigInt($0) }), userTssIndex: userTssIndex, userTssShare: share)
        // swiftlint:disable:next line_length
        guard let pk = Data(hexString: params.publicKey) else {
            throw CustomSigningError.generalError(error: "Unable to convert public key to data")
        }
        let client = try TSSClient(session: session, index: Int32(clientIndex), parties: partyIndexes.map({ Int32($0) }),
                                   // swiftlint:disable:next line_length
                                   endpoints: urls.map({ URL(string: $0 ?? "") }), tssSocketEndpoints: socketUrls.map({ URL(string: $0 ?? "") }),
                                   // swiftlint:disable:next line_length
                                   share: TSSHelpers.base64Share(share: denormalizeShare), pubKey: try TSSHelpers.base64PublicKey(pubKey: pk))

        return (client, coeffs)
    }
}
