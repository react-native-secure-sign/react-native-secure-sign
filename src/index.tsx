import SecureSign from './NativeSecureSign';

export const { generate, sign, getPublicKey, removeKey, checkHardwareSupport } =
  SecureSign;

export type { GenerateOptions } from './NativeSecureSign';
