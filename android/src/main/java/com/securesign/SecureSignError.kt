package com.securesign

//  Error Codes Documentation:
//  Key Management Errors (1001-1011):
//  1001 - Key generation failed (Secure Enclave / Keystore error)
//  1002 - Public key extraction failed
//  1004 - Key deletion failed
//  1005 - Key not found
//  1006 - Invalid key ID (cannot convert to data / invalid alias)
//  1008 - Authentication failed (biometric/passcode required)
//  1010 - Public key format conversion failed (SEC1 to SPKI / SPKI issues)
//  1011 - Key already exists
//  1012 - Key info extraction failed (cannot retrieve key properties from KeyStore)
//
//  Biometric Errors (2001-2004):
//  2001 - Biometric authentication not available
//  2003 - Biometric authentication locked out
//  2004 - Authentication cancelled
//
//  General Errors (9999):
//  9999 - Unknown error (catch-all for unexpected errors)

sealed class SecureSignError(
    val errorCode: Int,
    message: String,
    cause: Throwable? = null
) : Exception(message, cause) {

    class KeyGenerationFailed(cause: Throwable?) :
        SecureSignError(1001, "Key generation failed (Secure Enclave / Keystore error)", cause)

    object PublicKeyExtractionFailed :
        SecureSignError(1002, "Public key extraction failed")

    object KeyDeletionFailed :
        SecureSignError(1004, "Key deletion failed")

    object KeyNotFound :
        SecureSignError(1005, "Key not found")

    object InvalidKeyId :
        SecureSignError(1006, "Invalid key ID")

    object AuthenticationFailed :
        SecureSignError(1008, "Authentication failed")

    object PublicKeyFormatConversionFailed :
        SecureSignError(1010, "Public key format conversion failed (SEC1 to SPKI / SPKI invalid)")

    object KeyAlreadyExists :
        SecureSignError(1011, "Key already exists")

    class KeyInfoExtractionFailed(cause: Throwable?) :
        SecureSignError(1012, "Key info extraction failed (cannot retrieve key properties from KeyStore)", cause)

    object AuthenticationLockedOut :
        SecureSignError(2003, "Biometric locked out")

    object AuthenticationUnavailable :
        SecureSignError(2001, "Biometric unavailable")
    
    object AuthenticationCancelled :
        SecureSignError(2004, "Authentication cancelled")

    object InvalidInput :
        SecureSignError(3001, "Invalid input")

    object SignatureConversionFailed :
        SecureSignError(4002, "Signature conversion failed")

    object AlgorithmNotSupported :
        SecureSignError(5001, "Algorithm not supported")

    object NoActivity :
        SecureSignError(5002, "No activity available")

    class UnknownError(cause: Throwable) :
        SecureSignError(9999, "Unknown error", cause)
}
