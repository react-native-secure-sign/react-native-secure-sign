//
//  SecureSignSign.swift
//
//  Created by Bartosz Dadok on 18/10/2025.
//

import Foundation
import React

extension SecureSignImpl {
    @objc public func sign(keyId: String, information: String, resolve: @escaping RCTPromiseResolveBlock, reject: @escaping RCTPromiseRejectBlock) {
        // TODO: Implement actual signing logic
        resolve("Signed")
    }
}
