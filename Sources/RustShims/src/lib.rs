#![no_std]
#![feature(alloc_error_handler)]

extern crate alloc;
use alloc::alloc::*;
use libc::c_void;
use libc::malloc;
use libc::free;

pub mod string_shims;
pub mod uuid;
pub mod platform_shims;
pub mod filemanager_shims;

pub fn add(left: usize, right: usize) -> usize {
    left + right
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn it_works() {
        let result = add(2, 2);
        assert_eq!(result, 4);
    }
    
    //TODO: test string_shims and uuid modules(copy tests from swift-foundation)
}

#[derive(Default)]
pub struct Allocator;

unsafe impl GlobalAlloc for Allocator {
    unsafe fn alloc(&self, layout: Layout) -> *mut u8 {
        malloc(layout.size() as usize) as *mut u8
    }
    unsafe fn dealloc(&self, ptr: *mut u8, _layout: Layout) {
        free(ptr as *mut c_void);
    }
}


#[alloc_error_handler]
fn allocator_error(_layout: Layout) -> ! {
    panic!("out of memory");
}


#[global_allocator]
static GLOBAL_ALLOCATOR: Allocator = Allocator;


#[panic_handler]
fn custom_panic(_info: &core::panic::PanicInfo) -> ! {
    loop {}
}
