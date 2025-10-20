//  SecureSignImpl.swift
//
//  Created by Bartosz Dadok on 18/10/2025.
//

import Foundation
import SecureSignRust

@objc public class SecureSignImpl: NSObject {
    @objc public func generate(alias: String, requireBiometric: Bool = true) -> String {
       // Rust test function call
       let result = der_to_p1363(10, 20)
       return String(result)
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
