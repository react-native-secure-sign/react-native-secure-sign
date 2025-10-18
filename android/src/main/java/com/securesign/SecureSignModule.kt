package com.securesign

import com.facebook.react.bridge.Promise
import com.facebook.react.bridge.ReactApplicationContext
import com.facebook.react.bridge.ReadableMap
import com.facebook.react.module.annotations.ReactModule

@ReactModule(name = SecureSignModule.NAME)
class SecureSignModule(reactContext: ReactApplicationContext) :
  NativeSecureSignSpec(reactContext) {

  override fun getName(): String {
    return NAME
  }

  override fun generate(alias: String, options: ReadableMap?, promise: Promise) {
    val requireBiometric = options?.getBoolean(KEY_REQUIRE_BIOMETRIC) ?: true
    promise.resolve("Generated")
  }

  override fun sign(alias: String, information: String, promise: Promise) {
    promise.resolve("Signed")
  }

  override fun getPublicKey(alias: String, promise: Promise) {
    promise.resolve("Public Key")
  }

  override fun removeKey(alias: String, promise: Promise) {
    promise.resolve(null)
  }

  override fun isSupported(promise: Promise) {
    promise.resolve(true)
  }

  companion object {
    const val NAME = "SecureSign"
    const val KEY_REQUIRE_BIOMETRIC = "requireBiometric"
  }
}
