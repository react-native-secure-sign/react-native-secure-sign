package com.securesign

import androidx.fragment.app.FragmentActivity
import com.facebook.react.bridge.Promise
import com.facebook.react.bridge.ReactApplicationContext
import com.facebook.react.bridge.ReadableMap
import com.facebook.react.module.annotations.ReactModule
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.cancel
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext

@ReactModule(name = SecureSignModule.NAME)
class SecureSignModule(reactContext: ReactApplicationContext) :
  NativeSecureSignSpec(reactContext) {

  private val scope = CoroutineScope(SupervisorJob() + Dispatchers.Default)

  override fun invalidate() {
    super.invalidate()
    scope.cancel()
  }

  override fun getName(): String = NAME

  override fun generate(keyId: String, options: ReadableMap?, promise: Promise) {
    val requireUserAuthentication = options?.getBoolean(KEY_REQUIRE_BIOMETRIC) ?: true

    scope.launch {
      try {
        val publicKeyBase64 = SecureSignGenerate.generateKey(keyId, requireUserAuthentication)
        withContext(Dispatchers.Main) {
          promise.resolve(publicKeyBase64)
        }
      } catch (e: SecureSignError) {
        withContext(Dispatchers.Main) {
          promise.reject(e.errorCode.toString(), e.message, e)
        }
      } catch (e: Throwable) {
        val err = SecureSignError.UnknownError(e)
        withContext(Dispatchers.Main) {
          promise.reject(err.errorCode.toString(), err.message, err)
        }
      }
    }
  }

  override fun getPublicKey(keyId: String, promise: Promise) {
    scope.launch {
      try {
        val publicKeyBase64 = SecureSignGetPublicKey.getPublicKey(keyId)
        withContext(Dispatchers.Main) {
          promise.resolve(publicKeyBase64)
        }
      } catch (e: SecureSignError) {
        withContext(Dispatchers.Main) {
          promise.reject(e.errorCode.toString(), e.message, e)
        }
      } catch (e: Throwable) {
        val err = SecureSignError.UnknownError(e)
        withContext(Dispatchers.Main) {
          promise.reject(err.errorCode.toString(), err.message, err)
        }
      }
    }
  }

  override fun removeKey(keyId: String, promise: Promise) {
    scope.launch {
      try {
        SecureSignRemoveKey.removeKey(keyId)
        withContext(Dispatchers.Main) {
          promise.resolve(null)
        }
      } catch (e: SecureSignError) {
        withContext(Dispatchers.Main) {
          promise.reject(e.errorCode.toString(), e.message, e)
        }
      } catch (e: Throwable) {
        val err = SecureSignError.UnknownError(e)
        withContext(Dispatchers.Main) {
          promise.reject(err.errorCode.toString(), err.message, err)
        }
      }
    }
  }
  
  override fun sign(keyId: String, information: String, promise: Promise) {
    scope.launch {
      try {
        val dataToSign = SecureSignHelpers.base64UrlDecode(information)
        val privateKey = SecureSignHelpers.loadPrivateKeyFromKeystore(keyId)

        val requiresAuth = SecureSignHelpers.isUserAuthRequired(privateKey)

        if (!requiresAuth) {
          val signature = SecureSignSign.sign(keyId, information)
          withContext(Dispatchers.Main) { promise.resolve(signature) }
          return@launch
        }

        withContext(Dispatchers.Main) {
          val activity = currentActivity as? FragmentActivity
          if (activity == null) {
            val err = SecureSignError.NoActivity
            promise.reject(err.errorCode.toString(), err.message, err)
            return@withContext
          }

          SecureSignSign.signWithBiometric(
            activity = activity,
            privateKey = privateKey,
            dataToSign = dataToSign,
            onSuccess = { result: String ->
              promise.resolve(result)
            },
            onError = { t: Throwable ->
              val err = (t as? SecureSignError) ?: SecureSignError.UnknownError(t)
              promise.reject(err.errorCode.toString(), err.message, err)
            }
          )
        }
      } catch (t: Throwable) {
        val err = (t as? SecureSignError) ?: SecureSignError.UnknownError(t)
        withContext(Dispatchers.Main) {
          promise.reject(err.errorCode.toString(), err.message, err)
        }
      }
    }
  }

  override fun checkHardwareSupport(promise: Promise) {
    scope.launch {
      val supported = try {
        SecureSignSupport.checkHardwareSupport(reactApplicationContext)
      } catch (_: Exception) {
        false
      }
      withContext(Dispatchers.Main) {
        promise.resolve(supported)
      }
    }
  }

  companion object {
    const val NAME = "SecureSign"
    const val KEY_REQUIRE_BIOMETRIC = "requireUserAuthentication"
  }
}
