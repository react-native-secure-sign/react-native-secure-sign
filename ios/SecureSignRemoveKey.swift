//
//  SecureSignRemoveKey.swift
//
//  Created by Bartosz Dadok on 18/10/2025.
//

import Foundation
import Security
import React

extension SecureSignImpl {
    
    private func deleteKeyFromKeychain(keyId: String) throws {
        let tag = keyId.data(using: .utf8)!
        let query: [String: Any] = [
            kSecClass as String: kSecClassKey,
            kSecAttrApplicationTag as String: tag,
            kSecAttrKeyType as String: kSecAttrKeyTypeECSECPrimeRandom,
            kSecAttrKeyClass as String: kSecAttrKeyClassPrivate
        ]
        
        let status = SecItemDelete(query as CFDictionary)
        
        switch status {
        case errSecSuccess:
            break
        case errSecItemNotFound:
            throw SecureSignError.keyNotFound
        default:
            throw SecureSignError.keyDeletionFailed(status) 
        }
    }
    
    @objc public func removeKey(keyId: String, resolve: @escaping RCTPromiseResolveBlock, reject: @escaping RCTPromiseRejectBlock) {
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try self.deleteKeyFromKeychain(keyId: keyId)
                resolve(nil)
            } catch let error as SecureSignError {
                reject("\(error.errorCode)", nil, error)
            } catch {
                let unknownError = SecureSignError.unknownError(error)
                reject("\(unknownError.errorCode)", nil, unknownError)
            }
        }
    }
}
