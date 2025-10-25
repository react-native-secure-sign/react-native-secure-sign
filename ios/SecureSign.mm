#import "SecureSign.h"
#import "SecureSign-Swift.h"

@implementation SecureSign {
    SecureSignImpl *moduleImpl;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        moduleImpl = [SecureSignImpl new];
    }
    return self;
}
- (std::shared_ptr<facebook::react::TurboModule>)getTurboModule:
    (const facebook::react::ObjCTurboModule::InitParams &)params
{
    return std::make_shared<facebook::react::NativeSecureSignSpecJSI>(params);
}

+ (NSString *)moduleName
{
  return @"SecureSign";
}

- (void)generate:(nonnull NSString *)keyId options:(JS::NativeSecureSign::GenerateOptions &)options resolve:(nonnull RCTPromiseResolveBlock)resolve reject:(nonnull RCTPromiseRejectBlock)reject {
    BOOL requireBiometric = options.requireBiometric();
    [moduleImpl generateWithKeyId:keyId requireBiometric:requireBiometric resolve:resolve reject:reject];
}

- (void)getPublicKey:(nonnull NSString *)keyId resolve:(nonnull RCTPromiseResolveBlock)resolve reject:(nonnull RCTPromiseRejectBlock)reject { 
    [moduleImpl getPublicKeyWithKeyId:keyId resolve:resolve reject:reject];
}

- (void)isSupported:(nonnull RCTPromiseResolveBlock)resolve reject:(nonnull RCTPromiseRejectBlock)reject { 
    [moduleImpl isSupportedWithResolve:resolve reject:reject];
}

- (void)removeKey:(nonnull NSString *)keyId resolve:(nonnull RCTPromiseResolveBlock)resolve reject:(nonnull RCTPromiseRejectBlock)reject { 
    [moduleImpl removeKeyWithKeyId:keyId resolve:resolve reject:reject];
}

- (void)sign:(nonnull NSString *)keyId information:(nonnull NSString *)information resolve:(nonnull RCTPromiseResolveBlock)resolve reject:(nonnull RCTPromiseRejectBlock)reject { 
    [moduleImpl signWithKeyId:keyId information:information resolve:resolve reject:reject];
}

@end
