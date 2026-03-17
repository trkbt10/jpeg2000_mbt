///|
// Unit tests for float math utilities

///|
test "pow2_double returns 1.0 for n=0" {
  inspect(pow2_double(0), content="1")
}

///|
test "pow2_double computes positive exponents" {
  inspect(pow2_double(1), content="2")
  inspect(pow2_double(2), content="4")
  inspect(pow2_double(3), content="8")
  inspect(pow2_double(10), content="1024")
}

///|
test "pow2_double computes negative exponents" {
  inspect(pow2_double(-1), content="0.5")
  inspect(pow2_double(-2), content="0.25")
  inspect(pow2_double(-3), content="0.125")
  inspect(pow2_double(-10), content="0.0009765625")
}

///|
test "pow2_double handles large positive exponent" {
  let result = pow2_double(20)
  inspect(result, content="1048576")
}

///|
test "pow2_double handles large negative exponent" {
  let result = pow2_double(-20)
  // 1 / 2^20 = 1 / 1048576 ≈ 9.5367431640625e-7
  inspect(result > 0.0 && result < 0.000001, content="true")
}
