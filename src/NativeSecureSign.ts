import { TurboModuleRegistry, type TurboModule } from 'react-native';
interface GenerateOptions {
  requireBiometric: boolean;
}

type PublicKeyPem = string;

export interface Spec extends TurboModule {
  generate(keyId: string, options?: GenerateOptions): Promise<PublicKeyPem>;
  sign(keyId: string, information: string): Promise<string>;
  getPublicKey(keyId: string): Promise<PublicKeyPem>;
  removeKey(keyId: string): Promise<void>;
  isSupported(): Promise<boolean>;
}

export default TurboModuleRegistry.getEnforcing<Spec>('SecureSign');
