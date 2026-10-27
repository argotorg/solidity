include(${CMAKE_SOURCE_DIR}/cmake/submodules.cmake)
initialize_submodule(ctre)

add_library(ctre::ctre INTERFACE IMPORTED)
set_target_properties(ctre::ctre PROPERTIES
	INTERFACE_SYSTEM_INCLUDE_DIRECTORIES ${CMAKE_SOURCE_DIR}/deps/ctre/include
	INTERFACE_INCLUDE_DIRECTORIES ${CMAKE_SOURCE_DIR}/deps/ctre/include
)
