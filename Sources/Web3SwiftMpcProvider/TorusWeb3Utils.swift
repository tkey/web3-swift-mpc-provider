import BigInt
import Foundation
import web3
import CryptoKit

public typealias Ether = Double
public typealias Wei = BigUInt

public final class TorusWeb3Utils {
    // NOTE: calculate wei by 10^18
    private static let etherInWei = pow(Double(10), 18)
    private static let etherInGwei = pow(Double(10), 9)

    /// Convert Wei(BInt) unit to Ether(Decimal) unit
    public static func toEther(wei: Wei) -> Ether {
        guard let decimalWei = Double(wei.description) else {
            return 0
        }
        return decimalWei / etherInWei
    }

    public static func toEther(gwei: BigUInt) -> Ether {
        guard let decimalWei = Double(gwei.description) else {
            return 0
        }
        return decimalWei / etherInGwei
    }

    /// Convert Ether(Decimal) unit to Wei(BInt) unit
    public static func toWei(ether: Ether) -> Wei {
        let wei = Wei(ether * etherInWei)
        return wei
    }

    /// Convert Ether(String) unit to Wei(BInt) unit
    public static func toWei(ether: String) -> Wei {
        guard let decimalEther = Double(ether) else {
            return 0
        }
        return toWei(ether: decimalEther)
    }

    // Only used for calcurating gas price and gas limit.
    public static func toWei(gwei: Double) -> Wei {
        return Wei(gwei * 1000000000)
    }
}
