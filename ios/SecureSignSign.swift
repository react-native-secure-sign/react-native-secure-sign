//
//  SecureSignSign.swift
//
//  Created by Bartosz Dadok on 18/10/2025.
//

import Foundation
import Security
import LocalAuthentication
import React

extension SecureSignImpl {
    
    private func mapCFErrorToSecureSignError(_ cfError: CFError) -> SecureSignError {
        let ns = cfError as Error as NSError
        
        if ns.domain == LAError.errorDomain {
            let laError = LAError(_nsError: ns)
            switch laError.code {
            case .userCancel, .appCancel, .systemCancel:
                return .authenticationFailed
            case .biometryNotAvailable:
                return .biometricNotAvailable
            case .biometryNotEnrolled:
                return .biometricNotEnrolled
            case .biometryLockout:
                return .biometricLockout
            default:
                return .authenticationFailed
            }
        }
        
        if ns.domain == NSOSStatusErrorDomain {
            switch OSStatus(ns.code) {
            case errSecAuthFailed, errSecInteractionNotAllowed:
                return .authenticationFailed
            case errSecItemNotFound:
                return .keyNotFound
            default:
                return .unknownError(ns)
            }
        }
        
        return .unknownError(ns)
    }
    
    @objc public func sign(keyId: String, information: String, resolve: @escaping RCTPromiseResolveBlock, reject: @escaping RCTPromiseRejectBlock) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            do {
                let dataToSign = try self.base64urlDecode(information)
                
                let privateKey = try self.loadKeyFromKeychain(keyId: keyId)
                
                let algorithm = SecKeyAlgorithm.ecdsaSignatureMessageX962SHA256
                guard SecKeyIsAlgorithmSupported(privateKey, .sign, algorithm) else {
                    throw SecureSignError.algorithmNotSupported
                }
        
                var error: Unmanaged<CFError>?
                guard let derSignature = SecKeyCreateSignature(privateKey, algorithm, dataToSign as CFData, &error) as Data? else {
                    if let cfError = error?.takeRetainedValue() {
                        throw self.mapCFErrorToSecureSignError(cfError)
                    }
                    throw SecureSignError.authenticationFailed
                }
                
                let p1363 = try self.convertDerToP1363(derSignature: derSignature)
                let sig = self.base64urlEncode(p1363)
                resolve(sig)
                
            } catch let error as SecureSignError {
                reject("\(error.errorCode)", nil, error)
            } catch {
                let unknownError = SecureSignError.unknownError(error)
                reject("\(unknownError.errorCode)", nil, unknownError)
            }
        }
    }
}
