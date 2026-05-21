include(${CMAKE_SOURCE_DIR}/cmake/submodules.cmake)
initialize_submodule(mimalloc)

set(MI_BUILD_TESTS OFF CACHE BOOL "" FORCE)
set(MI_BUILD_SHARED OFF CACHE BOOL "" FORCE)
set(MI_BUILD_OBJECT OFF CACHE BOOL "" FORCE)
set(MI_BUILD_STATIC ON CACHE BOOL "" FORCE)
set(MI_OVERRIDE ON CACHE BOOL "" FORCE)

add_subdirectory(
	${CMAKE_SOURCE_DIR}/deps/mimalloc
	EXCLUDE_FROM_ALL
)
