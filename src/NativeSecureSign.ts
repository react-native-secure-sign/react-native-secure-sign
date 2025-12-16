import { TurboModuleRegistry, type TurboModule } from 'react-native';
interface GenerateOptions {
  requireUserAuthentication: boolean;
}

type PublicKeyPem = string;

export interface Spec extends TurboModule {
  generate(keyId: string, options?: GenerateOptions): Promise<PublicKeyPem>;
  sign(keyId: string, information: string): Promise<string>;
  getPublicKey(keyId: string): Promise<PublicKeyPem>;
  removeKey(keyId: string): Promise<void>;
  checkHardwareSupport(): Promise<boolean>;
}

export default TurboModuleRegistry.getEnforcing<Spec>('SecureSign');
