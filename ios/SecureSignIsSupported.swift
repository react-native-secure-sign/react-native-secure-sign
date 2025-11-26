//
//  SecureSignIsSupported.swift
//
//  Created by Bartosz Dadok on 18/10/2025.
//

import Foundation
import LocalAuthentication
import Security
import React

extension SecureSignImpl {

    private func checkSecureEnclaveSupport() -> Bool {
        #if targetEnvironment(simulator)
            return false
        #endif

        guard #available(iOS 10.0, *) else { return false }

        guard
            let access = SecAccessControlCreateWithFlags(
                nil,
                kSecAttrAccessibleWhenUnlockedThisDeviceOnly,
                [.privateKeyUsage],
                nil
            )
        else { return false }

        let attrs: [String: Any] = [
            kSecAttrKeyType as String: kSecAttrKeyTypeECSECPrimeRandom,
            kSecAttrKeySizeInBits as String: 256,
            kSecAttrTokenID as String: kSecAttrTokenIDSecureEnclave,
            kSecPrivateKeyAttrs as String: [
                kSecAttrIsPermanent as String: false,
                kSecAttrAccessControl as String: access,
            ],
        ]

        var cfErr: Unmanaged<CFError>?
        let key = SecKeyCreateRandomKey(attrs as CFDictionary, &cfErr)
        if key != nil { return true }

        if let nsErr = cfErr?.takeRetainedValue() as? NSError,
            nsErr.domain == NSOSStatusErrorDomain
        {
            let status: OSStatus = OSStatus(nsErr.code)
            if [errSecUnimplemented, errSecParam, errSecNotAvailable, errSecMissingEntitlement]
                .contains(status)
            {
                return false
            }
        }
        return false
    }

    @objc public func isSupported(
        resolve: @escaping RCTPromiseResolveBlock,
        reject: @escaping RCTPromiseRejectBlock
    ) {
        let supported = checkSecureEnclaveSupport()
        resolve(supported)
    }
}
