<p align="center">
  <img
    width="50"
    height="50"
    alt="react-native-secure-sign"
    src="https://github.com/user-attachments/assets/c7fca763-5ddc-4257-a959-6077a21e68ee"
  />
</p>

# react-native-secure-sign


### `react-native-secure-sign` provides a cross-platform API to generate and use non-exportable ECDSA keys stored in Android Keystore and iOS Secure Enclave, with optional biometric authentication for every signing operation.

## Installation

> **Important:** This library requires React Native's New Architecture (Fabric + TurboModules) to be enabled. The legacy architecture is not supported.

```bash
npm install react-native-secure-sign
# or
yarn add react-native-secure-sign
```

### React Native CLI

#### iOS
1. If you generate key with `requireUserAuthentication` set to true you need to add Face ID usage description to your `ios/YourApp/Info.plist`:

```xml
<key>NSFaceIDUsageDescription</key>
<string>This app uses Face ID / Touch ID to securely authenticate key operations in the Secure Enclave.</string>
```

This permission is required for biometric authentication when using the Secure Enclave on iOS.

### Expo (Bare Workflow)
This library supports **Expo bare workflow** (projects created with `expo prebuild`) and builds created with `expo-dev-client`. However, The app won't work with Expo Go.

#### iOS
1. If you generate key with `requireUserAuthentication` then add Face ID usage description in your `app.json` or `app.config.js`:
```json
{
  "expo": {
    "ios": {
      "infoPlist": {
        "NSFaceIDUsageDescription": "This app uses Face ID / Touch ID to securely authenticate key operations in the Secure Enclave."
      }
    }
  }
}
```

### Device Requirements

**Note:** The library requires devices with hardware-backed keystore support (most modern Android devices) and Secure Enclave support (iOS devices with Touch ID/Face ID). Use `checkHardwareSupport()` to verify device compatibility.

## Usage

### Methods

#### `generate(keyId: string, options?: { requireUserAuthentication?: boolean }): Promise<string>`

Generates a new key pair in the Secure Enclave (iOS) or Hardware Security Module (Android).

**Parameters:**

- `keyId` (string): Unique identifier for the key
- `options` (object, optional):
  - `requireUserAuthentication` (boolean, default: true): Require biometric authentication to use the key

**Returns:** Promise<string> - Base64url-encoded SPKI DER public key

**Example:**

```javascript
const publicKey = await generate('my-key', { requireUserAuthentication: true });
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

- **1001-1012**: Key generation and management errors
- **2001-2004**: Biometric authentication errors
- **3001**: Decode error
- **4001-4002**: Signature conversion errors
- **9999**: Unknown/unexpected errors

### Error Codes

#### Key Generation and Management (1001-1012)

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
| `1012` | Key info extraction failed (Android) | Cannot retrieve key properties from KeyStore                   |

#### Biometric Authentication (2001-2004)

| Code   | Description                            | Possible Causes                                         |
| ------ | -------------------------------------- | ------------------------------------------------------- |
| `2001` | Biometric authentication not available | Device doesn't support biometrics, disabled in settings |
| `2002` | No biometric data enrolled             | User hasn't set up Touch ID/Face ID                     |
| `2003` | Biometric authentication locked out    | Too many failed biometric attempts                      |
| `2004` | Authentication cancelled               | User cancelled the biometric authentication prompt      |

#### Decode Error

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

#### Import

```javascript
import {
  generate,
  sign,
  getPublicKey,
  removeKey,
  checkHardwareSupport,
} from 'react-native-secure-sign';
```

#### checkHardwareSupport()

Check if the device supports hardware-backed secure storage before using other methods.

```javascript
try {
  const supported = await checkHardwareSupport();
  if (supported) {
    console.log('✅ Device supports hardware security');
  } else {
    console.log('❌ Device does not support hardware security');
  }
} catch (error) {
  console.error('Error checking hardware support:', error.code);
}
```

#### generate()

Generate a new key pair in the Secure Enclave (iOS) or Hardware Security Module (Android).

```javascript
try {
  const publicKey = await generate('my-unique-key-id', {
    requireUserAuthentication: true,
  });
  console.log('✅ Key generated successfully');
  console.log('Public Key (Base64url):', publicKey);
} catch (error) {
  console.error('Error Code:', error.code);
  switch (error.code) {
    case '1011':
      // Key already exists - remove it first or use a different keyId
      console.log('Key already exists. Remove it first or use a different keyId');
      break;
    case '2001':
      // Biometric authentication not available
      console.log('Biometric authentication not available on this device');
      break;
    case '2002':
      // No biometric data enrolled
      console.log('Please set up Touch ID/Face ID in device settings');
      break;
    case '2003':
      // Biometric authentication locked out
      console.log('Too many failed biometric attempts.x');
      break;
    case '1001':
      // Key generation failed
      console.log('Failed to generate key. Check device security settings');
      break;
    case '1003':
      // Access control creation failed
      console.log('Failed to create access control');
      break;
    case '1006':
      // Invalid key ID
      console.log('Invalid key ID provided');
      break;
    default:
      console.log('Unknown error:', error.code);
      break;
  }
}
```

#### getPublicKey()

Retrieve the public key for an existing key pair.

```javascript
try {
  const publicKey = await getPublicKey('my-unique-key-id');
  console.log('✅ Public key retrieved');
  console.log('Public Key (Base64url):', publicKey);
} catch (error) {
  console.error('Error Code:', error.code);
  switch (error.code) {
    case '1005':
      // Key not found
      console.log('Key not found. Generate a key first');
      break;
    case '1006':
      // Invalid key ID
      console.log('Invalid key ID provided');
      break;
    case '1008':
      // Authentication failed (user cancelled or failed biometric)
      console.log('Authentication failed or cancelled');
      break;
    case '1002':
      // Public key extraction failed
      console.log('Failed to extract public key');
      break;
    default:
      console.log('Unknown error:', error.code);
      break;
  }
}
```

#### sign()

Sign data using a private key stored in hardware-backed secure storage.

```javascript
try {
  const dataToSign = 'Hello, World!';
  const dataBase64url = "SGVsbG8sIFdvcmxkIQ" // base64url
  
  const signature = await sign('my-unique-key-id', dataBase64url);
  console.log('✅ Signature created successfully');
  console.log('Signature (Base64url P1363):', signature);
} catch (error) {
  console.error('Error Code:', error.code);
  switch (error.code) {
    case '1005':
      // Key not found
      console.log('Key not found. Generate a key first');
      break;
    case '1008':
      // Authentication failed (user cancelled or failed biometric)
      console.log('Authentication failed or cancelled');
      break;
    case '2001':
      // Biometric authentication not available
      console.log('Biometric authentication not available');
      break;
    case '2002':
      // No biometric data enrolled
      console.log('Please set up biometric authentication');
      break;
    case '2003':
      // Biometric authentication locked out
      console.log('Too many failed attempts. Unlock device first');
      break;
    case '2004':
      // Authentication cancelled by user
      console.log('User cancelled authentication');
      break;
    case '3001':
      // Decode error - invalid Base64url input
      console.log('Invalid input format. Provide Base64url encoded data');
      break;
    case '4001':
      // Invalid DER format
      console.log('Invalid signature format');
      break;
    case '4002':
      // Signature conversion failed
      console.log('Failed to convert signature format');
      break;
    case '5001':
      // Algorithm not supported
      console.log('Signing algorithm not supported');
      break;
    default:
      console.log('Unknown error:', error.code);
      break;
  }
}
```

#### removeKey()

Remove a key pair from secure storage.

```javascript
try {
  await removeKey('my-unique-key-id');
  console.log('✅ Key removed successfully');
} catch (error) {
  console.error('Error Code:', error.code);
  switch (error.code) {
    case '1005':
      // Key not found
      console.log('Key not found. It may already be removed');
      break;
    case '1004':
      // Key deletion failed
      console.log('Failed to delete key');
      break;
    case '1006':
      // Invalid key ID
      console.log('Invalid key ID provided');
      break;
    case '1008':
      // Authentication failed
      console.log('Authentication required to remove key');
      break;
    default:
      console.log('Unknown error:', error.code);
      break;
  }
}
```

#### Complete Example: Registration Flow

Example of a complete registration flow using the library:

```javascript
import {
  generate,
  sign,
  getPublicKey,
  removeKey,
  checkHardwareSupport,
} from 'react-native-secure-sign';
import axios from 'axios';

const KEY_ID = 'com.example.app.key';

async function registerAccount() {
  try {
    // 1. Initiate registration challenge with server
    const challengeResponse = await axios.post(
      'https://api.example.com/v1/register/initiate-challenge'
    );
    const { challengeId, informationToSign_b64u } = challengeResponse.data;

    // 2. Generate key pair (if not exists)
    let publicKey;
    try {
      publicKey = await generate(KEY_ID, {
        requireUserAuthentication: true,
      });
    } catch (error) {
      if (error.code === '1011') {
        // Key exists, retrieve public key
        publicKey = await getPublicKey(KEY_ID);
      } else {
        throw error;
      }
    }

    // 3. Sign the challenge
    const signature = await sign(KEY_ID, informationToSign_b64u);

    // 4. Complete registration with server
    const finishResponse = await axios.post(
      'https://api.example.com/v1/register/finish-challenge',
      {
        challengeId,
        signature,
        publicKey,
      }
    );

    console.log('✅ Registration successful:', finishResponse.data);
    return finishResponse.data;
  } catch (error) {
    if (error.code) {
      // Handle library errors
      console.error('Secure Sign Error:', error.code);
      switch (error.code) {
        case '2001':
        case '2002':
          console.log('Please enable biometric authentication');
          break;
        case '2003':
          console.log('Device locked. Please unlock and try again');
          break;
        default:
          console.log('Error occurred:', error.code);
      }
    } else {
      // Handle other errors (network, etc.)
      console.error('Registration failed:', error);
    }
    throw error;
  }
}
```
