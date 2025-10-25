# Makefile for building secure_sign_rust library
ARCHS_IOS = x86_64-apple-ios aarch64-apple-ios aarch64-apple-ios-sim
ARCHS_ANDROID = aarch64-linux-android armv7-linux-androideabi x86_64-linux-android i686-linux-android
LIB = libsecure_sign_rust.a
DYLIB = libsecure_sign_rust.so
XCFRAMEWORK = secure_sign_rust.xcframework

all: clean ios android 

ios: $(XCFRAMEWORK)

android: $(ARCHS_ANDROID)
	# After build is done copy files into the android folder
	mkdir -p ../../android/src/main/jniLibs/x86
	mkdir -p ../../android/src/main/jniLibs/arm64-v8a
	mkdir -p ../../android/src/main/jniLibs/armeabi-v7a
	mkdir -p ../../android/src/main/jniLibs/x86_64

	cp ./target/i686-linux-android/release/$(DYLIB) ../../android/src/main/jniLibs/x86/$(DYLIB)
	cp ./target/aarch64-linux-android/release/$(DYLIB) ../../android/src/main/jniLibs/arm64-v8a/$(DYLIB)
	cp ./target/armv7-linux-androideabi/release/$(DYLIB) ../../android/src/main/jniLibs/armeabi-v7a/$(DYLIB)
	cp ./target/x86_64-linux-android/release/$(DYLIB) ../../android/src/main/jniLibs/x86_64/$(DYLIB)

.PHONY: $(ARCHS_IOS)
$(ARCHS_IOS): %:
	cargo build --target $@ --release

.PHONY: $(ARCHS_ANDROID)
$(ARCHS_ANDROID): %:
	cargo ndk --target $@ --platform 31 build --release

$(XCFRAMEWORK): $(ARCHS_IOS)
	mkdir -p simulator_fat
	lipo -create target/x86_64-apple-ios/release/$(LIB) target/aarch64-apple-ios-sim/release/$(LIB) -output simulator_fat/$(LIB)
	# Create module.modulemap in Headers directory
	mkdir -p generated/include
	echo 'module SecureSignRust {' > generated/include/module.modulemap
	echo '  header "libsecure_sign_rust.h"' >> generated/include/module.modulemap
	echo '  export *' >> generated/include/module.modulemap
	echo '}' >> generated/include/module.modulemap
	xcodebuild -create-xcframework \
		-library target/aarch64-apple-ios/release/$(LIB) \
		-headers generated/include \
		-library simulator_fat/$(LIB) \
		-headers generated/include \
		-output $(XCFRAMEWORK)
	cp -r $(XCFRAMEWORK) ../../ios/$(XCFRAMEWORK)

clean:
	rm -rf target/
	rm -rf simulator_fat/
	rm -rf $(XCFRAMEWORK)
	rm -rf ../../ios/$(XCFRAMEWORK)
	rm -rf generated/

.PHONY: all clean ios android 
