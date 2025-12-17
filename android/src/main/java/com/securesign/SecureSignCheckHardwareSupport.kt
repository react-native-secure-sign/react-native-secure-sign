package com.securesign
import android.content.Context
import android.os.Build
import android.security.keystore.KeyGenParameterSpec
import android.security.keystore.KeyInfo
import android.security.keystore.KeyProperties
import java.security.KeyFactory
import java.security.KeyPairGenerator
import java.security.KeyStore
import java.security.spec.ECGenParameterSpec

object SecureSignSupport {

    private const val PREFS_NAME = "securesign_prefs"
    private const val KEY_HARDWARE_SUPPORT = "secure_sign_hardware_support"
    private const val KEY_SDK_VERSION = "secure_sign_sdk_version"

    @Volatile
    private var cachedSupport: Boolean? = null

    fun checkHardwareSupport(context: Context): Boolean {
        cachedSupport?.let { return it }

        val prefs = context.applicationContext
            .getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)

        val cachedValue = prefs.getBoolean(KEY_HARDWARE_SUPPORT, false)
        val cachedSdk = prefs.getInt(KEY_SDK_VERSION, -1)

        if (cachedSdk == Build.VERSION.SDK_INT && prefs.contains(KEY_HARDWARE_SUPPORT)) {
            cachedSupport = cachedValue
            return cachedValue
        }

        val result =
            isStrongBoxBackedEcSigningSupported() ||
            isHardwareBackedEcSigningSupported()

        prefs.edit()
            .putBoolean(KEY_HARDWARE_SUPPORT, result)
            .putInt(KEY_SDK_VERSION, Build.VERSION.SDK_INT)
            .apply()

        cachedSupport = result
        return result
    }

    private fun isHardwareBackedEcSigningSupported(): Boolean {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.M) return false
        return generateTestKey(isStrongBox = false)
    }

    private fun isStrongBoxBackedEcSigningSupported(): Boolean {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.P) return false
        return generateTestKey(isStrongBox = true)
    }

    private fun generateTestKey(isStrongBox: Boolean): Boolean {
        val testAlias = "securesign_test_${System.currentTimeMillis()}"

        return try {
            val kpg = KeyPairGenerator.getInstance(
                KeyProperties.KEY_ALGORITHM_EC,
                "AndroidKeyStore"
            )

            val builder = KeyGenParameterSpec.Builder(
                testAlias,
                KeyProperties.PURPOSE_SIGN or KeyProperties.PURPOSE_VERIFY
            )
                .setAlgorithmParameterSpec(ECGenParameterSpec("secp256r1"))
                .setDigests(KeyProperties.DIGEST_SHA256)
                .setUserAuthenticationRequired(false)

            if (isStrongBox && Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
                builder.setIsStrongBoxBacked(true)
            }

            kpg.initialize(builder.build())
            val keyPair = kpg.generateKeyPair()

            val privateKey = keyPair.private
            val keyFactory = KeyFactory.getInstance(privateKey.algorithm, "AndroidKeyStore")
            val keyInfo = keyFactory.getKeySpec(privateKey, KeyInfo::class.java) as KeyInfo

            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                when (keyInfo.securityLevel) {
                    KeyProperties.SECURITY_LEVEL_TRUSTED_ENVIRONMENT,
                    KeyProperties.SECURITY_LEVEL_STRONGBOX -> true
                    else -> false
                }
            } else {
                @Suppress("DEPRECATION")
                keyInfo.isInsideSecureHardware
            }
        } catch (e: Exception) {
            false
        } finally {
            cleanupTestKey(testAlias)
        }
    }

    private fun cleanupTestKey(alias: String) {
        try {
            val keyStore = 
            KeyStore.getInstance("AndroidKeyStore")
            keyStore.load(null)
            if (keyStore.containsAlias(alias)) {
                keyStore.deleteEntry(alias)
            }
        } catch (_: Exception) {

        }
    }
}
