import XCTest
@testable import Web3SwiftMpcProvider
import secp256k1
import BigInt
import web3

final class Web3SwiftMpcProviderTests: XCTestCase {
    func testExample() throws {
        // get example share signature
        
//        XCTAssertEqual(Web3SwiftMpcProvider().text, "Hello, World!")
    }
    
    func testSigningMessage() {
        let fullAddress = "04e9c133d21e56435a3f410dbdfc2330704ecd98718fdb06f607415aa18b3d981e32f022656a771f9488bb4ae94e50a1f269b1d8d1df7052bd44d43d892c941f1f"
        let factorKey = "b8a2281666923af982a72c6ee2f050242a8aa81a6ed33f81c24f1d98377b9406"
        let tssNonce = 0
        let tssShare = "2852d4132ff0b296aed2cb1d5cc732a737b26fee99ae60bfc35f639d25a5cf59"
        let tssIndex = "2"
        let selected_tag = ""
        let verifier = "google-lrc"
        let verifierId = "hqjang95@gmail.com"
        let tssEndpoints = ["https://sapphire-1.auth.network/tss", "https://sapphire-2.auth.network/tss", "https://sapphire-3.auth.network/tss", "https://sapphire-4.auth.network/tss", "https://sapphire-5.auth.network/tss"]
        let sigs = ["{\"data\":\"eyJleHAiOjE2OTMyODgxMDUsInRlbXBfa2V5X3giOiJkMjgxYWFjNmUyOWIyZmU2NGQyYWFiNDJjMDBjOGJhZWRmNWVjODhjYjk2YjBiMGYzNWUzOGM1ZjFjYjA0Nzc5IiwidGVtcF9rZXlfeSI6ImE4Yzc3YmM2YzE3NzhkMjQ3YmRlMzZmYmM5MWZiNDQ4NGQ3MDQ3Mjc2ZDljYjg0ZDdlMjY5YjNjMzAwYjZiYzUiLCJ2ZXJpZmllcl9uYW1lIjoiZ29vZ2xlLWxyYyIsInZlcmlmaWVyX2lkIjoiaHFqYW5nOTVAZ21haWwuY29tIiwic2NvcGUiOiIifQ==\",\"sig\":\"188ecc2fc2dd477566bbe3c0c7b85560f8f64cc317713dd1b3a0f7a2f3d5f8136e8fbb68a30076f4c0f7f186f7091567cbd9487907c311598316c5686cb79a611c\"}", "{\"data\":\"eyJleHAiOjE2OTMyODgxMDUsInRlbXBfa2V5X3giOiJkMjgxYWFjNmUyOWIyZmU2NGQyYWFiNDJjMDBjOGJhZWRmNWVjODhjYjk2YjBiMGYzNWUzOGM1ZjFjYjA0Nzc5IiwidGVtcF9rZXlfeSI6ImE4Yzc3YmM2YzE3NzhkMjQ3YmRlMzZmYmM5MWZiNDQ4NGQ3MDQ3Mjc2ZDljYjg0ZDdlMjY5YjNjMzAwYjZiYzUiLCJ2ZXJpZmllcl9uYW1lIjoiZ29vZ2xlLWxyYyIsInZlcmlmaWVyX2lkIjoiaHFqYW5nOTVAZ21haWwuY29tIiwic2NvcGUiOiIifQ==\",\"sig\":\"e3d3920cc952418c064333be2f614542abdcac529764c82329569bd5ce894c9368d201cb43e2f49ebbc34507c858ba631ba64261ae3c05de8e6ab1c73de14b3a1b\"}", "{\"sig\":\"4b0ce34422c1b737dd1a26bfc4679ede79c8851c284cac26e35e65ab9206b46276e3cdd8b219591a8740253368cf102b12bb285edbb23dacb68007bc0273eff31c\",\"data\":\"eyJleHAiOjE2OTMyODgxMDUsInRlbXBfa2V5X3giOiJkMjgxYWFjNmUyOWIyZmU2NGQyYWFiNDJjMDBjOGJhZWRmNWVjODhjYjk2YjBiMGYzNWUzOGM1ZjFjYjA0Nzc5IiwidGVtcF9rZXlfeSI6ImE4Yzc3YmM2YzE3NzhkMjQ3YmRlMzZmYmM5MWZiNDQ4NGQ3MDQ3Mjc2ZDljYjg0ZDdlMjY5YjNjMzAwYjZiYzUiLCJ2ZXJpZmllcl9uYW1lIjoiZ29vZ2xlLWxyYyIsInZlcmlmaWVyX2lkIjoiaHFqYW5nOTVAZ21haWwuY29tIiwic2NvcGUiOiIifQ==\"}"]
        
        let params = EthTssAccountParams(publicKey: fullAddress, factorKey: factorKey, tssNonce: Int32(tssNonce), tssShare: tssShare, tssIndex: tssIndex, selectedTag: selected_tag, verifier: verifier, verifierID: verifierId, nodeIndexes: [], tssEndpoints: tssEndpoints, authSigs: sigs)
        
        do {
            let account = try EthereumTssAccount(params: params)

            let msg = "hello world"
            let signature = try account.sign(message: msg)
            let str = String(bytes: signature)
            
        } catch let err{
            XCTFail(err.localizedDescription)
        }
        
        
    }
    
    func testSigningTx() async {
        do {
            let fullAddress = "04e9c133d21e56435a3f410dbdfc2330704ecd98718fdb06f607415aa18b3d981e32f022656a771f9488bb4ae94e50a1f269b1d8d1df7052bd44d43d892c941f1f"
            let factorKey = "b8a2281666923af982a72c6ee2f050242a8aa81a6ed33f81c24f1d98377b9406"
            let tssNonce = 0
            let tssShare = "2852d4132ff0b296aed2cb1d5cc732a737b26fee99ae60bfc35f639d25a5cf59"
            let tssIndex = "2"
            let selected_tag = ""
            let verifier = "google-lrc"
            let verifierId = "hqjang95@gmail.com"
            let tssEndpoints = ["https://sapphire-1.auth.network/tss", "https://sapphire-2.auth.network/tss", "https://sapphire-3.auth.network/tss", "https://sapphire-4.auth.network/tss", "https://sapphire-5.auth.network/tss"]
            let sigs = ["{\"data\":\"eyJleHAiOjE2OTMyODgxMDUsInRlbXBfa2V5X3giOiJkMjgxYWFjNmUyOWIyZmU2NGQyYWFiNDJjMDBjOGJhZWRmNWVjODhjYjk2YjBiMGYzNWUzOGM1ZjFjYjA0Nzc5IiwidGVtcF9rZXlfeSI6ImE4Yzc3YmM2YzE3NzhkMjQ3YmRlMzZmYmM5MWZiNDQ4NGQ3MDQ3Mjc2ZDljYjg0ZDdlMjY5YjNjMzAwYjZiYzUiLCJ2ZXJpZmllcl9uYW1lIjoiZ29vZ2xlLWxyYyIsInZlcmlmaWVyX2lkIjoiaHFqYW5nOTVAZ21haWwuY29tIiwic2NvcGUiOiIifQ==\",\"sig\":\"188ecc2fc2dd477566bbe3c0c7b85560f8f64cc317713dd1b3a0f7a2f3d5f8136e8fbb68a30076f4c0f7f186f7091567cbd9487907c311598316c5686cb79a611c\"}", "{\"data\":\"eyJleHAiOjE2OTMyODgxMDUsInRlbXBfa2V5X3giOiJkMjgxYWFjNmUyOWIyZmU2NGQyYWFiNDJjMDBjOGJhZWRmNWVjODhjYjk2YjBiMGYzNWUzOGM1ZjFjYjA0Nzc5IiwidGVtcF9rZXlfeSI6ImE4Yzc3YmM2YzE3NzhkMjQ3YmRlMzZmYmM5MWZiNDQ4NGQ3MDQ3Mjc2ZDljYjg0ZDdlMjY5YjNjMzAwYjZiYzUiLCJ2ZXJpZmllcl9uYW1lIjoiZ29vZ2xlLWxyYyIsInZlcmlmaWVyX2lkIjoiaHFqYW5nOTVAZ21haWwuY29tIiwic2NvcGUiOiIifQ==\",\"sig\":\"e3d3920cc952418c064333be2f614542abdcac529764c82329569bd5ce894c9368d201cb43e2f49ebbc34507c858ba631ba64261ae3c05de8e6ab1c73de14b3a1b\"}", "{\"sig\":\"4b0ce34422c1b737dd1a26bfc4679ede79c8851c284cac26e35e65ab9206b46276e3cdd8b219591a8740253368cf102b12bb285edbb23dacb68007bc0273eff31c\",\"data\":\"eyJleHAiOjE2OTMyODgxMDUsInRlbXBfa2V5X3giOiJkMjgxYWFjNmUyOWIyZmU2NGQyYWFiNDJjMDBjOGJhZWRmNWVjODhjYjk2YjBiMGYzNWUzOGM1ZjFjYjA0Nzc5IiwidGVtcF9rZXlfeSI6ImE4Yzc3YmM2YzE3NzhkMjQ3YmRlMzZmYmM5MWZiNDQ4NGQ3MDQ3Mjc2ZDljYjg0ZDdlMjY5YjNjMzAwYjZiYzUiLCJ2ZXJpZmllcl9uYW1lIjoiZ29vZ2xlLWxyYyIsInZlcmlmaWVyX2lkIjoiaHFqYW5nOTVAZ21haWwuY29tIiwic2NvcGUiOiIifQ==\"}"]
            
            let params = EthTssAccountParams(publicKey: fullAddress, factorKey: factorKey, tssNonce: Int32(tssNonce), tssShare: tssShare, tssIndex: tssIndex, selectedTag: selected_tag, verifier: verifier, verifierID: verifierId, nodeIndexes: [], tssEndpoints: tssEndpoints, authSigs: sigs)
            
            let tssAccount = try EthereumTssAccount(params: params)

    //                        let RPC_URL = "https://api.avax-test.network/ext/bc/C/rpc"
    //                        let chainID = 43113
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
        } catch let err {
            XCTFail(err.localizedDescription)
        }
        
    }
}
