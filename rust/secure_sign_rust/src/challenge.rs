use serde::Deserialize;

#[derive(Deserialize)]
pub struct Challenge {
    pub ver: String,
    pub alg: String,
    #[serde(rename = "sigFormat")]
    pub sig_format: String,
    pub kid: String,
    pub aud: String,
    pub nonce: String,
    pub ts: i64,
    pub exp: i64,
    pub method: String,
    pub path: String,
    #[serde(default)]
    pub query: Option<String>,
    #[serde(default, rename = "bodyHash")]
    pub body_hash: Option<String>,
    #[serde(default, rename = "challengeId")]
    pub challenge_id: Option<String>,
}

fn assert_no_forbidden_chars(s: &str) -> bool {
    !s.contains('|') && !s.bytes().any(|b| b == 0)
}

pub fn canonical_string(ch: &Challenge) -> Result<String, i32> {
    if ch.ver != "SS1" { return Err(3002); }
    if ch.alg != "ES256" { return Err(3003); }
    if ch.sig_format != "P1363" { return Err(3004); }
    if ch.exp <= ch.ts { return Err(3005); }

    for (_name, val) in [
        ("kid", ch.kid.as_str()),
        ("aud", ch.aud.as_str()),
        ("nonce", ch.nonce.as_str()),
        ("method", ch.method.as_str()),
        ("path", ch.path.as_str()),
        ("query", ch.query.as_deref().unwrap_or("")),
        ("bodyHash", ch.body_hash.as_deref().unwrap_or("")),
        ("challengeId", ch.challenge_id.as_deref().unwrap_or("")),
    ] {
        if !assert_no_forbidden_chars(val) { 
            return Err(3006);
        }
    }

    let method_upper = ch.method.to_ascii_uppercase();

    let ts_s  = ch.ts.to_string();
    let exp_s = ch.exp.to_string();

    let fields = [
        ch.ver.as_str(),
        ch.alg.as_str(),
        ch.sig_format.as_str(),
        ch.aud.as_str(),
        ch.nonce.as_str(),
        ts_s.as_str(),
        exp_s.as_str(),
        method_upper.as_str(),
        ch.path.as_str(),
        ch.query.as_deref().unwrap_or(""),
        ch.body_hash.as_deref().unwrap_or(""),
        ch.kid.as_str(),
        ch.challenge_id.as_deref().unwrap_or(""),
    ];

    Ok(format!("{}|", fields.join("|")))
}
