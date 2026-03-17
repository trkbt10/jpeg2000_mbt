///|
test "ht_vlc_tbl0 patched entries match T.814 Table B.1" {
  assert_eq(ht_vlc_tbl0[740], 0xF2FD)
  assert_eq(ht_vlc_tbl0[741], 0x226E)
}
