package com.securesign

import android.os.Build
import android.security.keystore.KeyInfo
import java.security.KeyFactory
import java.security.KeyStore
import java.security.PrivateKey

object SecureSignHelpers {

    fun base64UrlEncode(bytes: ByteArray): String {
        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            java.util.Base64.getUrlEncoder()
                .withoutPadding()
                .encodeToString(bytes)
        } else {
            android.util.Base64.encodeToString(
                bytes,
                android.util.Base64.NO_PADDING or android.util.Base64.NO_WRAP
            )
                .replace('+', '-')
                .replace('/', '_')
        }
    }


    private fun base64UrlToBase64(base64Url: String): String {
        val normalized = base64Url
            .replace('-', '+')
            .replace('_', '/')

        val remainder = normalized.length % 4
        return if (remainder == 0) {
            normalized
        } else {
            normalized + "=".repeat(4 - remainder)
        }
    }

    fun base64UrlDecode(base64Url: String): ByteArray {
        val base64 = base64UrlToBase64(base64Url)

        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            java.util.Base64.getDecoder().decode(base64)
        } else {
            android.util.Base64.decode(base64, android.util.Base64.NO_WRAP)
        }
    }

    fun loadKeyEntryFromKeystore(keyId: String): KeyStore.PrivateKeyEntry {
        val keyStore = KeyStore.getInstance("AndroidKeyStore").apply {
            load(null)
        }

        val entry = keyStore.getEntry(keyId, null)
            ?: throw SecureSignError.KeyNotFound

        if (entry !is KeyStore.PrivateKeyEntry) {
            throw SecureSignError.KeyNotFound
        }

        return entry
    }

    fun loadPrivateKeyFromKeystore(keyId: String): PrivateKey {
        return loadKeyEntryFromKeystore(keyId).privateKey
    }

    fun isUserAuthRequired(privateKey: PrivateKey): Boolean {
        return try {
            val kf = KeyFactory.getInstance(privateKey.algorithm, "AndroidKeyStore")
            val keyInfo = kf.getKeySpec(privateKey, KeyInfo::class.java) as KeyInfo
            keyInfo.isUserAuthenticationRequired
        } catch (e: Throwable) {
            throw SecureSignError.KeyInfoExtractionFailed(e)
        }
    }
}
