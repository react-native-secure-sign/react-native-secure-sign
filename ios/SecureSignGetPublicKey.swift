//
//  SecureSignGetPublicKey.swift
//
//  Created by Bartosz Dadok on 18/10/2025.
//

import Foundation
import Security
import React
import SecureSignRust

extension SecureSignImpl {
    
    private func loadKeyFromKeychain(keyId: String) throws -> SecKey {
        guard let tag = keyId.data(using: .utf8) else {
            throw SecureSignError.invalidKeyId
        }

        let query: [String: Any] = [
            kSecClass as String: kSecClassKey,
            kSecAttrApplicationTag as String: tag,
            kSecAttrKeyType as String: kSecAttrKeyTypeECSECPrimeRandom,
            kSecAttrKeyClass as String: kSecAttrKeyClassPrivate,
            kSecReturnRef as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)

        switch status {
        case errSecSuccess:
            let privateKey = item as! SecKey
            return privateKey

        case errSecItemNotFound:
            throw SecureSignError.keyNotFound

        case errSecAuthFailed:
            throw SecureSignError.authenticationFailed

        default:
            throw SecureSignError.keychainQueryFailed(status)
        }
    }
    
    private func extractPublicKey(from privateKeyReference: SecKey) throws -> String {
        guard let publicKey = SecKeyCopyPublicKey(privateKeyReference) else {
            throw SecureSignError.publicKeyExtractionFailed
        }
        
        var error: Unmanaged<CFError>?
        guard let keyData = SecKeyCopyExternalRepresentation(publicKey, &error) else {
            throw SecureSignError.publicKeyExtractionFailed
        }
        
        let sec1Data = keyData as Data
        
        // Validate SEC1 format before calling Rust
        guard sec1Data.count == 65, sec1Data.first == 0x04 else {
            throw SecureSignError.publicKeyFormatConversionFailed
        }
        
        let spkiBase64url = sec1Data.withUnsafeBytes { (bytes: UnsafeRawBufferPointer) -> String? in
            guard let ptr = sec1_to_spki_der_b64url(bytes.bindMemory(to: UInt8.self).baseAddress!, UInt(sec1Data.count)) else {
                return nil
            }
            defer { free_string(ptr) }
            return String(cString: ptr)
        }
        
        guard let spkiBase64url = spkiBase64url, !spkiBase64url.isEmpty else {
            throw SecureSignError.publicKeyFormatConversionFailed
        }
        
        return spkiBase64url
    }
    
    @objc public func getPublicKey(keyId: String, resolve: @escaping RCTPromiseResolveBlock, reject: @escaping RCTPromiseRejectBlock) {
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                let privateKeyReference = try self.loadKeyFromKeychain(keyId: keyId)
                let publicKeyBase64 = try self.extractPublicKey(from: privateKeyReference)
                resolve(publicKeyBase64)
            } catch let error as SecureSignError {
                reject("\(error.errorCode)", nil, error)
            } catch {
                let unknownError = SecureSignError.unknownError(error)
                reject("\(unknownError.errorCode)", nil, unknownError)
            }
        }
    }
}
