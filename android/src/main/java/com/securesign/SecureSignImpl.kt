package com.securesign

class SecureSignImpl {
    init {
        System.loadLibrary("secure_sign_rust")
    }
    
    external fun der_to_p1363(derSignature: ByteArray): ByteArray?
}