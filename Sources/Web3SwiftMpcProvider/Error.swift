//
//  File.swift
//  
//
//  Created by CW Lee on 23/08/2023.
//

import Foundation


public enum CustomSigningError: Error {
    case generalError(error: String = "")
    case unknownError(error: String = "")

    public var errorDescription: String {
        switch self {
        case .generalError ( let err):
            return err
        
        case .unknownError ( let err):
            return err
        }
    }
}
