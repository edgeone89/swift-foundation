extern "C" {
    static mut environ: *mut *mut libc::c_char;
    static kOSThermalNotificationPressureLevelName: *const libc::c_char;
    fn _NSGetEnviron() -> *mut *mut libc::c_char;
}
#[no_mangle]
pub unsafe extern "C" fn _platform_shims_get_environ() -> *mut *mut libc::c_char {
    return environ;
}

#[cfg(target_os = "macos")]
#[no_mangle]
pub unsafe extern "C" fn _platform_shims_get_environ() -> *mut *mut libc::c_char {
    return _NSGetEnviron();
}

#[cfg(target_os = "macos")]
#[no_mangle]
pub unsafe extern "C" fn _platform_shims_kOSThermalNotificationPressureLevelName() -> *const libc::c_char {
    return kOSThermalNotificationPressureLevelName;
}
