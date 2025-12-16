use jni::JNIEnv;
use jni::objects::JClass;
use jni::sys::jbyteArray;

use crate::cryptographic::der_to_p1363_internal;

#[unsafe(no_mangle)]
pub extern "system" fn Java_com_securesign_SecureSignImpl_der_1to_1p1363(
    mut env: JNIEnv,
    _class: JClass,
    der: jbyteArray,
) -> jbyteArray {
    if der.is_null() {
        let _ = env.throw_new("java/lang/NullPointerException", "der is null");
        return std::ptr::null_mut();
    }

    let result = (|| -> Result<jbyteArray, jni::errors::Error> {
        let der_len = env.get_array_length(der)?;
        let mut der_bytes = vec![0u8; der_len as usize];
        env.get_byte_array_region(der, 0, &mut der_bytes)?;

        let p1363 = match der_to_p1363_internal(&der_bytes) {
            Ok(arr) => arr,
            Err(_code) => {
                let _ = env.throw_new(
                    "java/lang/IllegalArgumentException",
                    "Invalid DER signature",
                );
                return Err(jni::errors::Error::InvalidArguments);
            }
        };

        let result_array = env.new_byte_array(64)?;
        env.set_byte_array_region(result_array, 0, &p1363)?;
        
        Ok(result_array.into_raw())
    })();

    match result {
        Ok(array) => array,
        Err(_) => {
            std::ptr::null_mut()
        }
    }
}
