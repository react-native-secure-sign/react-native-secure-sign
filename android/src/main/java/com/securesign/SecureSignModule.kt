package com.securesign

import android.util.Log
import com.facebook.react.bridge.Promise
import com.facebook.react.bridge.ReactApplicationContext
import com.facebook.react.bridge.ReadableMap
import com.facebook.react.module.annotations.ReactModule
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext

@ReactModule(name = SecureSignModule.NAME)
class SecureSignModule(reactContext: ReactApplicationContext) :
  NativeSecureSignSpec(reactContext) {

  private val secureSignImpl = SecureSignImpl()

  override fun getName(): String {
    return NAME
  }

  override fun generate(keyId: String, options: ReadableMap?, promise: Promise) {
    val requireBiometric = options?.getBoolean(KEY_REQUIRE_BIOMETRIC) ?: true
    try {
      val publicKeyBase64 = SecureSignGenerate.generateKey(keyId, requireBiometric)
      promise.resolve(publicKeyBase64)
    } catch (e: Exception) {
      Log.e(NAME, "Error in generate: ${e.message}", e)
      promise.reject("1001", e.message, e)
    }
  }

  override fun sign(keyId: String, information: String, promise: Promise) {
    promise.resolve("Signed")
  }

  override fun getPublicKey(keyId: String, promise: Promise) {
    promise.resolve("Public Key")
  }

  override fun removeKey(keyId: String, promise: Promise) {
    promise.resolve(null)
  }

  override fun checkHardwareSupport(promise: Promise) {
    CoroutineScope(Dispatchers.Default).launch {
      val supported = try {
        SecureSignSupport.checkHardwareSupport(reactApplicationContext)
      } catch (e: Exception) {
        false
      }
      withContext(Dispatchers.Main) {
        promise.resolve(supported)
      }
    }
  }

  companion object {
    const val NAME = "SecureSign"
    const val KEY_REQUIRE_BIOMETRIC = "requireBiometric"
  }
}
