extern "C" {
    static mut environ: *mut *mut libc::c_char;
    static vm_page_size: u64;
    static kOSThermalNotificationPressureLevelName: *const libc::c_char;
    fn _NSGetEnviron() -> *mut *mut libc::c_char;
    fn mach_task_self() -> *const libc::c_void;
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

#[no_mangle]
pub unsafe extern "C" fn _platform_shims_lock_environ() {

}

#[no_mangle]
pub unsafe extern "C" fn _platform_shims_unlock_environ() {

}


#[cfg(target_os = "macos")]
#[no_mangle]
pub unsafe extern "C" fn _platform_shims_vm_size() -> u64 {
    return vm_page_size;
}

#[cfg(target_os = "macos")]
#[no_mangle]
pub unsafe extern "C" fn _platform_mach_task_self() -> *const libc::c_void {
    return mach_task_self();
}
