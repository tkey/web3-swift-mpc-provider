//  web3swift
//
//  Created by Alex Vlasov.
//  Copyright © 2018 Alex Vlasov. All rights reserved.
//

import Foundation

extension String {
    func stripHexPrefix() -> String {
        if hasPrefix("0x") {
            let indexStart = index(startIndex, offsetBy: 2)
            return String(self[indexStart...])
        }
        return self
    }
}

extension String {
    func toChecksumAddress() -> String {
        let lowerCaseAddress = stripHexPrefix().lowercased()
        let arr = Array(lowerCaseAddress)
        let hash = Array(lowerCaseAddress.sha3(.keccak256))
        var result = "0x"
        for idx in 0 ... lowerCaseAddress.count - 1 {
            if let val = Int(String(hash[idx]), radix: 16), val >= 8 {
                result.append(arr[idx].uppercased())
            } else {
                result.append(arr[idx])
            }
        }
        return result
    }
}
