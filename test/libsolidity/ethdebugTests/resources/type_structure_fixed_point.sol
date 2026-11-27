contract C {
    fixed128x18 signed;
    ufixed8x1 small;
    fixed8x0 signedZeroPlaces;
    ufixed256x0 unsignedZeroPlaces;
    fixed256x80 signedMaxPlaces;
    fixed signedDefault;
    ufixed unsignedDefault;
}
// ----
// .resources.types | keys: ["t_fixed128x18","t_fixed256x80","t_fixed8x0","t_ufixed128x18","t_ufixed256x0","t_ufixed8x1"]
// .resources.types.t_fixed128x18: {"bits":128,"kind":"fixed","places":18}
// .resources.types.t_fixed256x80: {"bits":256,"kind":"fixed","places":80}
// .resources.types.t_fixed8x0: {"bits":8,"kind":"fixed","places":0}
// .resources.types.t_ufixed128x18: {"bits":128,"kind":"ufixed","places":18}
// .resources.types.t_ufixed256x0: {"bits":256,"kind":"ufixed","places":0}
// .resources.types.t_ufixed8x1: {"bits":8,"kind":"ufixed","places":1}
// .resources.pointers | keys: ["storage-t_fixed128x18","storage-t_fixed256x80","storage-t_fixed8x0","storage-t_ufixed128x18","storage-t_ufixed256x0","storage-t_ufixed8x1"]
