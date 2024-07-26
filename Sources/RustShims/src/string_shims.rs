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

#[no_mangle]
#[allow(non_upper_case_globals)]
pub static _stringshims_macroman_mapping: [[u8; 3]; 129] = [
    [ 0xC2, 0xA0, 0x00 ], /* NO-BREAK SPACE */
    [ 0xC2, 0xA1, 0x00 ], /* INVERTED EXCLAMATION MARK */
    [ 0xC2, 0xA2, 0x00 ], /* CENT SIGN */
    [ 0xC2, 0xA3, 0x00 ], /* POUND SIGN */
    [ 0xC2, 0xA5, 0x00 ], /* YEN SIGN */
    [ 0xC2, 0xA7, 0x00 ], /* SECTION SIGN */
    [ 0xC2, 0xA8, 0x00 ], /* DIAERESIS */
    [ 0xC2, 0xA9, 0x00 ], /* COPYRIGHT SIGN */
    [ 0xC2, 0xAA, 0x00 ], /* FEMININE ORDINAL INDICATOR */
    [ 0xC2, 0xAB, 0x00 ], /* LEFT-POINTING DOUBLE ANGLE QUOTATION MARK */
    [ 0xC2, 0xAC, 0x00 ], /* NOT SIGN */
    [ 0xC2, 0xAE, 0x00 ], /* REGISTERED SIGN */
    [ 0xC2, 0xAF, 0x00 ], /* MACRON */
    [ 0xC2, 0xB0, 0x00 ], /* DEGREE SIGN */
    [ 0xC2, 0xB1, 0x00 ], /* PLUS-MINUS SIGN */
    [ 0xC2, 0xB4, 0x00 ], /* ACUTE ACCENT */
    [ 0xC2, 0xB5, 0x00 ], /* MICRO SIGN */
    [ 0xC2, 0xB6, 0x00 ], /* PILCROW SIGN */
    [ 0xC2, 0xB7, 0x00 ], /* MIDDLE DOT */
    [ 0xC2, 0xB8, 0x00 ], /* CEDILLA */
    [ 0xC2, 0xBA, 0x00 ], /* MASCULINE ORDINAL INDICATOR */
    [ 0xC2, 0xBB, 0x00 ], /* RIGHT-POINTING DOUBLE ANGLE QUOTATION MARK */
    [ 0xC2, 0xBF, 0x00 ], /* INVERTED QUESTION MARK */
    [ 0xC3, 0x80, 0x00 ], /* LATIN CAPITAL LETTER A WITH GRAVE */
    [ 0xC3, 0x81, 0x00 ], /* LATIN CAPITAL LETTER A WITH ACUTE */
    [ 0xC3, 0x82, 0x00 ], /* LATIN CAPITAL LETTER A WITH CIRCUMFLEX */
    [ 0xC3, 0x83, 0x00 ], /* LATIN CAPITAL LETTER A WITH TILDE */
    [ 0xC3, 0x84, 0x00 ], /* LATIN CAPITAL LETTER A WITH DIAERESIS */
    [ 0xC3, 0x85, 0x00 ], /* LATIN CAPITAL LETTER A WITH RING ABOVE */
    [ 0xC3, 0x86, 0x00 ], /* LATIN CAPITAL LIGATURE AE */
    [ 0xC3, 0x87, 0x00 ], /* LATIN CAPITAL LETTER C WITH CEDILLA */
    [ 0xC3, 0x88, 0x00 ], /* LATIN CAPITAL LETTER E WITH GRAVE */
    [ 0xC3, 0x89, 0x00 ], /* LATIN CAPITAL LETTER E WITH ACUTE */
    [ 0xC3, 0x8A, 0x00 ], /* LATIN CAPITAL LETTER E WITH CIRCUMFLEX */
    [ 0xC3, 0x8B, 0x00 ], /* LATIN CAPITAL LETTER E WITH DIAERESIS */
    [ 0xC3, 0x8C, 0x00 ], /* LATIN CAPITAL LETTER I WITH GRAVE */
    [ 0xC3, 0x8D, 0x00 ], /* LATIN CAPITAL LETTER I WITH ACUTE */
    [ 0xC3, 0x8E, 0x00 ], /* LATIN CAPITAL LETTER I WITH CIRCUMFLEX */
    [ 0xC3, 0x8F, 0x00 ], /* LATIN CAPITAL LETTER I WITH DIAERESIS */
    [ 0xC3, 0x91, 0x00 ], /* LATIN CAPITAL LETTER N WITH TILDE */
    [ 0xC3, 0x92, 0x00 ], /* LATIN CAPITAL LETTER O WITH GRAVE */
    [ 0xC3, 0x93, 0x00 ], /* LATIN CAPITAL LETTER O WITH ACUTE */
    [ 0xC3, 0x94, 0x00 ], /* LATIN CAPITAL LETTER O WITH CIRCUMFLEX */
    [ 0xC3, 0x95, 0x00 ], /* LATIN CAPITAL LETTER O WITH TILDE */
    [ 0xC3, 0x96, 0x00 ], /* LATIN CAPITAL LETTER O WITH DIAERESIS */
    [ 0xC3, 0x98, 0x00 ], /* LATIN CAPITAL LETTER O WITH STROKE */
    [ 0xC3, 0x99, 0x00 ], /* LATIN CAPITAL LETTER U WITH GRAVE */
    [ 0xC3, 0x9A, 0x00 ], /* LATIN CAPITAL LETTER U WITH ACUTE */
    [ 0xC3, 0x9B, 0x00 ], /* LATIN CAPITAL LETTER U WITH CIRCUMFLEX */
    [ 0xC3, 0x9C, 0x00 ], /* LATIN CAPITAL LETTER U WITH DIAERESIS */
    [ 0xC3, 0x9F, 0x00 ], /* LATIN SMALL LETTER SHARP S */
    [ 0xC3, 0xA0, 0x00 ], /* LATIN SMALL LETTER A WITH GRAVE */
    [ 0xC3, 0xA1, 0x00 ], /* LATIN SMALL LETTER A WITH ACUTE */
    [ 0xC3, 0xA2, 0x00 ], /* LATIN SMALL LETTER A WITH CIRCUMFLEX */
    [ 0xC3, 0xA3, 0x00 ], /* LATIN SMALL LETTER A WITH TILDE */
    [ 0xC3, 0xA4, 0x00 ], /* LATIN SMALL LETTER A WITH DIAERESIS */
    [ 0xC3, 0xA5, 0x00 ], /* LATIN SMALL LETTER A WITH RING ABOVE */
    [ 0xC3, 0xA6, 0x00 ], /* LATIN SMALL LIGATURE AE */
    [ 0xC3, 0xA7, 0x00 ], /* LATIN SMALL LETTER C WITH CEDILLA */
    [ 0xC3, 0xA8, 0x00 ], /* LATIN SMALL LETTER E WITH GRAVE */
    [ 0xC3, 0xA9, 0x00 ], /* LATIN SMALL LETTER E WITH ACUTE */
    [ 0xC3, 0xAA, 0x00 ], /* LATIN SMALL LETTER E WITH CIRCUMFLEX */
    [ 0xC3, 0xAB, 0x00 ], /* LATIN SMALL LETTER E WITH DIAERESIS */
    [ 0xC3, 0xAC, 0x00 ], /* LATIN SMALL LETTER I WITH GRAVE */
    [ 0xC3, 0xAD, 0x00 ], /* LATIN SMALL LETTER I WITH ACUTE */
    [ 0xC3, 0xAE, 0x00 ], /* LATIN SMALL LETTER I WITH CIRCUMFLEX */
    [ 0xC3, 0xAF, 0x00 ], /* LATIN SMALL LETTER I WITH DIAERESIS */
    [ 0xC3, 0xB1, 0x00 ], /* LATIN SMALL LETTER N WITH TILDE */
    [ 0xC3, 0xB2, 0x00 ], /* LATIN SMALL LETTER O WITH GRAVE */
    [ 0xC3, 0xB3, 0x00 ], /* LATIN SMALL LETTER O WITH ACUTE */
    [ 0xC3, 0xB4, 0x00 ], /* LATIN SMALL LETTER O WITH CIRCUMFLEX */
    [ 0xC3, 0xB5, 0x00 ], /* LATIN SMALL LETTER O WITH TILDE */
    [ 0xC3, 0xB6, 0x00 ], /* LATIN SMALL LETTER O WITH DIAERESIS */
    [ 0xC3, 0xB7, 0x00 ], /* DIVISION SIGN */
    [ 0xC3, 0xB8, 0x00 ], /* LATIN SMALL LETTER O WITH STROKE */
    [ 0xC3, 0xB9, 0x00 ], /* LATIN SMALL LETTER U WITH GRAVE */
    [ 0xC3, 0xBA, 0x00 ], /* LATIN SMALL LETTER U WITH ACUTE */
    [ 0xC3, 0xBB, 0x00 ], /* LATIN SMALL LETTER U WITH CIRCUMFLEX */
    [ 0xC3, 0xBC, 0x00 ], /* LATIN SMALL LETTER U WITH DIAERESIS */
    [ 0xC3, 0xBF, 0x00 ], /* LATIN SMALL LETTER Y WITH DIAERESIS */
    [ 0xC4, 0xB1, 0x00 ], /* LATIN SMALL LETTER DOTLESS I */
    [ 0xC5, 0x92, 0x00 ], /* LATIN CAPITAL LIGATURE OE */
    [ 0xC5, 0x93, 0x00 ], /* LATIN SMALL LIGATURE OE */
    [ 0xC5, 0xB8, 0x00 ], /* LATIN CAPITAL LETTER Y WITH DIAERESIS */
    [ 0xC6, 0x92, 0x00 ], /* LATIN SMALL LETTER F WITH HOOK */
    [ 0xCB, 0x86, 0x00 ], /* MODIFIER LETTER CIRCUMFLEX ACCENT */
    [ 0xCB, 0x87, 0x00 ], /* CARON */
    [ 0xCB, 0x98, 0x00 ], /* BREVE */
    [ 0xCB, 0x99, 0x00 ], /* DOT ABOVE */
    [ 0xCB, 0x9A, 0x00 ], /* RING ABOVE */
    [ 0xCB, 0x9B, 0x00 ], /* OGONEK */
    [ 0xCB, 0x9C, 0x00 ], /* SMALL TILDE */
    [ 0xCB, 0x9D, 0x00 ], /* DOUBLE ACUTE ACCENT */
    [ 0xCE, 0xA9, 0x00 ], /* OHM SIGN (Canonical ?) */
    [ 0xCF, 0x80, 0x00 ], /* GREEK SMALL LETTER PI */
    [ 0xE2, 0x80, 0x93 ], /* EN DASH */
    [ 0xE2, 0x80, 0x94 ], /* EM DASH */
    [ 0xE2, 0x80, 0x98 ], /* LEFT SINGLE QUOTATION MARK */
    [ 0xE2, 0x80, 0x99 ], /* RIGHT SINGLE QUOTATION MARK */
    [ 0xE2, 0x80, 0x9A ], /* SINGLE LOW-9 QUOTATION MARK */
    [ 0xE2, 0x80, 0x9C ], /* LEFT DOUBLE QUOTATION MARK */
    [ 0xE2, 0x80, 0x9D ], /* RIGHT DOUBLE QUOTATION MARK */
    [ 0xE2, 0x80, 0x9E ], /* DOUBLE LOW-9 QUOTATION MARK */
    [ 0xE2, 0x80, 0xA0 ], /* DAGGER */
    [ 0xE2, 0x80, 0xA1 ], /* DOUBLE DAGGER */
    [ 0xE2, 0x80, 0xA2 ], /* BULLET */
    [ 0xE2, 0x80, 0xA6 ], /* HORIZONTAL ELLIPSIS */
    [ 0xE2, 0x80, 0xB0 ], /* PER MILLE SIGN */
    [ 0xE2, 0x80, 0xB9 ], /* SINGLE LEFT-POINTING ANGLE QUOTATION MARK */
    [ 0xE2, 0x80, 0xBA ], /* SINGLE RIGHT-POINTING ANGLE QUOTATION MARK */
    [ 0xE2, 0x81, 0x84 ], /* FRACTION SLASH */
    [ 0xE2, 0x82, 0xAC ], /* EURO SIGN */
    [ 0xE2, 0x84, 0xA2 ], /* TRADE MARK SIGN */
    [ 0xE2, 0x84, 0xA6 ], /* OHM SIGN */
    [ 0xE2, 0x88, 0x82 ], /* PARTIAL DIFFERENTIAL */
    [ 0xE2, 0x88, 0x86 ], /* INCREMENT */
    [ 0xE2, 0x88, 0x8F ], /* N-ARY PRODUCT */
    [ 0xE2, 0x88, 0x91 ], /* N-ARY SUMMATION */
    [ 0xE2, 0x88, 0x9A ], /* SQUARE ROOT */
    [ 0xE2, 0x88, 0x9E ], /* INFINITY */
    [ 0xE2, 0x88, 0xAB ], /* INTEGRAL */
    [ 0xE2, 0x89, 0x88 ], /* ALMOST EQUAL TO */
    [ 0xE2, 0x89, 0xA0 ], /* NOT EQUAL TO */
    [ 0xE2, 0x89, 0xA4 ], /* LESS-THAN OR EQUAL TO */
    [ 0xE2, 0x89, 0xA5 ], /* GREATER-THAN OR EQUAL TO */
    [ 0xE2, 0x97, 0x8A ], /* LOZENGE */
    [ 0xEF, 0xA3, 0xBF ], /* Apple logo */
    [ 0xEF, 0xAC, 0x81 ], /* LATIN SMALL LIGATURE FI */
    [ 0xEF, 0xAC, 0x82 ], /* LATIN SMALL LIGATURE FL */
];
