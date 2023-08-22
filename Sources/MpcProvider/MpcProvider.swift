import Foundation
import web3
import secp256k1
import CryptoKit
import BigInt


public struct MpcProvider {
    public private(set) var text = "Hello, World!"

    public init() {
        
    }
    
    public func sign(transaction: EthereumTransaction) -> SignedTransaction {
        return signtx(transaction: transaction)
    }
    
}
