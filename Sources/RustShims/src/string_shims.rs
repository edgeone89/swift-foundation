extern crate alloc;
use alloc::ffi::CString;
use core::ptr;
//use libc;

extern "C" {
    fn strncasecmp_l(s1: *const libc::c_char, s2: *const libc::c_char, n: libc::size_t, loc: libc::locale_t) -> libc::c_int;
    fn strncasecmp(s1: *const libc::c_char, s2: *const libc::c_char, n: libc::size_t) -> libc::c_int;
    fn strtof(s: *const libc::c_char, endp: *mut *mut libc::c_char, loc: libc::locale_t) -> libc::c_float;
    fn strtod_l(nptr: *const libc::c_char, endptr: *mut *mut libc::c_char, loc: libc::locale_t) -> libc::c_double;
    fn abort();
}

#[no_mangle]
pub unsafe extern "C" fn _stringshims_strncasecmp_l(
    s1: *const libc::c_char,
    s2: *const libc::c_char,
    n: libc::size_t,
    loc: libc::locale_t,
) -> libc::c_int {
    if loc != ptr::null_mut() {
        #[cfg(target_os = "android")]
        abort();
        
        return strncasecmp_l(s1, s2, n, loc);
    }

    #[cfg(target_os = "android")]
    return strncasecmp(s1, s2, n);

    #[cfg(target_os = "macos")]
    return strncasecmp_l(s1, s2, n, ptr::null());

    let clocale = libc::newlocale(libc::LC_ALL_MASK, c"C".as_ptr(), 0 as libc::locale_t); // 12 == 'C'
    return strncasecmp_l(s1, s2, n, clocale);
    //return strncasecmp(s1, s2, n);
}


#[no_mangle]
pub unsafe extern "C" fn _stringshims_strtod_l(nptr: *const libc::c_char,
    endptr: *mut *mut libc::c_char,
    loc: libc::locale_t) -> libc::c_double
{
    #[cfg(target_os = "macos")]
    return strtod_l(nptr, endptr, loc);
    
    // Use the C locale
    let clocale = libc::newlocale(libc::LC_ALL_MASK, c"C".as_ptr(), 0 as libc::locale_t);
    let old_locale = libc::uselocale(clocale);
    let result = libc::strtod(nptr, endptr);
    // Restore locale
    libc::uselocale(old_locale);
    return result;
}


#[no_mangle]
pub unsafe extern "C" fn _stringshims_strtof_l(nptr: *const libc::c_char,
    endptr: *mut *mut libc::c_char,
    loc: libc::locale_t) -> libc::c_float
{
    #[cfg(target_os = "macos")]
    return strtof_l(nptr, endptr, loc);

    // Use the C locale
    let clocale = libc::newlocale(libc::LC_ALL_MASK, c"C".as_ptr(), 0 as libc::locale_t);
    let old_locale = libc::uselocale(clocale);
    let result = libc::strtof(nptr, endptr);
    // Restore locale
    libc::uselocale(old_locale);
    return result;
}

