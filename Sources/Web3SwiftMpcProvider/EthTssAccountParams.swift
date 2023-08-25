public class EthTssAccountParams {
    public let evmAddress: String
    public let publicKey: String
    public let factorKey: String
    public let tssNonce: Int32
    public let tssShare: String
    public let tssIndex: String
    public let selectedTag: String
    public let verifier: String
    
    ///verifierID for
    public let verifierID: String
    public let nodeIndexes: [Int]
    public let tssEndpoints: [String]
    public let authSigs: [String]
    
    // Initializer
    public init(evmAddress: String, publicKey: String, factorKey: String, tssNonce: Int32, tssShare: String, tssIndex: String, selectedTag: String, verifier: String, verifierID: String, nodeIndexes: [Int], tssEndpoints: [String], authSigs: [String]) {
        self.evmAddress = evmAddress
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
