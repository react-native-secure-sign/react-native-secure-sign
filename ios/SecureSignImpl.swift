//  SecureSignImpl.swift
//
//  Created by Bartosz Dadok on 18/10/2025.
//

import Foundation

@objc public class SecureSignImpl: NSObject {
    @objc public func generate(alias: String, requireBiometric: Bool = true) -> String {
        return "Generated"
    }
    @objc public func sign(alias: String, information: String) -> String {
        return "Signed"
    }
    @objc public func getPublicKey(alias: String) -> String {
        return "Public Key"
    }
    @objc public func removeKey(alias: String) -> Void {
        return Void()
    }
    @objc public func isSupported() -> Bool {
        return true
    }
}
