//
//  SecureSignHelpers.swift
//
//  Created by Bartosz Dadok on 18/10/2025.
//

import Foundation
import Security
import LocalAuthentication
import SecureSignRust

extension SecureSignImpl {
    
    func loadKeyFromKeychain(keyId: String) throws -> SecKey {
        guard let tag = keyId.data(using: .utf8) else {
            throw SecureSignError.invalidKeyId
        }

        let authContext = LAContext()
        authContext.localizedReason = "Authenticate to access the key"
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassKey,
            kSecAttrApplicationTag as String: tag,
            kSecAttrKeyType as String: kSecAttrKeyTypeECSECPrimeRandom,
            kSecAttrKeyClass as String: kSecAttrKeyClassPrivate,
            kSecReturnRef as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne,
            kSecUseAuthenticationContext as String: authContext
        ]

        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)

        switch status {
        case errSecSuccess:
            guard let item = item else {
                throw SecureSignError.invalidKeyReference
            }
            return item as! SecKey

        case errSecItemNotFound:
            throw SecureSignError.keyNotFound

        case errSecAuthFailed:
            throw SecureSignError.authenticationFailed

        default:
            throw SecureSignError.keychainQueryFailed(status)
        }
    }
    
    
    func canonicalizeChallenge(jsonString: String) throws -> Data {
        guard let jsonData = jsonString.data(using: .utf8), !jsonData.isEmpty else {
            throw SecureSignError.invalidInput
        }

        var errorCode: Int32 = 0
        let canonicalString: String? = jsonData.withUnsafeBytes { rawBuf -> String? in
            guard let rawBase = rawBuf.baseAddress else { return nil }
            var local: Int32 = 0
            let res = withUnsafeMutablePointer(to: &local) { errPtr -> String? in
                guard let cPtr = canonicalize_challenge(
                    rawBase.assumingMemoryBound(to: UInt8.self),
                    UInt(rawBuf.count),
                    errPtr
                ) else { return nil }
                defer { free_string(cPtr) }
                return String(cString: cPtr)
            }
            errorCode = (res == nil) ? local : 0
            return res
        }

        guard let canonical = canonicalString, !canonical.isEmpty else {
            switch errorCode {
            case 3001: throw SecureSignError.invalidInput
            case 3002: throw SecureSignError.invalidVersion
            case 3003: throw SecureSignError.invalidAlgorithm
            case 3004: throw SecureSignError.invalidSigFormat
            case 3005: throw SecureSignError.invalidExpiration
            case 3006: throw SecureSignError.forbiddenChars
            case 3007: throw SecureSignError.jsonParseError
            case 3008: throw SecureSignError.utf8Error
            case 3009: throw SecureSignError.cStringError
            default:   throw SecureSignError.unknownError(NSError(domain: "SecureSign", code: Int(errorCode)))
            }
        }

        guard let canonicalData = canonical.data(using: .utf8) else {
            throw SecureSignError.utf8Error
        }
        return canonicalData
    }
    
    
    func convertDerToP1363(derSignature: Data) throws -> Data {
        
        let p1363Data = derSignature.withUnsafeBytes { (bytes: UnsafeRawBufferPointer) -> Data? in
            guard let rawBase = bytes.baseAddress else {
                return nil
            }
            let u8Base = rawBase.assumingMemoryBound(to: UInt8.self)
            
            guard let ptr = der_to_p1363(u8Base, UInt(bytes.count)) else {
                return nil
            }
            defer { free_bytes(ptr) }
            
            return Data(bytes: ptr, count: 64)
        }
        
        guard let p1363 = p1363Data else {
            throw SecureSignError.signatureConversionFailed
        }
        guard p1363.count == 64 else {
            throw SecureSignError.signatureConversionFailed
        }
        
        return p1363
    }
    
    
    func base64urlEncode(_ data: Data) -> String {
        let base64 = data.base64EncodedString()
        return base64
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "=", with: "")
    }
}