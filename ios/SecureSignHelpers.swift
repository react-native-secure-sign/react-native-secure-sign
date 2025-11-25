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
    
    
    func base64urlDecode(_ base64url: String) throws -> Data {
        var base64 = base64url
            .replacingOccurrences(of: "-", with: "+")
            .replacingOccurrences(of: "_", with: "/")
        let remainder = base64.count % 4
        if remainder > 0 {
            base64 += String(repeating: "=", count: 4 - remainder)
        }
        guard let data = Data(base64Encoded: base64) else {
            throw SecureSignError.invalidInput
        }
        return data
    }
    
    func base64urlEncode(_ data: Data) -> String {
        let base64 = data.base64EncodedString()
        return base64
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "=", with: "")
    }
}