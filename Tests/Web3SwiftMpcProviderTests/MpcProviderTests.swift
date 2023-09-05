import BigInt
import web3
import Web3SwiftMpcProvider
import XCTest

final class Web3SwiftMpcProviderTests: XCTestCase {
    func testSigningMessage() throws {
        let fullAddress = "04238569d5e12caf57d34fb5b2a0679c7775b5f61fd18cd69db9cc600a651749c3ec13a9367380b7a024a67f5e663f3afd40175c3223da63f6024b05d0bd9f292e"
        let factorKey = "3b4af35bc4838471f94825f34c4f649904a258c0907d348bed653eb0c94ec6c0"
        let tssNonce = 0
        let tssShare = "4f62ddd962fab8b0777bd18a2e6f3992c7e15ff929df79a15a7046da46af5a05"
        let tssIndex = "2"
        let selected_tag = "default"
        let verifier = "google-lrc"
        let verifierId = "hqjang95@gmail.com"
        let tssEndpoints = ["https://sapphire-1.auth.network/tss", "https://sapphire-2.auth.network/tss", "https://sapphire-3.auth.network/tss", "https://sapphire-4.auth.network/tss", "https://sapphire-5.auth.network/tss"]
        let sigs = ["{\"sig\":\"16de7c5812aedf492e7afe4a9c0607dba6d8d908d30ef1eb2e4761bc300bb3fc62bfbd0e94b03aa5eb496b5ed7adfa4203fa9745d90673cf789d3a989f872ae41b\",\"data\":\"eyJleHAiOjE2OTM0NjYxMTAsInRlbXBfa2V5X3giOiI2MTg3NTM3ZTc1YThhNWQ3NWQzZjhkMGZmYzE4NjMwNTRjYjEzNmE3YzRjYWVjNWRkYjUyZjViNmY1MTcyZDEwIiwidGVtcF9rZXlfeSI6ImFhNTNhNmE2N2YzOTE1NzNmYTA1YTVkZWViZjM2MDVkM2MzODljNjhjMDhlOGI5YzllNDQyODU1ZWYyYWE2ZTkiLCJ2ZXJpZmllcl9uYW1lIjoiZ29vZ2xlLWxyYyIsInZlcmlmaWVyX2lkIjoiaHFqYW5nOTVAZ21haWwuY29tIiwic2NvcGUiOiIifQ==\"}", "{\"sig\":\"50a7451f2a8af5f3e193b3e53768e3107f8d606ef5e9ee70aba15fba8e67a1be279d71f8d3b6a954beef5e5119a10195c3017e48b3f0a93b557ed9366ce38f171c\",\"data\":\"eyJleHAiOjE2OTM0NjYxMTAsInRlbXBfa2V5X3giOiI2MTg3NTM3ZTc1YThhNWQ3NWQzZjhkMGZmYzE4NjMwNTRjYjEzNmE3YzRjYWVjNWRkYjUyZjViNmY1MTcyZDEwIiwidGVtcF9rZXlfeSI6ImFhNTNhNmE2N2YzOTE1NzNmYTA1YTVkZWViZjM2MDVkM2MzODljNjhjMDhlOGI5YzllNDQyODU1ZWYyYWE2ZTkiLCJ2ZXJpZmllcl9uYW1lIjoiZ29vZ2xlLWxyYyIsInZlcmlmaWVyX2lkIjoiaHFqYW5nOTVAZ21haWwuY29tIiwic2NvcGUiOiIifQ==\"}", "{\"sig\":\"d94979a0f743a8a41630167622c5b443b148f231bb2293e60a17ab4ea7ebdf38713b81b0bc9161ecd3949ddcf8cfca9734f136ba02c2e4e670fb4b8523299ab01b\",\"data\":\"eyJleHAiOjE2OTM0NjYxMTAsInRlbXBfa2V5X3giOiI2MTg3NTM3ZTc1YThhNWQ3NWQzZjhkMGZmYzE4NjMwNTRjYjEzNmE3YzRjYWVjNWRkYjUyZjViNmY1MTcyZDEwIiwidGVtcF9rZXlfeSI6ImFhNTNhNmE2N2YzOTE1NzNmYTA1YTVkZWViZjM2MDVkM2MzODljNjhjMDhlOGI5YzllNDQyODU1ZWYyYWE2ZTkiLCJ2ZXJpZmllcl9uYW1lIjoiZ29vZ2xlLWxyYyIsInZlcmlmaWVyX2lkIjoiaHFqYW5nOTVAZ21haWwuY29tIiwic2NvcGUiOiIifQ==\"}"]

        let params = EthTssAccountParams(publicKey: fullAddress, factorKey: factorKey, tssNonce: Int32(tssNonce), tssShare: tssShare, tssIndex: tssIndex, selectedTag: selected_tag, verifier: verifier, verifierID: verifierId, nodeIndexes: [], tssEndpoints: tssEndpoints, authSigs: sigs)

        let account = try EthereumTssAccount(params: params)

        let msg = "hello world"
        let _ = try account.sign(message: msg)
    }

    func testSigningTx() async throws {
        let fullAddress = "04238569d5e12caf57d34fb5b2a0679c7775b5f61fd18cd69db9cc600a651749c3ec13a9367380b7a024a67f5e663f3afd40175c3223da63f6024b05d0bd9f292e"
        let factorKey = "3b4af35bc4838471f94825f34c4f649904a258c0907d348bed653eb0c94ec6c0"
        let tssNonce = 0
        let tssShare = "4f62ddd962fab8b0777bd18a2e6f3992c7e15ff929df79a15a7046da46af5a05"
        let tssIndex = "2"
        let selected_tag = "default"
        let verifier = "google-lrc"
        let verifierId = "hqjang95@gmail.com"
        let tssEndpoints = ["https://sapphire-1.auth.network/tss", "https://sapphire-2.auth.network/tss", "https://sapphire-3.auth.network/tss", "https://sapphire-4.auth.network/tss", "https://sapphire-5.auth.network/tss"]
        let sigs = ["{\"sig\":\"16de7c5812aedf492e7afe4a9c0607dba6d8d908d30ef1eb2e4761bc300bb3fc62bfbd0e94b03aa5eb496b5ed7adfa4203fa9745d90673cf789d3a989f872ae41b\",\"data\":\"eyJleHAiOjE2OTM0NjYxMTAsInRlbXBfa2V5X3giOiI2MTg3NTM3ZTc1YThhNWQ3NWQzZjhkMGZmYzE4NjMwNTRjYjEzNmE3YzRjYWVjNWRkYjUyZjViNmY1MTcyZDEwIiwidGVtcF9rZXlfeSI6ImFhNTNhNmE2N2YzOTE1NzNmYTA1YTVkZWViZjM2MDVkM2MzODljNjhjMDhlOGI5YzllNDQyODU1ZWYyYWE2ZTkiLCJ2ZXJpZmllcl9uYW1lIjoiZ29vZ2xlLWxyYyIsInZlcmlmaWVyX2lkIjoiaHFqYW5nOTVAZ21haWwuY29tIiwic2NvcGUiOiIifQ==\"}", "{\"sig\":\"50a7451f2a8af5f3e193b3e53768e3107f8d606ef5e9ee70aba15fba8e67a1be279d71f8d3b6a954beef5e5119a10195c3017e48b3f0a93b557ed9366ce38f171c\",\"data\":\"eyJleHAiOjE2OTM0NjYxMTAsInRlbXBfa2V5X3giOiI2MTg3NTM3ZTc1YThhNWQ3NWQzZjhkMGZmYzE4NjMwNTRjYjEzNmE3YzRjYWVjNWRkYjUyZjViNmY1MTcyZDEwIiwidGVtcF9rZXlfeSI6ImFhNTNhNmE2N2YzOTE1NzNmYTA1YTVkZWViZjM2MDVkM2MzODljNjhjMDhlOGI5YzllNDQyODU1ZWYyYWE2ZTkiLCJ2ZXJpZmllcl9uYW1lIjoiZ29vZ2xlLWxyYyIsInZlcmlmaWVyX2lkIjoiaHFqYW5nOTVAZ21haWwuY29tIiwic2NvcGUiOiIifQ==\"}", "{\"sig\":\"d94979a0f743a8a41630167622c5b443b148f231bb2293e60a17ab4ea7ebdf38713b81b0bc9161ecd3949ddcf8cfca9734f136ba02c2e4e670fb4b8523299ab01b\",\"data\":\"eyJleHAiOjE2OTM0NjYxMTAsInRlbXBfa2V5X3giOiI2MTg3NTM3ZTc1YThhNWQ3NWQzZjhkMGZmYzE4NjMwNTRjYjEzNmE3YzRjYWVjNWRkYjUyZjViNmY1MTcyZDEwIiwidGVtcF9rZXlfeSI6ImFhNTNhNmE2N2YzOTE1NzNmYTA1YTVkZWViZjM2MDVkM2MzODljNjhjMDhlOGI5YzllNDQyODU1ZWYyYWE2ZTkiLCJ2ZXJpZmllcl9uYW1lIjoiZ29vZ2xlLWxyYyIsInZlcmlmaWVyX2lkIjoiaHFqYW5nOTVAZ21haWwuY29tIiwic2NvcGUiOiIifQ==\"}"]

        let params = EthTssAccountParams(publicKey: fullAddress, factorKey: factorKey, tssNonce: Int32(tssNonce), tssShare: tssShare, tssIndex: tssIndex, selectedTag: selected_tag, verifier: verifier, verifierID: verifierId, nodeIndexes: [], tssEndpoints: tssEndpoints, authSigs: sigs)

        let tssAccount = try EthereumTssAccount(params: params)
        let RPC_URL = "https://rpc.ankr.com/eth_goerli"
        let chainID = 5
        let web3Client = EthereumHttpClient(url: URL(string: RPC_URL)!)

        let amount = 0.001
        let toAddress = tssAccount.address
        let fromAddress = tssAccount.address
        let gasPrice = try await web3Client.eth_gasPrice()
        let maxTipInGwie = BigUInt(TorusWeb3Utils.toEther(gwei: BigUInt(amount)))
        let totalGas = gasPrice + maxTipInGwie
        let gasLimit = BigUInt(21000)

        let amtInGwie = TorusWeb3Utils.toWei(ether: amount)
        let nonce = try await web3Client.eth_getTransactionCount(address: fromAddress, block: .Latest)
        let transaction = EthereumTransaction(from: fromAddress, to: toAddress, value: amtInGwie, data: Data(), nonce: nonce + 1, gasPrice: totalGas, gasLimit: gasLimit, chainId: chainID)
        let _ = try tssAccount.sign(transaction: transaction)
    }
}
