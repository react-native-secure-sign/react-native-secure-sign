package com.securesign

import java.security.KeyStore

object SecureSignRemoveKey {

    fun removeKey(keyId: String) {
        try {
            if (keyId.isBlank()) {
                throw SecureSignError.InvalidKeyId
            }

            val keyStore = KeyStore.getInstance("AndroidKeyStore").apply { load(null) }

            if (!keyStore.containsAlias(keyId)) {
                throw SecureSignError.KeyNotFound
            }

            keyStore.deleteEntry(keyId)

        } catch (e: SecureSignError) {
            throw e
        } catch (e: Throwable) {
            throw SecureSignError.KeyDeletionFailed
        }
    }
}
