# EVMC: Ethereum Client-VM Connector API.
# Copyright 2016-2019 The EVMC Authors.
# Licensed under the Apache License, Version 2.0.

# Only the loader survives here; the EVMC headers now come from the fetched evmone (see
# cmake/EvmoneDependency.cmake and test/evmc/README.md). loader.c includes <evmc/evmc.h> and
# <evmc/helpers.h> (unprefixed), so it needs evmc::evmc's include directory to resolve those
# against the fetched copy.
add_library(evmc_loader STATIC loader.h loader.c)
add_library(evmc::loader ALIAS evmc_loader)
set_target_properties(evmc_loader PROPERTIES LINKER_LANGUAGE C)
target_link_libraries(evmc_loader PUBLIC evmc::evmc)
target_link_libraries(evmc_loader INTERFACE ${CMAKE_DL_LIBS})
target_include_directories(evmc_loader PUBLIC ${PROJECT_SOURCE_DIR}/test/)
set_target_properties(evmc_loader PROPERTIES
    POSITION_INDEPENDENT_CODE TRUE
)
