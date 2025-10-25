# react-native-secure-sign

react-native-secure-sign lets you generates and use cryptographic signatures backed by hardware security on iOS and Android

## Installation

## Usage

## Error Codes

This library returns only error codes, not error messages. All error handling should be based on the numeric codes.

### Error Code Structure

Error codes are organized by category:
- **1000-1999**: Key generation and management errors
- **2000-2999**: Biometric authentication errors  
- **3000-3999**: Key existence and validation errors
- **9999**: Unknown/unexpected errors

### Error Codes

#### Key Generation and Management (1000-1999)

| Code | Description | Possible Causes |
|------|-------------|----------------|
| `1001` | Key generation failed | Secure Enclave error, insufficient permissions, hardware issue |
| `1002` | Public key extraction failed | Key exists but public key cannot be extracted |
| `1003` | Access control creation failed | Invalid biometric settings, system error |
| `1004` | Key deletion failed | Authentication error, invalid parameters |
| `1005` | Key not found | The specified key was not found in the Keychain |
| `1006` | Invalid key ID | The provided key identifier is invalid or cannot be processed |
| `1007` | Invalid key reference | The retrieved key reference is not of the expected type |
| `1008` | Authentication failed | Biometric or passcode authentication failed for key access |
| `1009` | Keychain query failed | A general error occurred during a Keychain query operation |
| `1010` | Public key format conversion failed | SEC1 to SPKI DER conversion failed (Rust FFI error) |

#### Biometric Authentication (2000-2999)

| Code | Description | Possible Causes |
|------|-------------|----------------|
| `2001` | Biometric authentication not available | Device doesn't support biometrics, disabled in settings |
| `2002` | No biometric data enrolled | User hasn't set up Touch ID/Face ID |
| `2003` | Biometric authentication locked out | Too many failed biometric attempts |

#### Key Validation (3000-3999)

| Code | Description | Possible Causes |
|------|-------------|----------------|
| `3001` | Key already exists | Attempting to generate key with existing alias |

#### Unknown Errors (9999)

| Code | Description | Possible Causes |
|------|-------------|----------------|
| `9999` | Unknown error | Unexpected system error, unhandled exception |

### Usage in JavaScript

```javascript
// Generate key
try {
  const result = await generate('my-key', { requireBiometric: true });
  console.log('Success:', result);
} catch (error) {
  console.log('Error Code:', error.code);
  
  switch (error.code) {
    case '2001':
      // Handle biometric not available
      break;
    case '2002':
      // Handle biometric not enrolled
      break;
    case '2003':
      // Handle biometric locked out
      break;
    case '3001':
      // Handle key already exists
      break;
    default:
      // Handle other errors
      break;
  }
}

// Remove key
try {
  await removeKey('my-key');
  console.log('Key removed successfully');
} catch (error) {
  console.log('Error Code:', error.code);
  
  switch (error.code) {
    case '1005':
      // Handle key not found
      console.log('Key does not exist');
      break;
    case '1004':
      // Handle deletion failed
      console.log('Failed to delete key');
      break;
    default:
      // Handle other errors
      break;
  }
}
```

## License

MIT

---

Made with [create-react-native-library](https://github.com/callstack/react-native-builder-bob)
