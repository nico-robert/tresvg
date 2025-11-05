use std::ffi::CString;
use std::os::raw::c_char;
use crate::{resvg_render_tree, resvg_error};

/// Export to XML (caller must free with resvg_free_string).
#[no_mangle]
pub extern "C" fn resvg_tree_to_xml(
    tree: *const resvg_render_tree,
    out_xml: *mut *mut c_char
) -> i32 {
    if tree.is_null() || out_xml.is_null() {
        return resvg_error::PARSING_FAILED as i32;
    }
    
    let tree = unsafe { &*tree };
    let opt = resvg::usvg::WriteOptions::default();
    let xml = tree.0.to_string(&opt);
    
    match CString::new(xml) {
        Ok(c_str) => {
            unsafe {
                *out_xml = c_str.into_raw();
            }
            resvg_error::OK as i32
        }
        Err(_) => {
            unsafe {
                *out_xml = std::ptr::null_mut();
            }
            resvg_error::NOT_AN_UTF8_STR as i32
        }
    }
}

/// Frees a string allocated by resvg_tree_to_xml.
///
/// Should be called to free the string allocated by 
/// resvg_tree_to_xml after it is no longer needed.
#[no_mangle]
pub extern "C" fn resvg_free_string(s: *mut c_char) {
    if !s.is_null() {
        unsafe {
            let _ = CString::from_raw(s);
        }
    }
}

/// Returns the resvg version string (e.g., "0.45.1").
/// 
/// The returned pointer is valid for the lifetime of the program
/// and must NOT be freed.
#[no_mangle]
pub extern "C" fn resvg_version_string() -> *const c_char {
    concat!(env!("CARGO_PKG_VERSION"), "\0").as_ptr() as *const c_char
}