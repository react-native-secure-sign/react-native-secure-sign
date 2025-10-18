import { TurboModuleRegistry, type TurboModule } from 'react-native';
interface GenerateOptions {
  requireBiometric: boolean;
}

type PublicKeyPem = string;

export interface Spec extends TurboModule {
  generate(alias: string, options?: GenerateOptions): Promise<PublicKeyPem>;
  sign(alias: string, information: string): Promise<string>;
  getPublicKey(alias: string): Promise<PublicKeyPem>;
  removeKey(alias: string): Promise<void>;
  isSupported(): Promise<boolean>;
}

export default TurboModuleRegistry.getEnforcing<Spec>('SecureSign');
