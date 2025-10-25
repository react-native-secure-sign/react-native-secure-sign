//
//  SecureSignGenerate.swift
//
//  Created by Bartosz Dadok on 18/10/2025.
//

import Foundation
import Security
import LocalAuthentication
import React
import SecureSignRust

extension SecureSignImpl {
    
    private func checkBiometricAvailability() throws {
        let localAuthentication = LAContext()
        var error: NSError?
        
        guard localAuthentication.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            if let laError = error.flatMap({ LAError(_nsError: $0) }) {
                switch laError.code {
                case .biometryNotAvailable:
                    throw SecureSignError.biometricNotAvailable
                case .biometryNotEnrolled:
                    throw SecureSignError.biometricNotEnrolled
                case .biometryLockout:
                    throw SecureSignError.biometricLockout
                default:
                    throw SecureSignError.biometricNotAvailable
                }
            } else {
                throw SecureSignError.biometricNotAvailable
            }
        }
    }
    
    
    private func createAccessControl(requireBiometric: Bool) throws -> SecAccessControl {
        var accessControlFlags: SecAccessControlCreateFlags = []
        
        if requireBiometric {
            accessControlFlags.insert(.biometryAny)
        }
        
        accessControlFlags.insert(.privateKeyUsage)
        
        guard let accessControl = SecAccessControlCreateWithFlags(
            kCFAllocatorDefault,
            kSecAttrAccessibleWhenUnlockedThisDeviceOnly,
            accessControlFlags,
            nil
        ) else {
            throw SecureSignError.accessControlCreationFailed
        }
        
        return accessControl
    }
    
    private func generateKeyPair(keyId: String, requireBiometric: Bool) throws -> String {
        if requireBiometric {
            try checkBiometricAvailability()
        }
        
        if keyExists(keyId: keyId) {
            throw SecureSignError.keyAlreadyExists
        }
        
        let accessControl = try createAccessControl(requireBiometric: requireBiometric)
        
        let keyAttributes: [String: Any] = [
            kSecAttrKeyType as String: kSecAttrKeyTypeECSECPrimeRandom,
            kSecAttrTokenID as String: kSecAttrTokenIDSecureEnclave,
            kSecPrivateKeyAttrs as String: [
                kSecAttrIsPermanent as String: true,
                kSecAttrApplicationTag as String: keyId.data(using: .utf8)!,
                kSecAttrAccessControl as String: accessControl
            ]
        ]
        
        var error: Unmanaged<CFError>?
        guard let privateKey = SecKeyCreateRandomKey(keyAttributes as CFDictionary, &error) else {
            throw SecureSignError.keyGenerationFailed(error?.takeRetainedValue())
        }
        
        guard let publicKey = SecKeyCopyPublicKey(privateKey) else {
            throw SecureSignError.publicKeyExtractionFailed
        }
        
        guard let keyData = SecKeyCopyExternalRepresentation(publicKey, &error) else {
            throw SecureSignError.publicKeyExtractionFailed
        }
        

        let sec1Data = keyData as Data
        
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
    
    private func keyExists(keyId: String) -> Bool {
        let query: [String: Any] = [
            kSecClass as String: kSecClassKey,
            kSecAttrApplicationTag as String: keyId.data(using: .utf8)!,
            kSecAttrKeyType as String: kSecAttrKeyTypeECSECPrimeRandom,
            kSecAttrTokenID as String: kSecAttrTokenIDSecureEnclave,
            kSecAttrKeyClass as String: kSecAttrKeyClassPrivate,
            kSecReturnRef as String: false,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        let status = SecItemCopyMatching(query as CFDictionary, nil)
        return status == errSecSuccess
    }
    
    
    @objc public func generate(keyId: String, requireBiometric: Bool = true, resolve: @escaping RCTPromiseResolveBlock, reject: @escaping RCTPromiseRejectBlock) {
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                let publicKey = try self.generateKeyPair(keyId: keyId, requireBiometric: requireBiometric)
                resolve(publicKey)
            } catch let error as SecureSignError {
                reject("\(error.errorCode)", nil, error)
            } catch {
                let unknownError = SecureSignError.unknownError(error)
                reject("\(unknownError.errorCode)", nil, unknownError)
            }
        }
    }
}
