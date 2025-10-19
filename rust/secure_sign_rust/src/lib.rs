// IOS
#[unsafe(no_mangle)]
pub unsafe extern "C" fn der_to_p1363(left: u64, right: u64) -> u64 {
    left + right
}

// Android JNI
use jni::JNIEnv;
use jni::objects::{JClass};
use jni::sys::{jlong};

#[unsafe(no_mangle)]
pub extern "system" fn Java_com_securesign_SecureSignImpl_der_1to_1p1363(
    _env: JNIEnv,
    _class: JClass,
    left: jlong,
    right: jlong,
) -> jlong {
    unsafe { der_to_p1363(left as u64, right as u64) as jlong }
}