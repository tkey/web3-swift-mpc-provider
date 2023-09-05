public final class EthTssAccountParams {
    private(set) var publicKey: String
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
