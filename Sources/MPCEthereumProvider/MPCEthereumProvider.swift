//
//  File.swift
//  
//
//  Created by CW Lee on 17/05/2024.
//

import BigInt
import Foundation
import web3

#if canImport(curveSecp256k1)
import curveSecp256k1
#endif


public protocol EvmSigner {
    func sign( message: Data ) throws -> Data
    var publicKey : Data { get }
}

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

public class MPCEthereumProvider : EthereumAccountProtocol {
    let signer: EvmSigner
    
    public init( evmSigner: EvmSigner) {
        signer = evmSigner
    }
    
    public var address: web3.EthereumAddress {
        // try async
        return EthereumAddress(KeyUtil.generateAddress(from: self.signer.publicKey ).toChecksumAddress())
    }

    
    public func sign(message: Data) throws -> Data {
        return try self.signer.sign(message: message)
    }
    
    /// Signs using provided Data
    ///
    /// - Parameters:
    ///   - data : Data to be signed
    ///
    /// - Returns: `Data`
    ///
    /// - Throws: On signing failure
    public func sign(data: Data) throws -> Data {
        let hash = try keccak256(data: data)
        let signature = try sign(message: hash)
        return signature
    }

    /// Signs using provided Hex String
    ///
    /// - Parameters:
    ///   - hex : Hex string to be signed
    ///
    /// - Returns: `Data`
    ///
    /// - Throws: On signing failure
    public func sign(hex: String) throws -> Data {
        if let data = Data(hex: hex) {
            return try sign(data: data)
        } else {
            throw EthereumAccountError.signError
        }
    }

    /// Signs using provided hash
    ///
    /// - Parameters:
    ///   - hash : Hash to be used for signing
    ///
    /// - Returns: `Data`
    ///
    /// - Throws: On signing failure
    public func sign(hash: String) throws -> Data {
        if let data = hash.web3.hexData {
            return try sign(message: data)
        } else {
            throw EthereumAccountError.signError
        }
    }

    /// Signs using provided message string
    ///
    /// - Parameters:
    ///   - message : message to be used for signing
    ///
    /// - Returns: `Data`
    ///
    /// - Throws: On signing failure
    public func sign(message: String) throws -> Data {
        if let data = message.data(using: .utf8) {
            return try sign(data: data)
        } else {
            throw EthereumAccountError.signError
        }
    }

    /// Signs using provided message data, prefixing the data first
    ///
    /// - Parameters:
    ///   - message : message to be used for signing
    ///
    /// - Returns: `String`
    ///
    /// - Throws: On signing failure
    public func signMessage(message: Data) throws -> String {
        let prefix = "\u{19}Ethereum Signed Message:\n\(String(message.count))"
        guard var data = prefix.data(using: .ascii) else {
            throw EthereumAccountError.signError
        }
        data.append(message)
        let hash = data.web3.keccak256

        var signed = try sign(message: hash)

        // Check last char (v)
        guard var last = signed.popLast() else {
            throw EthereumAccountError.signError
        }

        if last < 27 {
            last += 27
        }

        signed.append(last)
        return signed.web3.hexString
    }

    /// Signs using provided structured typed message (EIP712)
    ///
    /// - Parameters:
    ///   - message : message to be used for signing
    ///
    /// - Returns: `String`
    ///
    /// - Throws: On signing failure
    public func signMessage(message: TypedData) throws -> String {
        let hash = try message.signableHash()

        var signed = try sign(message: hash)

        // Check last char (v)
        guard var last = signed.popLast() else {
            throw EthereumAccountError.signError
        }

        if last < 27 {
            last += 27
        }

        signed.append(last)
        return signed.web3.hexString
    }

    /// Signs an ethereum transaction
    ///
    /// - Parameters:
    ///   - transaction : Transaction to be signed
    ///
    /// - Returns: `SignedTransaction`
    ///
    /// - Throws: On signing failure
    public func sign(transaction: EthereumTransaction) throws -> SignedTransaction {
        guard let raw = transaction.raw else {
            throw EthereumSignerError.emptyRawTransaction
        }

        // hash and sign data
        let signed = try sign(data: raw)

        return SignedTransaction(transaction: transaction, signature: signed)
    }

}
