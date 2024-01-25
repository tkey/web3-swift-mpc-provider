import BigInt
import Foundation
import curveSecp256k1
import tss_client_swift

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

public final class TssAccount {
//    public var address: web3.EthereumAddress
    public var ethAccountParams: EthTssAccountParams

    /// Instantiates an EtheriumTssAccount
    ///
    /// - Parameters:
    ///   - params : Parameters used to initialize the account
    ///
    public required init(params: EthTssAccountParams) {
        ethAccountParams = params
        // swiftlint:disable:next line_length
//        address = EthereumAddress(KeyUtil.generateAddress(from: Data(hex: ethAccountParams.publicKey).suffix(64)).toChecksumAddress())
    }

    /// Signs using provided message data
    ///
    /// - Parameters:
    ///   - message : message to be used for signing
    ///
    /// - Returns: `Data`
    ///
    /// - Throws: On signing failure
    public func tssSign(message: Data) throws -> Data {
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

        // swiftlint:disable:next line_length
        let verified = TSSHelpers.verifySignature(msgHash: signingMessage, s: s, r: r, v: v, pubKey: Data(hex: ethAccountParams.publicKey))
        if !verified {
            throw EthereumSignerError.unknownError
        }

        // swiftlint:disable:next line_length
        guard let signature = Data(hexString: try TSSHelpers.hexSignature(s: s, r: r, v: v)) else { throw EthereumSignerError.unknownError }

        return signature
    }

    private func bootstrapTssClient(params: EthTssAccountParams) throws -> (TSSClient, [String: String]) {
        if params.publicKey.count < 128 || params.publicKey.count > 130 {
            throw CustomSigningError.generalError(error: "Public Key should be in uncompressed format")
        }

        // generate a random nonce for sessionID
        let randomKey = try SecretKey().serialize()
        guard let randomKeyBigUint = BigUInt(randomKey, radix: 16 ) else {
            throw CustomSigningError.generalError(error: "Could not generate random key for sessionID nonce")
        }
        let random = BigInt(sign: .plus, magnitude: randomKeyBigUint) + BigInt(Date().timeIntervalSince1970)
        let sessionNonce = TSSHelpers.base64ToBase64url(base64: TSSHelpers.hashMessage(message: String(random)))
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
        let client = try TSSClient(session: session, index: Int32(clientIndex), parties: partyIndexes.map({ Int32($0) }),
                                   // swiftlint:disable:next line_length
                                   endpoints: urls.map({ URL(string: $0 ?? "") }), tssSocketEndpoints: socketUrls.map({ URL(string: $0 ?? "") }),
                                   // swiftlint:disable:next line_length
                                   share: TSSHelpers.base64Share(share: denormalizeShare), pubKey: try TSSHelpers.base64PublicKey(pubKey: Data(hex: params.publicKey)))

        return (client, coeffs)
    }
}
