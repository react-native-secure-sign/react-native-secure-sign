package com.securesign

import java.security.KeyStore

object SecureSignGetPublicKey {
    
    fun getPublicKey(keyId: String): String {
        try {
            if (keyId.isBlank()) {
                throw SecureSignError.InvalidKeyId
            }

            val keyEntry = SecureSignHelpers.loadKeyEntryFromKeystore(keyId)
            
            val cert = keyEntry.certificate
                ?: throw SecureSignError.PublicKeyExtractionFailed

            val publicKey = cert.publicKey
                ?: throw SecureSignError.PublicKeyExtractionFailed

            val encoded = publicKey.encoded
            if (encoded.isEmpty()) {
                throw SecureSignError.PublicKeyFormatConversionFailed
            }

            return SecureSignHelpers.base64UrlEncode(encoded)
        } catch (e: Throwable) {
            throw (e as? SecureSignError) ?: SecureSignError.UnknownError(e)
        }
    }
}
