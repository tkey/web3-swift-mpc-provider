//
//  EthereumTssAccount.swift
//  tkey_ios
//
//  Created by himanshu on 09/08/23.
//

import Foundation
import web3
import secp256k1
import tss_client_swift
import CryptoKit
import BigInt

public enum CustomError: Error {
    case unknownError
    case methodUnavailable

    public var errorDescription: String {
        switch self {
        case .unknownError:
            return "unknownError"
        case .methodUnavailable:
            return "method unavailable/unimplemented"
        }
    }
}

enum EthereumSignerError: Error {
    case emptyRawTransaction
    case unknownError
}

public class EthereumTssAccount: EthereumAccountProtocol {
    public let selectedTag: String
    public let verifier: String
    public let factorKey: String
    public let verifierID: String
    public let publicKey: String
    public let authSigs: [String]
    public let tssNonce: Int32
    public let tssShare: String
    public let tssIndex: String
    public let nodeIndexes: [Int]
    public let tssEndpoints: [String]
    public let address: EthereumAddress

    required public init(evmAddress: String, pubkey: String, factorKey: String, tssNonce: Int32, tssShare: String,
                         tssIndex: String, selectedTag: String, verifier: String, verifierID: String, nodeIndexes: [Int],
                         tssEndpoints: [String], authSigs: [String]) throws {
            self.factorKey = factorKey
            self.selectedTag = selectedTag
            self.verifier = verifier
            self.verifierID = verifierID
            self.publicKey = pubkey
            self.nodeIndexes = nodeIndexes
            self.tssEndpoints = tssEndpoints
            self.tssNonce = tssNonce
            self.tssIndex = tssIndex
            self.tssShare = tssShare
            self.address = EthereumAddress(evmAddress)
            self.authSigs = authSigs
        }

        /// hash and sign data
        public func sign(data: Data) throws -> Data {
            let hash = data.sha3(.keccak256)
            let signature = try self.sign(message: hash)
            return signature
        }

        /// hash and sign hex string
        public func sign(hex: String) throws -> Data {
            if let data = Data(hex: hex) {
                return try self.sign(data: data)
            } else {
                throw EthereumAccountError.signError
            }
        }

        /// Signing hashed string
        public func sign(hash: String) throws -> Data {
            if let data = hash.web3.hexData {
                return try self.sign(message: data)
            } else {
                throw EthereumAccountError.signError
            }
        }

        /// Signing Data without hashing
        public func sign(message: Data) throws -> Data {
            // Create tss Client using helper
            let (client, coeffs) = try bootstrapTssClient(selectedTag: self.selectedTag, tssNonce: self.tssNonce,
                                                          publicKey: self.publicKey, tssShare: self.tssShare, tssIndex: self.tssIndex,
                                                          nodeIndexes: self.nodeIndexes, factorKey: self.factorKey, verifier: self.verifier,
                                                          verifierId: self.verifierID, tssEndpoints: self.tssEndpoints)

            // Wait for sockets to be connected
            let connected = try client.checkConnected()
            if !(connected) {
                throw EthereumSignerError.unknownError
            }

            let precompute = try client.precompute(serverCoeffs: coeffs, signatures: self.authSigs)

            let ready = try client.isReady()
            if !(ready) {
                throw EthereumSignerError.unknownError
            }

            let signingMessage = message.base64EncodedString()

            // swiftlint:disable:next identifier_name
            let (s, r, v) = try client.sign(message: signingMessage, hashOnly: true, original_message: nil, precompute: precompute, signatures: self.authSigs)

            try client.cleanup(signatures: self.authSigs)

            guard let signature = Data(hexString: try TSSHelpers.hexSignature(s: s, r: r, v: v)) else { throw EthereumSignerError.unknownError }
            return signature
        }

        /// Signing utf8 encoded message String without hashing
        public func sign(message: String) throws -> Data {
            if let data = message.data(using: .utf8) {
                return try self.sign(data: data)
            } else {
                throw EthereumAccountError.signError
            }
        }

        /// prefix message and hash it before signing
        public func signMessage(message: Data) throws -> String {
            let prefix = "\u{19}Ethereum Signed Message:\n\(String(message.count))"
            guard var data = prefix.data(using: .ascii) else {
                throw EthereumAccountError.signError
            }
            data.append(message)
            let hash = data.web3.keccak256

            guard var signed = try? self.sign(message: hash) else {
                throw EthereumAccountError.signError
            }

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

        /// signing TypedData
        public func signMessage(message: TypedData) throws -> String {
            let hash = try message.signableHash()

            guard var signed = try? self.sign(message: hash) else {
                throw EthereumAccountError.signError
            }

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
    
        /// Signing EthereumTransaction
        public func signtx(transaction: EthereumTransaction) throws -> SignedTransaction {
            guard let raw = transaction.raw else {
               throw EthereumSignerError.emptyRawTransaction
            }
            
            // hash and sign data
            var signed = try self.sign(data: raw)
            // Check last char (v)
            guard var last = signed.popLast() else {
                throw EthereumAccountError.signError
            }

            if last < 27 {
                last += 27
            }

            signed.append(last)
            return SignedTransaction(transaction: transaction, signature: signed)
        }
}

