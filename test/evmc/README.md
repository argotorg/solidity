# EVMC loader

This directory used to be a full vendored import of [EVMC](https://github.com/ipsilon/evmc) as
shipped inside [evmone](https://github.com/ipsilon/evmone). As of the `evmone-fetchcontent`
branch, Solidity instead fetches evmone itself (headers included) via CMake `FetchContent`
(`cmake/EvmoneDependency.cmake`), so the EVMC headers that used to live here -- `evmc.h`,
`evmc.hpp`, `helpers.h`, `utils.h`, `mocked_host.hpp`, `bytes.hpp`, `hex.hpp`,
`filter_iterator.hpp` -- have been deleted. `#include <evmc/...>` now resolves against the fetched
copy instead. This directory shrinks from 13 files to 5: `loader.c`, `loader.h`,
`CMakeLists.txt`, `LICENSE` and this README.

What is left, and why:
- `loader.c` / `loader.h`: the EVMC loader library backing the `--vm` flag and `ETH_EVMONE`
  (see `test/Common.cpp` and `test/EVMHost.cpp`). evmone 0.23.0's `evmc/lib/` builds only the
  `evmc`, `evmc_cpp` and `mocked_host` CMake targets -- the loader itself is gone upstream (there
  is no `loader.c`, no `include/evmc/loader.h`, and no `evmc::loader` target to link). Solidity
  still needs it to keep `--vm <path>` working against arbitrary EVMC VMs, not just the statically
  linked evmone. The loader is ABI-agnostic (it only reads `vm->abi_version` and compares it
  against the compile-time `EVMC_ABI_VERSION`), so it needs no maintenance across EVMC versions
  and these two files can be left untouched on future upgrades.
- `LICENSE`: covers the two files above.
- `CMakeLists.txt`: reduced to build only the `evmc::loader` static library. It no longer defines
  an `evmc` INTERFACE target -- that name now belongs to the fetched evmone's own `evmc` target,
  and a second definition of the same target name would collide.

The `MockedAccount::storage` container-ordering tweak (`std::map` instead of `unordered_map`, kept
for deterministic `EVMHostPrinter` output -- see
[PR #11094](https://github.com/argotorg/solidity/pull/11094)) could not be preserved this way,
since `mocked_host.hpp` no longer lives in this directory to patch. Instead,
`EVMHostPrinter::storage()` (`test/EVMHost.cpp`) now sorts the storage entries at the point of
output, so upstream's `unordered_map` is safe to consume directly.
