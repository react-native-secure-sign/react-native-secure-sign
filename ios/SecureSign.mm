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
    NSString *result = [moduleImpl generateWithKeyId:keyId requireBiometric:requireBiometric];
    resolve(result);
}

- (void)getPublicKey:(nonnull NSString *)keyId resolve:(nonnull RCTPromiseResolveBlock)resolve reject:(nonnull RCTPromiseRejectBlock)reject { 
    NSString *result = [moduleImpl getPublicKeyWithKeyId:keyId];
    resolve(result);
}

- (void)isSupported:(nonnull RCTPromiseResolveBlock)resolve reject:(nonnull RCTPromiseRejectBlock)reject { 
    BOOL result = [moduleImpl isSupported];
    resolve(@(result));
}

- (void)removeKey:(nonnull NSString *)keyId resolve:(nonnull RCTPromiseResolveBlock)resolve reject:(nonnull RCTPromiseRejectBlock)reject { 
    [moduleImpl removeKeyWithKeyId:keyId];
    resolve(nil);
}

- (void)sign:(nonnull NSString *)keyId information:(nonnull NSString *)information resolve:(nonnull RCTPromiseResolveBlock)resolve reject:(nonnull RCTPromiseRejectBlock)reject { 
    NSString *result = [moduleImpl signWithKeyId:keyId information:information];
    resolve(result);
}

@end
