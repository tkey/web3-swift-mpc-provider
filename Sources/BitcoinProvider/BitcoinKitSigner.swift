//
//  File.swift
//  
//
//  Created by CW Lee on 25/01/2024.
//

import Foundation
import Web3SwiftMpcProvider

public protocol ISigner {
    func sign( message: Data ) -> Data
    func schnorrSign(message: Data, publicKey: Data) -> Data
    var publicKey : Data { get }
}

extension TssAccount : ISigner {
    public func sign(message: Data) -> Data {
        let data =  try? self.tssSign(message: message)
        return data ?? Data()
    }
    
    public func schnorrSign(message: Data, publicKey: Data) -> Data {
        return Data()
    }
    
    public var publicKey: Data {
        return Data(hex: self.ethAccountParams.publicKey)
    }
    
}
