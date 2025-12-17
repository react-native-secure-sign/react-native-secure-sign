//
//  SecureSignCheckHardwareSupport.swift
//
//  Created by Bartosz Dadok on 18/10/2025.
//

import Foundation
import LocalAuthentication
import Security
import React

extension SecureSignImpl {

    private enum HardwareSupportCache {
        static let supportKey = "secure_sign_hardware_support"
        static let osVersionKey = "secure_sign_os_version"
        static var cachedSupport: Bool?
    }

    @objc public func checkHardwareSupport(
        resolve: @escaping RCTPromiseResolveBlock,
        reject: @escaping RCTPromiseRejectBlock
    ) {
        if let cached = HardwareSupportCache.cachedSupport {
            resolve(cached)
            return
        }

        let defaults = UserDefaults.standard
        let currentOS = ProcessInfo.processInfo.operatingSystemVersionString
        let cachedOS = defaults.string(forKey: HardwareSupportCache.osVersionKey)

        if
            cachedOS == currentOS,
            let storedSupport = defaults.object(forKey: HardwareSupportCache.supportKey) as? Bool
        {
            HardwareSupportCache.cachedSupport = storedSupport
            resolve(storedSupport)
            return
        }


        let supported = checkSecureEnclaveSupport()

        defaults.set(supported, forKey: HardwareSupportCache.supportKey)
        defaults.set(currentOS, forKey: HardwareSupportCache.osVersionKey)
        HardwareSupportCache.cachedSupport = supported

        resolve(supported)
    }


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
    }
