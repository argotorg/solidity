string constant CONST = "test.file";
contract C {
    uint8[erc7201(CONST)] array;
}
// ----
// Warning 7325: (54-75): Type uint8[5237610212305498718603509572682216073844539971870822423088087032295879652864] covers a large part of storage and thus makes collisions likely. Either use mappings or dynamic arrays and allow their size to be increased only in small quantities per transaction.
