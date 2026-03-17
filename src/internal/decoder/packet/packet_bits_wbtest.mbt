///|
test "pkt_body_start_offset skips trailing stuffed byte after terminal 0xFF" {
  let arr : Array[Byte] = [
    b'\x12', b'\xFF', b'\x00', b'\xFF', b'\x92', b'\x23',
  ]
  let packet = Bytes::from_iter(arr.iter())
  let body_offset = pkt_body_start_offset(packet, 16)
  assert_eq(body_offset, 3)
}
