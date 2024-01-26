//
//  File.swift
//  
//
//  Created by CW Lee on 25/01/2024.
//

import Foundation
import mpc_kit_swift

public protocol ISigner {
    func sign( message: Data ) -> Data
    func schnorrSign(message: Data, publicKey: Data) -> Data
    var publicKey : Data { get }
}

extension MpcSigningKit : ISigner {
    public func sign(message: Data) -> Data {
        let data =  self.tssSign(message: message)
        return data
    }
    
    public func schnorrSign(message: Data, publicKey: Data) -> Data {
        return Data()
    }
    
    public var publicKey: Data {
        return self.getTssPubKey()
    }
    
}
