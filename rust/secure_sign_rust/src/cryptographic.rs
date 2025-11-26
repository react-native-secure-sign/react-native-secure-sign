use p256::PublicKey;
use p256::ecdsa;
use pkcs8::EncodePublicKey;
use base64::engine::general_purpose::URL_SAFE_NO_PAD;
use base64::Engine as _;

pub fn sec1_to_spki_der_b64url_internal(sec1: &[u8]) -> Result<String, i32> {
    if sec1.len() != 65 || sec1[0] != 0x04 {
        return Err(1010);
    }

    let pk = PublicKey::from_sec1_bytes(sec1)
        .map_err(|_| 1010)?; 
    let der = pk.to_public_key_der()
        .map_err(|_| 1010)?;
    let der_bytes = der.as_bytes();

    let b64url = URL_SAFE_NO_PAD.encode(der_bytes);
    Ok(b64url)
}

pub fn der_to_p1363_internal(der: &[u8]) -> Result<[u8; 64], i32> {
    let sig = ecdsa::Signature::from_der(der)
        .map_err(|_| 4001)?; 
    let p1363_bytes: [u8; 64] = sig.to_bytes().into();
    Ok(p1363_bytes)
}