package com.securesign

class SecureSignImpl {
    init {
        System.loadLibrary("secure_sign_rust")
    }
    
    external fun add(left: Long, right: Long): Long
}