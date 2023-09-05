import BigInt
import Foundation
import web3

public typealias Ether = Double
public typealias Wei = BigUInt

enum TorusWeb3UtilsError: Error {
    case conversionError
}

public final class TorusWeb3Utils {
    // NOTE: calculate wei by 10^18
    private static let etherInWei = pow(Double(10), 18)
    private static let etherInGwei = pow(Double(10), 9)

    /// Converts Wei to Ether
    ///
    /// - Parameters:
    ///   - wei : Amount of Wei
    ///
    /// - Returns: `Ether`
    ///
    /// - Throws: On conversion failure
    public static func toEther(wei: Wei) throws -> Ether {
        guard let decimalWei = Double(wei.description) else {
            throw TorusWeb3UtilsError.conversionError
        }
        return decimalWei / etherInWei
    }

    /// Converts Gwei to Ether
    ///
    /// - Parameters:
    ///   - gwei : Amount of gwei
    ///
    /// - Returns: `Ether`
    ///
    /// - Throws: On conversion failure
    public static func toEther(gwei: BigUInt) throws -> Ether {
        guard let decimalWei = Double(gwei.description) else {
            throw TorusWeb3UtilsError.conversionError
        }
        return decimalWei / etherInGwei
    }

    /// Converts Ether to Wei
    ///
    /// - Parameters:
    ///   - ether : Amount of Ether
    ///
    /// - Returns: `Wei`
    public static func toWei(ether: Ether) -> Wei {
        let wei = Wei(ether * etherInWei)
        return wei
    }

    /// Converts Ether to Wei
    ///
    /// - Parameters:
    ///   - ether : Amount of Ether in string format
    ///
    /// - Returns: `Wei`
    ///
    /// - Throws: On conversion failure
    public static func toWei(ether: String) throws -> Wei {
        guard let decimalEther = Double(ether) else {
            throw TorusWeb3UtilsError.conversionError
        }
        return toWei(ether: decimalEther)
    }

    /// Converts Gwei to Wei for calculating gas prive and gas limit
    ///
    /// - Parameters:
    ///   - gwei : Amount of Gwei
    ///
    /// - Returns: `Wei`
    ///
    /// - Throws: On conversion failure
    public static func toWei(gwei: Double) -> Wei {
        return Wei(gwei * 1000000000)
    }
}
