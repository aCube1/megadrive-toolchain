set(CMAKE_SYSTEM_NAME Generic CACHE INTERNAL "")
set(CMAKE_SYSTEM_VERSION 1 CACHE INTERNAL "")
set(CMAKE_SYSTEM_PROCESSOR m68k CACHE INTERNAL "")

set(CMAKE_TRY_COMPILE_TARGET_TYPE "STATIC_LIBRARY")

function(_find_m68k_compiler lang binary)
	if(NOT CMAKE_${lang}_COMPILER)
		find_program(CMAKE_${lang}_COMPILER NAMES ${binary} REQUIRED)
	endif()

	execute_process(
		COMMAND "${CMAKE_${lang}_COMPILER}" -dumpversion
		OUTPUT_VARIABLE _VERSION
		OUTPUT_STRIP_TRAILING_WHITESPACE
	)

	set(CMAKE_${lang}_COMPILER_TARGET m68k-elf CACHE INTERNAL "")
	set(CMAKE_${lang}_COMPILER_ID GNU CACHE INTERNAL "")
	set(CMAKE_${lang}_COMPILER_VERSION "${_VERSION}" CACHE INTERNAL "")
	set(CMAKE_${lang}_COMPILER_FORCED ON CACHE INTERNAL "")
	unset(_VERSION)
endfunction()

# Setup compilers
_find_m68k_compiler(ASM m68k-elf-gcc)
_find_m68k_compiler(C m68k-elf-gcc)
_find_m68k_compiler(CXX m68k-elf-g++)

foreach(lang "" C CXX)
	set(CMAKE_${lang}_FLAGS_RELEASE_INIT        "-O3 -DNDEBUG")
	set(CMAKE_${lang}_FLAGS_DEBUG_INIT          "-O0 -g -D_DEBUG")
	set(CMAKE_${lang}_FLAGS_RELWITHDEBINFO_INIT "-Og -g -DNDEBUG")
	set(CMAKE_${lang}_FLAGS_MINSIZEREL_INIT     "-Os -DNDEBUG")
endforeach()

foreach(suffix "" ASM C CXX)
	set(CMAKE_EXECUTABLE_FORMAT_${suffix} ELF CACHE INTERNAL "")
	set(CMAKE_EXECUTABLE_SUFFIX_${suffix} .elf CACHE INTERNAL "")
endforeach()

set(CFLAGS
	-m68000
	-fomit-frame-pointer
	-frename-registers -fshort-enums
	-ffreestanding
	-ffunction-sections -fdata-sections
	-fwrapv
	-fno-gcse
	-fms-extensions
	-fno-web -fno-unit-at-a-time
)

set(ASMFLAGS
	-m68000
	-Wa,--bitwise-or -Wa,--register-prefix-optional
	-x assembler-with-cpp
)

add_compile_options(
	"$<$<COMPILE_LANGUAGE:C,CXX>:${CFLAGS}>"
	"$<$<COMPILE_LANGUAGE:ASM>:${ASMFLAGS}>"
)

# Find linker
find_program(CMAKE_LINKER NAMES m68k-elf-ld)

set(CMAKE_EXE_LINKER_FLAGS "-nostdlib -nostartfiles -fcommon -Wl,--gc-sections")

# Find tools
find_program(CMAKE_OBJCOPY NAMES m68k-elf-objcopy)
find_program(CMAKE_NM NAMES m68k-elf-nm)
