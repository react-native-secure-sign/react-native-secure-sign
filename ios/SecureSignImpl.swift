//  SecureSignImpl.swift
//
//  Created by Bartosz Dadok on 18/10/2025.
//

import Foundation

// Import Rust library
@_silgen_name("add")
func add(_ left: UInt64, _ right: UInt64) -> UInt64

@objc public class SecureSignImpl: NSObject {
    @objc public func generate(alias: String, requireBiometric: Bool = true) -> String {
        // Example usage of Rust function
        let result = add(7, 8)
        return "Generated with Rust: \(result)"
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
