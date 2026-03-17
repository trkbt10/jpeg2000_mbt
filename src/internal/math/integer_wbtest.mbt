///|
// Unit tests for integer math utilities

///|
test "ceil_div computes ceiling division" {
  inspect(ceil_div(10, 3), content="4") // ceil(10/3) = 4
  inspect(ceil_div(9, 3), content="3") // ceil(9/3) = 3
  inspect(ceil_div(1, 1), content="1")
  inspect(ceil_div(7, 2), content="4") // ceil(7/2) = 4
}

///|
test "ceil_div returns 0 for non-positive inputs" {
  inspect(ceil_div(0, 5), content="0")
  inspect(ceil_div(-1, 5), content="0")
  inspect(ceil_div(5, 0), content="0")
  inspect(ceil_div(5, -1), content="0")
}

///|
test "ceil_div_checked returns error for invalid divisor" {
  let result = ceil_div_checked(10, 0)
  guard result is Err(msg) else { fail("expected Err") }
  inspect(msg, content="invalid divisor")
}

///|
test "ceil_div_checked returns Ok(0) for non-positive n" {
  let result = ceil_div_checked(0, 5)
  guard result is Ok(val) else { fail("expected Ok") }
  inspect(val, content="0")
}

///|
test "ceil_div_checked computes ceiling division" {
  let result = ceil_div_checked(10, 3)
  guard result is Ok(val) else { fail("expected Ok") }
  inspect(val, content="4")
}

///|
test "floor_log2 computes floor of log2" {
  inspect(floor_log2(1), content="0")
  inspect(floor_log2(2), content="1")
  inspect(floor_log2(3), content="1")
  inspect(floor_log2(4), content="2")
  inspect(floor_log2(7), content="2")
  inspect(floor_log2(8), content="3")
  inspect(floor_log2(1024), content="10")
}

///|
test "floor_log2 returns 0 for edge cases" {
  inspect(floor_log2(0), content="0")
  inspect(floor_log2(-1), content="0")
}

///|
test "grid_index_2d computes row-major index" {
  inspect(grid_index_2d(10, 0, 0), content="0")
  inspect(grid_index_2d(10, 5, 0), content="5")
  inspect(grid_index_2d(10, 0, 1), content="10")
  inspect(grid_index_2d(10, 3, 2), content="23") // 2 * 10 + 3
}

///|
test "sum_ints sums array elements" {
  inspect(sum_ints([]), content="0")
  inspect(sum_ints([1]), content="1")
  inspect(sum_ints([1, 2, 3, 4, 5]), content="15")
  inspect(sum_ints([-1, 1]), content="0")
}
