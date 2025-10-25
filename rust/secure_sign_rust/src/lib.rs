use std::{ffi::CString, os::raw::c_char, ptr, slice, panic};
use p256::PublicKey;
use pkcs8::EncodePublicKey;
use base64::engine::general_purpose::URL_SAFE_NO_PAD;
use base64::Engine as _;

// IOS
#[unsafe(no_mangle)]
pub extern "C" fn sec1_to_spki_der_b64url(sec1_ptr: *const u8, len: usize) -> *mut c_char {
    if sec1_ptr.is_null() || len == 0 {
        return ptr::null_mut();
    }

    let result = panic::catch_unwind(|| {
        let sec1 = unsafe { slice::from_raw_parts(sec1_ptr, len) };

        if sec1.len() != 65 || sec1[0] != 0x04 {
            return Err(());
        }

        let pk = PublicKey::from_sec1_bytes(sec1).map_err(|_| ())?;
        let der = pk.to_public_key_der().map_err(|_| ())?;
        let der_bytes = der.as_bytes();

        let b64url = URL_SAFE_NO_PAD.encode(der_bytes);

        let c_string = CString::new(b64url).map_err(|_| ())?;
        Ok(c_string.into_raw())
    });

    match result {
        Ok(Ok(ptr)) => ptr,
        _ => ptr::null_mut(),
    }
}

#[unsafe(no_mangle)]
pub extern "C" fn free_string(ptr: *mut c_char) {
    if !ptr.is_null() {
        unsafe {
            let _ = CString::from_raw(ptr);
        }
    }
}
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