//  SecureSignImpl.swift
//
//  Created by Bartosz Dadok on 18/10/2025.
//

import Foundation
import SecureSignRust

@objc public class SecureSignImpl: NSObject {
    @objc public func generate(keyId: String, requireBiometric: Bool = true) -> String {
       // Rust test function call
       let result = der_to_p1363(10, 20)
       return String(result)
    }
    @objc public func sign(keyId: String, information: String) -> String {
        return "Signed"
    }
    @objc public func getPublicKey(keyId: String) -> String {
        return "Public Key"
    }
    @objc public func removeKey(keyId: String) -> Void {
        return Void()
    }
    @objc public func isSupported() -> Bool {
        return true
    }
}
