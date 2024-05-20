//
//  File.swift
//  
//
//  Created by CW Lee on 20/05/2024.
//

import Foundation

import Foundation
import mpc_core_kit_swift
import MPCEthereumProvider

//public protocol IBticoinSigner {
//    func sign( message: Data ) -> Data
////    func schnorrSign(message: Data, publicKey: Data) -> Data
//    var publicKey : Data { get }
//}
//
//
//extension MpcCoreKit : IBticoinSigner {
//    public func sign(message: Data) -> Data {
//        let data =  try? self.tssSign(message: message)
//        return data ?? Data([])
//    }
//    
//    
//    // MPC do not support shnorrSign yet
//    // return empty data to fullfill signer interface requirement
////    public func schnorrSign(message: Data, publicKey: Data) -> Data {
////        return Data()
////    }
//    
//    public var publicKey: Data {
//        return self.getTssPubKey()
//    }
//    
//}


// EVM signer
//public protocol ISigner {
//    func sign( message: Data ) -> Data
//    var publicKey : Data { get }
//}


extension MpcCoreKit : EvmSigner {
    public func sign(message: Data) throws -> Data {
        let data =  try self.tssSign(message: message)
        return data
    }
    
    public var publicKey: Data {
        return self.getTssPubKey().suffix(64)
    }
    
}

