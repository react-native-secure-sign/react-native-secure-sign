//
//  SecureSignSign.swift
//
//  Created by Bartosz Dadok on 18/10/2025.
//

import Foundation
import Security
import React

extension SecureSignImpl {
    
    private static let localizedReason = "Authenticate to sign the challenge"
    
    @objc public func sign(keyId: String, information: String, resolve: @escaping RCTPromiseResolveBlock, reject: @escaping RCTPromiseRejectBlock) {
        
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                let canonicalData = try self.canonicalizeChallenge(jsonString: information)
                let privateKey = try self.loadKeyFromKeychain(
                    keyId: keyId,
                    prompt: Self.localizedReason
                )
                
                let algorithm = SecKeyAlgorithm.ecdsaSignatureMessageX962SHA256
                guard SecKeyIsAlgorithmSupported(privateKey, .sign, algorithm) else {
                    throw SecureSignError.unknownError(NSError(domain: "SecureSign", code: 5001, userInfo: [NSLocalizedDescriptionKey: "Algorithm not supported"]))
                }
                
                var error: Unmanaged<CFError>?
                guard let derSignature = SecKeyCreateSignature(privateKey, algorithm, canonicalData as CFData, &error) as Data? else {
                    if let cfError = error?.takeRetainedValue() {
                        throw SecureSignError.unknownError(cfError as Error)
                    }
                    throw SecureSignError.authenticationFailed
                }
                let p1363Signature = try self.convertDerToP1363(derSignature: derSignature)
                let signatureBase64url = self.base64urlEncode(p1363Signature)
                resolve(signatureBase64url)
            } catch let error as SecureSignError {
                reject("\(error.errorCode)", nil, error)
            } catch {
                let unknownError = SecureSignError.unknownError(error)
                reject("\(unknownError.errorCode)", nil, unknownError)
            }
        }
    }
}
