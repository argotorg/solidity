# EVMC

This is an import of [EVMC](https://github.com/ipsilon/evmc) as vendored in
[evmone 0.23.0](https://github.com/ipsilon/evmone/tree/v0.23.0/evmc) (ABI version 18).

The standalone `ipsilon/evmc` repository stopped cutting releases after
[v12.1.0](https://github.com/ipsilon/evmc/releases/tag/v12.1.0) (ABI 12) and has since been archived.
EVMC development continues inside the `evmc/` subdirectory of the `evmone` repository instead, so later
ABI versions (13 onward, including the current ABI 18) are only available from an `evmone` checkout or
release, not from a versioned `evmc` release.

Steps when upgrading:
- Copy all from [evmc/include/evmc](https://github.com/ipsilon/evmone/tree/v0.23.0/evmc/include/evmc) to [test/evmc](https://github.com/argotorg/solidity/tree/develop/test/evmc)
    - As of evmone 0.23.0 that directory no longer contains `tooling.hpp` or `instructions.h` (an
      older instruction to delete/skip them on copy no longer applies — there is nothing there to
      skip). If a future upstream reintroduces files like these that don't belong in this vendored
      copy, drop them then.
- `loader.c` / `loader.h` do **not** need to be refreshed, and in fact can no longer be, from an
  `evmone` checkout: as of evmone 0.23.0, `evmc/lib/` only builds the `evmc`, `evmc_cpp` and
  `mocked_host` CMake targets — the EVMC loader is gone. The copies kept in this directory are
  ABI-agnostic (they only read `vm->abi_version` and compare it against the compile-time
  `EVMC_ABI_VERSION`), so they need no per-version maintenance and can be left untouched on future
  upgrades.
- `MockedAccount.storage` in `mocked_host.hpp` should be changed to a `map` from `unordered_map` as ordering is important for fuzzing. You'll also need to include `<map>`.
    See [PR #11094](https://github.com/argotorg/solidity/pull/11094) for more details.
