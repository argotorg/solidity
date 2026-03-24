object "outer" {
  code {
    pop(datasize("a\\b\"c\nd\re\tf\x01g"))
  }
  data "a\\b\"c\nd\re\tf\x01g" hex"deadbeef"
}
// ----
