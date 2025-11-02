//
//  SecureSignError.swift
//
//  Created by Bartosz Dadok on 18/10/2025.
//
//  Error Codes Documentation:
//  =========================
//  Key Management Errors (1001-1011):
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
//  1011 - Key already exists
//
//
//  Biometric Errors (2001-2003):
//  2001 - Biometric authentication not available
//  2002 - No biometric data enrolled
//  2003 - Biometric authentication locked out (too many failed attempts)
//
//  Challenge Validation Errors (3001-3009):
//  3001 - Invalid input (null pointer or empty data)
//  3002 - Invalid version (must be "SS1")
//  3003 - Invalid algorithm (must be "ES256")
//  3004 - Invalid signature format (must be "P1363")
//  3005 - Invalid expiration (exp must be > ts)
//  3006 - Forbidden characters (contains | or \0)
//  3007 - JSON parse error
//  3008 - UTF8 error
//  3009 - C string conversion error
//
//  Signature Conversion Errors (4001-4005):
//  4001 - Invalid DER format
//  4002 - Signature conversion failed
//
//  Algorithm Errors (5001):
//  5001 - Algorithm not supported
//
//  General Errors (9999):
//  9999 - Unknown error (catch-all for unexpected errors)
//

import Foundation
import Security

enum SecureSignError: Error {
    // Key management errors
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
    case keyAlreadyExists
    // Biometric errors
    case biometricNotAvailable
    case biometricNotEnrolled
    case biometricLockout
    // Challenge validation errors
    case invalidInput
    case invalidVersion
    case invalidAlgorithm
    case invalidSigFormat
    case invalidExpiration
    case forbiddenChars
    case jsonParseError
    case utf8Error
    case cStringError
    // Signature conversion errors
    case invalidDerFormat
    case signatureConversionFailed
    // Algorithm errors
    case algorithmNotSupported
    // General errors
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
        case .keyAlreadyExists:
            return 1011
        // Biometric errors
        case .biometricNotAvailable:
            return 2001
        case .biometricNotEnrolled:
            return 2002
        case .biometricLockout:
            return 2003
        // Challenge validation errors
        case .invalidInput:
            return 3001
        case .invalidVersion:
            return 3002
        case .invalidAlgorithm:
            return 3003
        case .invalidSigFormat:
            return 3004
        case .invalidExpiration:
            return 3005
        case .forbiddenChars:
            return 3006
        case .jsonParseError:
            return 3007
        case .utf8Error:
            return 3008
        case .cStringError:
            return 3009
        // Signature conversion errors
        case .invalidDerFormat:
            return 4001
        case .signatureConversionFailed:
            return 4002
        // Algorithm errors
        case .algorithmNotSupported:
            return 5001
        // General errors
        case .unknownError:
            return 9999
        }
        
    }
}
