///|
pub fn find_arg_index(args : Array[String], value : String) -> Int? {
  for i, arg in args {
    if arg == value {
      return Some(i)
    }
  }
  None
}

///|
pub fn arg_after_or(
  args : Array[String],
  at : Int,
  fallback : String,
) -> String {
  if at + 1 < args.length() {
    args[at + 1]
  } else {
    fallback
  }
}
