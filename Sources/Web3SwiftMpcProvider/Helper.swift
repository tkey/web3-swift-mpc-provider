import BigInt
import Foundation
import SwiftUI
import tss_client_swift
import web3
import secp256k1

// swiftlint:disable:next function_parameter_count
public func bootstrapTssClient (selectedTag: String, tssNonce: Int32, publicKey: String, tssShare: String,
                                tssIndex: String, nodeIndexes: [Int], factorKey: String, verifier: String, verifierId: String,
                                tssEndpoints: [String] ) throws -> (TSSClient, [String: String]) {
    if publicKey.count < 128 || publicKey.count > 130 {
        throw CustomSigningError.generalError(error: "Public Key should be in uncompressed format")
    }

    // generate a random nonce for sessionID
    let randomKey = BigUInt(SECP256K1.generatePrivateKey()!)
    let random = BigInt(sign: .plus, magnitude: randomKey) + BigInt(Date().timeIntervalSince1970)
    let sessionNonce = TSSHelpers.hashMessage(message: String(random))
    // create the full session string
    let session = TSSHelpers.assembleFullSession(verifier: verifier, verifierId: verifierId, tssTag: selectedTag, tssNonce: String(tssNonce), sessionNonce: sessionNonce)

    let userTssIndex = BigInt(tssIndex, radix: 16)!
    // total parties, including the client
    let parties = nodeIndexes.count > 0 ? nodeIndexes.count + 1 : 4

    // index of the client, last index of partiesIndexes
    let clientIndex = Int32(parties - 1)

    let (urls, socketUrls, partyIndexes, nodeInd) = try TSSHelpers.generateEndpoints(parties: parties, clientIndex: Int(clientIndex), nodeIndexes: nodeIndexes, urls: tssEndpoints)

    let coeffs = try TSSHelpers.getServerCoefficients(participatingServerDKGIndexes: nodeInd.map({ BigInt($0) }), userTssIndex: userTssIndex)

    let shareUnsigned = BigUInt(tssShare, radix: 16)!
    let share = BigInt(sign: .plus, magnitude: shareUnsigned)
    let denormalizeShare = try TSSHelpers.denormalizeShare(participatingServerDKGIndexes: nodeInd.map({ BigInt($0) }), userTssIndex: userTssIndex, userTssShare: share)

    let client = try TSSClient(session: session, index: Int32(clientIndex), parties: partyIndexes.map({Int32($0)}),
                               endpoints: urls.map({ URL(string: $0 ?? "") }), tssSocketEndpoints: socketUrls.map({ URL(string: $0 ?? "") }),
                               share: TSSHelpers.base64Share(share: denormalizeShare), pubKey: try TSSHelpers.base64PublicKey(pubKey: Data(hex: publicKey)))

    return (client, coeffs)
 }
