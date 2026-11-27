contract C {
    bytes blob;
    string text;
}
// ----
// .resources.types | keys: ["t_bytes_storage","t_string_storage"]
// .resources.pointers | keys: ["storage-t_bytes_storage","storage-t_string_storage"]
// .resources.pointers.storage-t_bytes_storage.for.group[0].name: length-flag
// .resources.pointers.storage-t_bytes_storage.for.group[0].length: 0x01
// .resources.pointers.storage-t_bytes_storage.for.group[0].offset: {"~difference":["~wordsize","0x01"]}
// .resources.pointers.storage-t_bytes_storage.for.group[0].slot: slot
// .resources.pointers.storage-t_bytes_storage.for.group[1].if: {"~remainder":[{"~sum":[{"~read":"length-flag"},"0x01"]},"0x02"]}
// .resources.pointers.storage-t_bytes_storage.for.group[1].then.define.length: {"~quotient":[{"~read":"length-flag"},"0x02"]}
// .resources.pointers.storage-t_bytes_storage.for.group[1].then.in.slot: slot
// .resources.pointers.storage-t_bytes_storage.for.group[1].then.in.length: length
// .resources.pointers.storage-t_bytes_storage.for.group[1].else.group[0].slot: slot
// .resources.pointers.storage-t_bytes_storage.for.group[1].else.group[1].define.length: {"~quotient":[{"~difference":[{"~read":"long-length"},"0x01"]},"0x02"]}
// .resources.pointers.storage-t_bytes_storage.for.group[1].else.group[1].in.define.start: {"~keccak256":[{"~wordsized":"slot"}]}
// .resources.pointers.storage-t_bytes_storage.for.group[1].else.group[1].in.in.slot: start
// .resources.pointers.storage-t_bytes_storage.for.group[1].else.group[1].in.in.length: length
// .resources.pointers.storage-t_string_storage.for.group[0].name: length-flag
// .resources.pointers.storage-t_string_storage.for.group[0].length: 0x01
// .resources.pointers.storage-t_string_storage.for.group[0].offset: {"~difference":["~wordsize","0x01"]}
// .resources.pointers.storage-t_string_storage.for.group[0].slot: slot
// .resources.pointers.storage-t_string_storage.for.group[1].if: {"~remainder":[{"~sum":[{"~read":"length-flag"},"0x01"]},"0x02"]}
// .resources.pointers.storage-t_string_storage.for.group[1].then.define.length: {"~quotient":[{"~read":"length-flag"},"0x02"]}
// .resources.pointers.storage-t_string_storage.for.group[1].then.in.slot: slot
// .resources.pointers.storage-t_string_storage.for.group[1].then.in.length: length
// .resources.pointers.storage-t_string_storage.for.group[1].else.group[0].slot: slot
// .resources.pointers.storage-t_string_storage.for.group[1].else.group[1].define.length: {"~quotient":[{"~difference":[{"~read":"long-length"},"0x01"]},"0x02"]}
// .resources.pointers.storage-t_string_storage.for.group[1].else.group[1].in.define.start: {"~keccak256":[{"~wordsized":"slot"}]}
// .resources.pointers.storage-t_string_storage.for.group[1].else.group[1].in.in.slot: start
// .resources.pointers.storage-t_string_storage.for.group[1].else.group[1].in.in.length: length
