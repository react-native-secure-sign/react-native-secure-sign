// IOS
#[unsafe(no_mangle)]
pub unsafe extern "C" fn add(left: u64, right: u64) -> u64 {
    left + right
}

// Android JNI
use jni::JNIEnv;
use jni::objects::{JClass};
use jni::sys::{jlong};

#[unsafe(no_mangle)]
pub extern "system" fn Java_com_securesign_SecureSignImpl_add(
    _env: JNIEnv,
    _class: JClass,
    left: jlong,
    right: jlong,
) -> jlong {
    unsafe { add(left as u64, right as u64) as jlong }
}