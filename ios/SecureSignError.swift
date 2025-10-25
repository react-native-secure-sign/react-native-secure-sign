//
//  SecureSignError.swift
//
//  Created by Bartosz Dadok on 18/10/2025.
//
//  Error Codes Documentation:
//  =========================
//  1001 - Key generation failed (Secure Enclave error)
//  1002 - Public key extraction failed
//  1003 - Access control creation failed
//  1004 - Key deletion failed
//  1005 - Key not found
//  1006 - Invalid key ID (cannot convert to data)
//  1007 - Invalid key reference (wrong type)
//  1008 - Authentication failed (biometric/passcode required)
//  1009 - Keychain query failed (system error)
//  1010 - Public key format conversion failed (SEC1 to SPKI)
//  2001 - Biometric authentication not available
//  2002 - No biometric data enrolled
//  2003 - Biometric authentication locked out (too many failed attempts)
//  3001 - Key already exists
//  9999 - Unknown error (catch-all for unexpected errors)
//

import Foundation
import Security

enum SecureSignError: Error {
    case keyGenerationFailed(CFError?)
    case publicKeyExtractionFailed
    case accessControlCreationFailed
    case keyDeletionFailed(OSStatus)
    case keyNotFound
    case invalidKeyId
    case invalidKeyReference
    case authenticationFailed
    case keychainQueryFailed(OSStatus)
    case publicKeyFormatConversionFailed
    case biometricNotAvailable
    case biometricNotEnrolled
    case biometricLockout
    case keyAlreadyExists
    case unknownError(Error)
    
    var errorCode: Int {
        switch self {
        case .keyGenerationFailed:
            return 1001
        case .publicKeyExtractionFailed:
            return 1002
        case .accessControlCreationFailed:
            return 1003
        case .keyDeletionFailed:
            return 1004
        case .keyNotFound:
            return 1005
        case .invalidKeyId:
            return 1006
        case .invalidKeyReference:
            return 1007
        case .authenticationFailed:
            return 1008
        case .keychainQueryFailed:
            return 1009
        case .publicKeyFormatConversionFailed:
            return 1010
        case .biometricNotAvailable:
            return 2001
        case .biometricNotEnrolled:
            return 2002
        case .biometricLockout:
            return 2003
        case .keyAlreadyExists:
            return 3001
        case .unknownError:
            return 9999
        }
    }
}
