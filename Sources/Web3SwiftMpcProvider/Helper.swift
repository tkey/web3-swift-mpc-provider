import BigInt
import Foundation
import SwiftUI
import tss_client_swift
import web3
import secp256k1

public func bootstrapTssClient (params: EthTssAccountParams) throws -> (TSSClient, [String: String]) {
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

    let client = try TSSClient(session: session, index: Int32(clientIndex), parties: partyIndexes.map({Int32($0)}),
                               endpoints: urls.map({ URL(string: $0 ?? "") }), tssSocketEndpoints: socketUrls.map({ URL(string: $0 ?? "") }),
                               share: TSSHelpers.base64Share(share: denormalizeShare), pubKey: try TSSHelpers.base64PublicKey(pubKey: Data(hex: params.publicKey)))

    return (client, coeffs)
 }
