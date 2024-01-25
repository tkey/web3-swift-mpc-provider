import Foundation

public final class EthTssAccountParams {
    public private(set) var publicKey: String
    private(set) var factorKey: String
    private(set) var tssNonce: Int32
    private(set) var tssShare: String
    private(set) var tssIndex: String
    private(set) var selectedTag: String
    private(set) var verifier: String
    private(set) var verifierID: String
    private(set) var nodeIndexes: [Int]
    private(set) var tssEndpoints: [String]
    private(set) var authSigs: [String]
    /// Instantiates EthTssAccountParams which are used to instantiate an EtheriumTssAccount
    ///
    /// - Parameters:
    ///   - publicKey : Public key for the account, EtheriumAddress is derived from this.
    ///   - factorKey: The factor key
    ///   - tssNonce: The current tss nonce
    ///   - tssShare: The current tss share
    ///   - tssIndex: The index corresponding to the tssShare
    ///   - selectedTag: The current tss tag
    ///   - verifier: The verifier for the account
    ///   - verifierID: The identifier for the account
    ///   - nodeIndexes: The node indexes returned form the sapphire network
    ///   - tssEndpoints: The tss endpoints for the sapphire network
    ///   - authSigs: The signatures returned for the sapphire network
    ///
    // swiftlint:disable:next line_length
    public init(publicKey: String, factorKey: String, tssNonce: Int32, tssShare: String, tssIndex: String, selectedTag: String, verifier: String, verifierID: String, nodeIndexes: [Int], tssEndpoints: [String], authSigs: [String]) {
        self.publicKey = publicKey
        self.factorKey = factorKey
        self.tssNonce = tssNonce
        self.tssShare = tssShare
        self.tssIndex = tssIndex
        self.selectedTag = selectedTag
        self.verifier = verifier
        self.verifierID = verifierID
        self.nodeIndexes = nodeIndexes
        self.tssEndpoints = tssEndpoints
        self.authSigs = authSigs
    }
}
