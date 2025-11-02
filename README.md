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

#### `isSupported(): Promise<boolean>`

Checks if the device supports hardware-backed secure storage (Secure Enclave on iOS, HSM on Android).

**Returns:** Promise<boolean> - Whether hardware-backed security is supported

**Example:**
```javascript
const supported = await isSupported();
```

#### `sign(keyId: string, information: string): Promise<string>`

Signs data using a private key stored in the hardware-backed secure storage.

**Parameters:**
- `keyId` (string): Unique identifier for the key
- `challenge` (string): Data to sign

**Returns:** Promise<string> - Base64url-encoded P1363 signature


The challenge has to be in the right format, since the SDK validates them and canonicalizes them
- `ver` - required, version has to be `S1` 
- `alg` - required, SKD will sign the challenge with that algorithm, for now supports only `ES256`
- `sigFormat` - required, the signature format, for now supports only `P1363`
- `exp` - required, has to be bigger than timestamp `ts`
- `kid` - 
**Challenge JSON Format:**
```json
{
  "ver": "S1",
  "alg": "ES256",
  "sigFormat": "P1363",
  "kid": "key-identifier",
  "aud": "audience",
  "nonce": "random-nonce",
  "ts": 1234567890,
  "exp": 1234567900,
  "method": "GET",
  "path": "/api/resource",
  "query": "param=value",
  "bodyHash": "optional-body-hash",
  "challengeId": "optional-challenge-id"
}
```





## Error Codes

This library returns only error codes, not error messages. All error handling should be based on the numeric codes.

### Error Code Structure

Error codes are organized by category:
- **1001-1011**: Key generation and management errors
- **2001-2003**: Biometric authentication errors  
- **3001-3009**: Challenge validation errors
- **9999**: Unknown/unexpected errors

### Error Codes

#### Key Generation and Management (1001-1011)

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
| `1011` | Key already exists | Attempting to generate key with existing alias |

#### Biometric Authentication (2001-2003)

| Code | Description | Possible Causes |
|------|-------------|----------------|
| `2001` | Biometric authentication not available | Device doesn't support biometrics, disabled in settings |
| `2002` | No biometric data enrolled | User hasn't set up Touch ID/Face ID |
| `2003` | Biometric authentication locked out | Too many failed biometric attempts |

#### Challenge Validation (3001-3009)

| Code | Description | Possible Causes |
|------|-------------|----------------|
| `3001` | Invalid input | Null pointer or empty data provided |
| `3002` | Invalid version | Challenge version must be "SS1" |
| `3003` | Invalid algorithm | Algorithm must be "ES256" |
| `3004` | Invalid signature format | Signature format must be "P1363" |
| `3005` | Invalid expiration | Expiration time must be after timestamp |
| `3006` | Forbidden characters | String contains forbidden characters (| or \0) |
| `3007` | JSON parse error | Invalid JSON format provided |
| `3008` | UTF8 error | Invalid UTF-8 encoding |
| `3009` | C string conversion error | Failed to convert to C string format |

#### Unknown Errors (9999)

| Code | Description | Possible Causes |
|------|-------------|----------------|
| `9999` | Unknown error | Unexpected system error, unhandled exception |

### Usage in JavaScript

```javascript

// Example 
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


## License

MIT

---

Made with [create-react-native-library](https://github.com/callstack/react-native-builder-bob)