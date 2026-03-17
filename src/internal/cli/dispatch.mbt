///|
// Handle shared CLI commands (list-samples, parse-sample, sample-hex, roundtrip-hex).
// Returns true if a command was handled, false if none matched.
pub fn dispatch_shared_commands(args : Array[String]) -> Bool {
  if find_arg_index(args, "list-samples") is Some(_) {
    for name in @core.sample_codestream_names() {
      println(name)
    }
    return true
  }
  if find_arg_index(args, "parse-sample") is Some(i) {
    let sample_name = arg_after_or(args, i, "minimal")
    print_unit_result(parse_sample_by_name(sample_name))
    return true
  }
  if find_arg_index(args, "sample-hex") is Some(i) {
    let sample_name = arg_after_or(args, i, "minimal")
    print_string_result(sample_hex_output(sample_name))
    return true
  }
  if find_arg_index(args, "roundtrip-hex") is Some(i) {
    if i + 1 >= args.length() {
      return false
    }
    print_string_result(roundtrip_hex_output(args[i + 1]))
    return true
  }
  false
}
