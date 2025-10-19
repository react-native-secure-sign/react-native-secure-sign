cd rust/secure_sign_rust

IOS
cargo build --release --target aarch64-apple-ios

Android
cargo clean
cargo ndk -t arm64-v8a -o ../../android/src/main/jniLibs build --release
cargo ndk -t armeabi-v7a -o ../../android/src/main/jniLibs build --release
cargo ndk -t x86_64 -o ../../android/src/main/jniLibs build --release
cargo ndk -t x86 -o ../../android/src/main/jniLibs build --release