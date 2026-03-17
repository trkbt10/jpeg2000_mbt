///|
pub fn print_string_result(result : Result[String, String]) -> Unit {
  match result {
    Ok(value) => println(value)
    Err(msg) => println("error: \{msg}")
  }
}

///|
pub fn print_unit_result(
  result : Result[Unit, String],
  ok_message? : String = "ok",
) -> Unit {
  match result {
    Ok(_) => println(ok_message)
    Err(msg) => println("error: \{msg}")
  }
}
