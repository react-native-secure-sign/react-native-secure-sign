# react-native-secure-sign

react-native-secure-sign lets you generates and use cryptographic signatures backed by hardware security on iOS and Android

## Installation

## Usage

### Methods

#### `generate(keyId: string, options?: { requireBiometric?: boolean }): Promise<string>`

Generates a new key pair in the Secure Enclave (iOS) or Hardware Security Module (Android).

**Parameters:**

- `keyId` (string): Unique identifier for the key
- `options` (object, optional):
  - `requireBiometric` (boolean, default: true): Require biometric authentication to use the key

**Returns:** Promise<string> - Base64url-encoded SPKI DER public key

**Example:**

```javascript
const publicKey = await generate('my-key', { requireBiometric: true });
```

#### `getPublicKey(keyId: string): Promise<string>`

Retrieves the public key for an existing key pair.

**Parameters:**

- `keyId` (string): Unique identifier for the key

**Returns:** Promise<string> - Base64url-encoded SPKI DER public key

**Example:**

```javascript
const publicKey = await getPublicKey('my-key');
```

#### `removeKey(keyId: string): Promise<void>`

Removes a key pair from the secure storage.

**Parameters:**

- `keyId` (string): Unique identifier for the key

**Example:**

```javascript
await removeKey('my-key');
```

#### `checkHardwareSupport(): Promise<boolean>`

Checks if the device supports hardware-backed secure storage.

**Returns:** Promise<boolean> - Whether hardware-backed security is supported

**Example:**

```javascript
const supported = await checkHardwareSupport();
```

#### `sign(keyId: string, information: string): Promise<string>`

Signs information using a private key stored in the hardware-backed secure storage.

**Parameters:**

- `keyId` (string): Unique identifier for the key
- `information` (Base64url string): Information to sign

**Returns:** Promise<string> - Base64url-encoded P1363 signature

## Error Codes

This library returns only error codes, not error messages. All error handling should be based on the numeric codes.

### Error Code Structure

Error codes are organized by category:

- **1001-1011**: Key generation and management errors
- **2001-2003**: Biometric authentication errors
- **3001**: Decode error
- **4001-4002**: Signature conversion errors
- **9999**: Unknown/unexpected errors

### Error Codes

#### Key Generation and Management (1001-1011)

| Code   | Description                         | Possible Causes                                                |
| ------ | ----------------------------------- | -------------------------------------------------------------- |
| `1001` | Key generation failed               | Secure Enclave error, insufficient permissions, hardware issue |
| `1002` | Public key extraction failed        | Key exists but public key cannot be extracted                  |
| `1003` | Access control creation failed      | Invalid biometric settings, system error                       |
| `1004` | Key deletion failed                 | Authentication error, invalid parameters                       |
| `1005` | Key not found                       | The specified key was not found in the Keychain                |
| `1006` | Invalid key ID                      | The provided key identifier is invalid or cannot be processed  |
| `1007` | Invalid key reference               | The retrieved key reference is not of the expected type        |
| `1008` | Authentication failed               | Biometric or passcode authentication failed for key access     |
| `1009` | Keychain query failed               | A general error occurred during a Keychain query operation     |
| `1010` | Public key format conversion failed | SEC1 to SPKI DER conversion failed (Rust FFI error)            |
| `1011` | Key already exists                  | Attempting to generate key with existing alias                 |

#### Biometric Authentication (2001-2003)

| Code   | Description                            | Possible Causes                                         |
| ------ | -------------------------------------- | ------------------------------------------------------- |
| `2001` | Biometric authentication not available | Device doesn't support biometrics, disabled in settings |
| `2002` | No biometric data enrolled             | User hasn't set up Touch ID/Face ID                     |
| `2003` | Biometric authentication locked out    | Too many failed biometric attempts                      |

### Decode Error

| Code   | Description  | Possible Causes        |
| ------ | ------------ | ---------------------- |
| `3001` | Decode error | Decode base64Url error |

#### Signature Conversion Errors (4001-4002)

| Code   | Description                 | Possible Causes                                 |
| ------ | --------------------------- | ----------------------------------------------- |
| `4001` | Invalid DER format          | DER signature format is invalid or corrupted    |
| `4002` | Signature conversion failed | Failed to convert DER signature to P1363 format |

#### Unknown Errors (9999)

| Code   | Description   | Possible Causes                              |
| ------ | ------------- | -------------------------------------------- |
| `9999` | Unknown error | Unexpected system error, unhandled exception |

### Usage in JavaScript

```javascript
// Example of usage
try {
  const result = await generate('my-key', { requireBiometric: true });
  console.log('Success:', result);
} catch (error) {
  console.log('Error Code:', error.code);
  switch (error.code) {
    case '1011':
      // Handle key already exists
      console.log('Key already exists');
      break;
    case '2001':
      // Handle biometric not available
      break;
    case '2002':
      // Handle biometric not enrolled
      break;
    case '2003':
      // Handle biometric locked out
      break;
    default:
      // Handle other errors
      break;
  }
}
```
