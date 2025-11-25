use std::{ffi::CString, os::raw::c_char, ptr, slice, panic};
use serde_json;

use crate::cryptographic::{sec1_to_spki_der_b64url_internal, der_to_p1363_internal};

#[unsafe(no_mangle)]
pub extern "C" fn sec1_to_spki_der_b64url(sec1_ptr: *const u8, len: usize) -> *mut c_char {
    if sec1_ptr.is_null() || len == 0 {
        return ptr::null_mut();
    }

    let result = panic::catch_unwind(|| {
        let sec1 = unsafe { slice::from_raw_parts(sec1_ptr, len) };
        let b64url = sec1_to_spki_der_b64url_internal(sec1).map_err(|_| ())?;

        let c_string = CString::new(b64url).map_err(|_| ())?;
        Ok::<*mut c_char, ()>(c_string.into_raw())
    });

    match result {
        Ok(Ok(ptr)) => ptr,
        _ => ptr::null_mut(),
    }
}



#[unsafe(no_mangle)]
pub extern "C" fn der_to_p1363(der_ptr: *const u8, len: usize) -> *mut u8 {
    if der_ptr.is_null() || len == 0 {
        return ptr::null_mut();
    }

    let result = panic::catch_unwind(|| {
        let der_bytes = unsafe { slice::from_raw_parts(der_ptr, len) };
        let p1363 = der_to_p1363_internal(der_bytes).map_err(|_| ())?;
        let boxed = Box::new(p1363); 
        Ok::<*mut u8, ()>(Box::into_raw(boxed) as *mut u8)
    });

    match result {
        Ok(Ok(ptr)) => ptr,
        _ => ptr::null_mut(),
    }
}

#[unsafe(no_mangle)]
pub extern "C" fn free_bytes(ptr: *mut u8) {
    if !ptr.is_null() {
        unsafe {
            let _ = Box::from_raw(ptr as *mut [u8; 64]);
        }
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
