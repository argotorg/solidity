# The Zig implementation of the SSA CFG stack shuffler, libyul/backends/evm/ssa/stack/shuffler.zig.
# It is used if a suitable Zig compiler is found; libyul/CMakeLists.txt has the build rules.

find_program(ZIG_EXECUTABLE zig DOC "The Zig compiler, for the Zig implementation of the stack shuffler")
set(zigVersion "")
if (ZIG_EXECUTABLE)
	execute_process(
		COMMAND "${ZIG_EXECUTABLE}" version
		OUTPUT_VARIABLE zigVersion
		OUTPUT_STRIP_TRAILING_WHITESPACE
		ERROR_QUIET
	)
endif()
# shuffler.zig uses the builtins of this version
set(zigMinimumVersion "0.17.0")

# The systems that the object of the Zig compiler is known to link on
set(zigTarget "")
set(zigCpu "baseline")
if (EMSCRIPTEN)
	set(zigTarget "wasm32-emscripten")
	# no WebAssembly feature beyond the MVP: the wasm-opt of Emscripten 3 rejects the features that the
	# baseline of Zig enables
	set(zigCpu "mvp")
elseif (CMAKE_SYSTEM_NAME STREQUAL "Linux")
	if (CMAKE_SYSTEM_PROCESSOR MATCHES "^(x86_64|amd64|AMD64)$")
		set(zigTarget "x86_64-linux-none")
	elseif (CMAKE_SYSTEM_PROCESSOR MATCHES "^(aarch64|arm64)$")
		set(zigTarget "aarch64-linux-none")
	endif()
endif()
set(ZIG_SHUFFLER_TARGET "${zigTarget}" CACHE STRING "Target of the Zig compiler for the stack shuffler")
set(ZIG_SHUFFLER_CPU "${zigCpu}" CACHE STRING "CPU and features (-mcpu) of the Zig compiler for the stack shuffler")
set(ZIG_SHUFFLER_OPTIMIZE "ReleaseSmall" CACHE STRING "Optimization mode of the Zig compiler for the stack shuffler")
mark_as_advanced(ZIG_SHUFFLER_TARGET ZIG_SHUFFLER_CPU ZIG_SHUFFLER_OPTIMIZE)

set(zigShufflerDefault OFF)
if (zigVersion VERSION_GREATER_EQUAL zigMinimumVersion AND ZIG_SHUFFLER_TARGET)
	set(zigShufflerDefault ON)
endif()
option(
	ZIG_SHUFFLER
	"Use the Zig implementation of the SSA CFG stack shuffler. Requires Zig ${zigMinimumVersion} or newer."
	${zigShufflerDefault}
)
option(
	ZIG_SHUFFLER_CROSSCHECK
	"Run the C++ stack shuffler next to the Zig one and assert that their results are equal."
	OFF
)

if (ZIG_SHUFFLER)
	if (NOT zigVersion VERSION_GREATER_EQUAL zigMinimumVersion)
		message(FATAL_ERROR "ZIG_SHUFFLER requires Zig ${zigMinimumVersion} or newer. Found: ${ZIG_EXECUTABLE} ${zigVersion}")
	endif()
	if (NOT ZIG_SHUFFLER_TARGET)
		message(FATAL_ERROR
			"ZIG_SHUFFLER has no default target for ${CMAKE_SYSTEM_NAME} on ${CMAKE_SYSTEM_PROCESSOR}. "
			"Set ZIG_SHUFFLER_TARGET.")
	endif()
	message(STATUS
		"Stack shuffler: Zig ${zigVersion} for ${ZIG_SHUFFLER_TARGET} (${ZIG_SHUFFLER_CPU}, ${ZIG_SHUFFLER_OPTIMIZE})")
elseif (ZIG_SHUFFLER_CROSSCHECK)
	message(FATAL_ERROR "ZIG_SHUFFLER_CROSSCHECK requires ZIG_SHUFFLER.")
endif()
