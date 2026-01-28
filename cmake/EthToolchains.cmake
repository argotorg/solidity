# Require C++20.
if (NOT DEFINED CMAKE_CXX_STANDARD)
  set(CMAKE_CXX_STANDARD 20) # This requires at least CMake 3.12 to accept this C++20 flag.
endif ()
set(CMAKE_CXX_STANDARD_REQUIRED TRUE)
set(CMAKE_CXX_EXTENSIONS OFF)

if(NOT CMAKE_TOOLCHAIN_FILE)
  # Use default toolchain file if none is provided.
  set(
      CMAKE_TOOLCHAIN_FILE
      "${CMAKE_CURRENT_LIST_DIR}/toolchains/default.cmake"
      CACHE FILEPATH "The CMake toolchain file"
  )
endif()
