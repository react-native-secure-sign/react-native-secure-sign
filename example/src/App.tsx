import { Text, View, StyleSheet, TouchableOpacity } from 'react-native';
import axios from 'axios';
import {
  generate,
  removeKey,
  checkHardwareSupport,
  getPublicKey,
  sign,
} from 'react-native-secure-sign';
import base64 from 'react-native-base64';

const KEY_ID = 'com.rn.securesign';
const API_BASE = 'http://192.168.0.122:8080';

export default function App() {
  const registerAccount = async () => {
    try {
      const response = await axios.post(
        `${API_BASE}/v1/register/initiate-challenge`
      );
      const challengeId = response.data.challengeId;
      const informationToSign_b64u = response.data.informationToSign_b64u;
      const publicKey = await generateKey();
      const signature = await sign(KEY_ID, informationToSign_b64u);

      const finishResponse = await axios.post(
        `${API_BASE}/v1/register/finish-challenge`,
        {
          challengeId,
          signature,
          publicKey,
        }
      );
      console.log('Register finish response:', finishResponse.data);
    } catch (error) {
      console.error(
        'Error in register account:',
        JSON.stringify(error, null, 2)
      );
    }
  };

  const generateKey = async () => {
    try {
      const result = await generate(KEY_ID, {
        requireUserAuthentication: false,
      });
      console.log('generateKey result:', result);
      return result;
    } catch (error) {
      console.error('Error in generateKey:', JSON.stringify(error, null, 2));
      throw error;
    }
  };

  const removeKeyHandler = async () => {
    try {
      await removeKey(KEY_ID);
      console.log('removeKey result: success');
    } catch (error) {
      console.error('Error in removeKey:', JSON.stringify(error, null, 2));
    }
  };

  const checkSupport = async () => {
    try {
      const deviceSupported = await checkHardwareSupport();

      if (deviceSupported) {
        console.log('Device fully supported');
      } else {
        console.log('Device not supported');
      }
    } catch (error) {
      console.error('Error in checkSupport:', JSON.stringify(error, null, 2));
    }
  };

  const getPublicKeyHandler = async () => {
    try {
      const result = await getPublicKey(KEY_ID);
      console.log('getPublicKey result:', result);
    } catch (error) {
      console.error('Error in getPublicKey:', JSON.stringify(error, null, 2));
    }
  };

  const signHandler = async () => {
    try {
      const information = 'test_information';
      const informationBase64url = base64.encode(information);
      const signature = await sign(KEY_ID, informationBase64url);
      console.log('signature:', signature);
    } catch (error) {
      console.error('Error in sign:', JSON.stringify(error, null, 2));
    }
  };
  return (
    <View style={styles.container}>
      <TouchableOpacity style={styles.button} onPress={checkSupport}>
        <Text>Check Support</Text>
      </TouchableOpacity>
      <TouchableOpacity style={styles.button} onPress={generateKey}>
        <Text>Generate Key</Text>
      </TouchableOpacity>
      <TouchableOpacity style={styles.button} onPress={getPublicKeyHandler}>
        <Text>Get Public Key</Text>
      </TouchableOpacity>
      <TouchableOpacity style={styles.button} onPress={signHandler}>
        <Text>Sign</Text>
      </TouchableOpacity>
      <TouchableOpacity style={styles.button} onPress={registerAccount}>
        <Text>Register account</Text>
      </TouchableOpacity>
      <TouchableOpacity style={styles.button} onPress={removeKeyHandler}>
        <Text>Remove Key</Text>
      </TouchableOpacity>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    backgroundColor: '#E0E0E0',
    flex: 1,
    alignItems: 'center',
    justifyContent: 'center',
  },
  button: {
    alignItems: 'center',
    width: 170,
    height: 40,
    padding: 10,
    borderRadius: 8,
    margin: 10,
    backgroundColor: '#99CCFF',
  },
  buttonText: {
    color: 'white',
    fontSize: 16,
  },
});
