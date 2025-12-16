package com.securesign

import android.os.Build
import android.security.keystore.KeyGenParameterSpec
import android.security.keystore.KeyProperties
import android.util.Log
import java.security.KeyPairGenerator
import java.security.KeyStore
import java.security.spec.ECGenParameterSpec

object SecureSignGenerate {

    fun generateKey(keyId: String, requireUserAuthentication: Boolean): String {
        try {
            if (keyId.isBlank()) throw SecureSignError.InvalidKeyId
            if (keyExists(keyId)) throw SecureSignError.KeyAlreadyExists

            generateKeyPair(keyId, requireUserAuthentication)

            return SecureSignGetPublicKey.getPublicKey(keyId)

        } catch (e: SecureSignError) {
            throw e
        } catch (e: Throwable) {
            throw SecureSignError.UnknownError(e)
        }
    }

    private fun keyExists(keyId: String): Boolean {
        val ks = KeyStore.getInstance("AndroidKeyStore").apply { load(null) }
        return ks.containsAlias(keyId)
    }

    private fun generateKeyPair(keyId: String, requireUserAuthentication: Boolean) {
        fun buildSpec(useStrongBox: Boolean): KeyGenParameterSpec {
            val builder = KeyGenParameterSpec.Builder(
                keyId,
                KeyProperties.PURPOSE_SIGN 
            )
                .setAlgorithmParameterSpec(ECGenParameterSpec("secp256r1"))
                .setDigests(KeyProperties.DIGEST_SHA256)

            if (requireUserAuthentication) {
                builder.setUserAuthenticationRequired(true)

                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
                    builder.setUserAuthenticationParameters(
                        0,
                        KeyProperties.AUTH_BIOMETRIC_STRONG
                    )
                } else if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
                    builder.setUserAuthenticationValidityDurationSeconds(-1)
                    builder.setInvalidatedByBiometricEnrollment(true)
                } else {
                    builder.setUserAuthenticationValidityDurationSeconds(-1)
                }
            }

            if (useStrongBox && Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
                builder.setIsStrongBoxBacked(true)
            }

            return builder.build()
        }

        try {
            val kpg = KeyPairGenerator.getInstance(
                KeyProperties.KEY_ALGORITHM_EC,
                "AndroidKeyStore"
            )
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
                try {
                    kpg.initialize(buildSpec(useStrongBox = true))
                    kpg.generateKeyPair()
                    return
                } catch (e: Exception) {
                    Log.w("SecureSign", "StrongBox unavailable/unsupported, fallback to TEE", e)
                }
            }

            kpg.initialize(buildSpec(useStrongBox = false))
            kpg.generateKeyPair()

        } catch (e: Exception) {
            throw SecureSignError.KeyGenerationFailed(e)
        }
    }

}
