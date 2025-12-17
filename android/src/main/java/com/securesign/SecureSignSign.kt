package com.securesign

import androidx.fragment.app.FragmentActivity
import androidx.biometric.BiometricPrompt
import androidx.core.content.ContextCompat
import java.security.Signature
import java.security.SignatureException
import java.lang.IllegalArgumentException
import java.lang.RuntimeException
import java.lang.NullPointerException
import android.security.KeyStoreException

object SecureSignSign {
    private val secureSignImpl by lazy { SecureSignImpl() }
    
    fun sign(keyId: String, information: String): String {
        try {
            val dataToSign = SecureSignHelpers.base64UrlDecode(information)
            val privateKey = SecureSignHelpers.loadPrivateKeyFromKeystore(keyId)
        
            val derSignature = Signature.getInstance("SHA256withECDSA").apply {
                initSign(privateKey)
                update(dataToSign)
            }.sign()
    
            val p1363Signature = secureSignImpl.der_to_p1363(derSignature)
                ?: throw SecureSignError.SignatureConversionFailed

            return SecureSignHelpers.base64UrlEncode(p1363Signature)
        } catch (t: Throwable) { 
            throw (t as? SecureSignError) ?: SecureSignError.UnknownError(t) 
        }
    }


    fun signWithBiometric(
        activity: FragmentActivity,
        privateKey: java.security.PrivateKey,
        dataToSign: ByteArray,
        onSuccess: (String) -> Unit,
        onError: (Throwable) -> Unit
    ) {
        try {
            val signature = Signature.getInstance("SHA256withECDSA").apply {
                initSign(privateKey)
            }

            val promptInfo = BiometricPrompt.PromptInfo.Builder()
                .setTitle("SecureSign")
                .setSubtitle("Authenticate to sign")
                .setNegativeButtonText("Cancel")
                .build()

            val executor = ContextCompat.getMainExecutor(activity)

            val prompt = BiometricPrompt(
                activity,
                executor,
                object : BiometricPrompt.AuthenticationCallback() {

                    override fun onAuthenticationSucceeded(result: BiometricPrompt.AuthenticationResult) {
                        try {
                            val sig = result.cryptoObject?.signature
                                ?: throw RuntimeException("Missing cryptoObject.signature")

                            sig.update(dataToSign)
                            val der = sig.sign()

                            val p1363 = secureSignImpl.der_to_p1363(der)
                                ?: throw SecureSignError.SignatureConversionFailed

                            onSuccess(SecureSignHelpers.base64UrlEncode(p1363))
                        } catch (t: Throwable) {
                            onError(t)
                        }
                    }

                    override fun onAuthenticationError(code: Int, msg: CharSequence) {
                        val error = when (code) {
                            BiometricPrompt.ERROR_NEGATIVE_BUTTON,
                            BiometricPrompt.ERROR_USER_CANCELED,
                            BiometricPrompt.ERROR_CANCELED ->
                                SecureSignError.AuthenticationCancelled
                            BiometricPrompt.ERROR_LOCKOUT,
                            BiometricPrompt.ERROR_LOCKOUT_PERMANENT ->
                                SecureSignError.AuthenticationLockedOut
                            BiometricPrompt.ERROR_NO_BIOMETRICS,
                            BiometricPrompt.ERROR_HW_UNAVAILABLE,
                            BiometricPrompt.ERROR_HW_NOT_PRESENT ->
                                SecureSignError.AuthenticationUnavailable
                            else ->
                                SecureSignError.AuthenticationFailed
                        }
                        onError(error)
                    }

                    override fun onAuthenticationFailed() {
                    }
                }
            )

            prompt.authenticate(promptInfo, BiometricPrompt.CryptoObject(signature))
        } catch (t: Throwable) {
            onError(t)
        }
    }
}
