use jni::JNIEnv;
use jni::objects::{JClass};
use jni::sys::{jlong};

use crate::cryptographic::der_to_p1363_internal;

#[unsafe(no_mangle)]
pub extern "system" fn Java_com_securesign_SecureSignImpl_der_1to_1p1363(
    _env: JNIEnv,
    _class: JClass,
    left: jlong,
    right: jlong,
) -> jlong {
    0
}
