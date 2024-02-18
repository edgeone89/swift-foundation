use libc::c_int;
use libc::c_void;

type removefile_state_t = *mut c_void;

extern "C" {
    fn _FileRemove_ConfirmCallback();
    fn _FileRemove_ErrorCallback();
    fn removefile_state_get(state: removefile_state_t, key: u32, dst: *mut c_void) -> c_int;
    fn removefile_state_set(state: removefile_state_t, key: u32, value: *const c_void) -> c_int;
}

#[cfg(target_os = "macos")]
#[no_mangle]
pub unsafe extern "C"
fn _filemanagershims_removefile_attach_callbacks(state: removefile_state_t, ctx: *const c_void) {
    removefile_state_set(state, REMOVEFILE_STATE_CONFIRM_CONTEXT, ctx);
    removefile_state_set(state, REMOVEFILE_STATE_CONFIRM_CALLBACK, _FileRemove_ConfirmCallback);
    removefile_state_set(state, REMOVEFILE_STATE_ERROR_CONTEXT, ctx);
    removefile_state_set(state, REMOVEFILE_STATE_ERROR_CALLBACK, _FileRemove_ErrorCallback);
}

#[cfg(target_os = "macos")]
#[no_mangle]
pub unsafe extern "C" 
fn _filemanagershims_removefile_state_get_errnum(state: removefile_state_t) -> c_int {
    let errnum = 0;
    removefile_state_get(state, REMOVEFILE_STATE_ERRNO, &errnum);
    return errnum;
}
