include_guard()

include(ExternalProject)

set(SGDK_PATH CACHE PATH "Path to SGDK")
set(RESCOMP java -jar ${SGDK_PATH}/bin/rescomp.jar)

set(RESOURCE_OUTPUT_DIR ${CMAKE_CURRENT_BINARY_DIR})

function(megadrive_create_rom target)
	if(NOT TARGET ${target})
		message(FATAL_ERROR "No target \"${target}\"")
		return()
	endif()

	add_custom_command(
		TARGET ${target}
		POST_BUILD
		COMMAND ${CMAKE_OBJCOPY}
			ARGS -O binary ${target}.elf ${target}.md
		WORKING_DIRECTORY "${CMAKE_BINARY_DIR}/bin"
	)

	set(ENV{PREFIX} m68k-elf-)
	ExternalProject_Add(
		sgdk
		SOURCE_DIR ${SGDK_PATH}
	)
	add_dependencies(${target} sgdk)

	target_include_directories(
		${target}
		PRIVATE
			${SGDK_PATH}
			${SGDK_PATH}/inc
			${SGDK_PATH}/res
	)

	target_link_options(${target} PRIVATE "-T${CMAKE_SOURCE_DIR}/md.ld")
	target_link_libraries(${target} PRIVATE md)

	# TODO: Probably is better to let the User provide their
	# own "header.c" and "sega.s" files
	target_sources(
		${target}
		PRIVATE
			${CMAKE_SOURCE_DIR}/boot/header.c
			${CMAKE_SOURCE_DIR}/boot/sega.s
	)
endfunction()

function(megadrive_include_resources target file)
	get_filename_component(RES_NAME ${file} NAME_WLE)
	get_filename_component(RES_PATH ${file} DIRECTORY)

	file(STRINGS ${file} FILE_CONTENTS)
	foreach(FILE_LINE ${FILE_CONTENTS})
		string(REPLACE " " ";" LINE_LIST ${FILE_LINE}) # Split component into a list
		list(GET LINE_LIST 2 RES_FILENAME) # Get the "file" component
		string(REPLACE "\"" "" RES_FILENAME ${RES_FILENAME}) # Remove '"'
		list(APPEND RES_DEPENDS "${CMAKE_CURRENT_SOURCE_DIR}/${RES_PATH}/${RES_FILENAME}")
	endforeach()

	add_custom_command(
		OUTPUT ${RES_NAME}.s ${RES_NAME}.h
		COMMAND ${RESCOMP}
		ARGS ${CMAKE_CURRENT_SOURCE_DIR}/${file} ${RESOURCE_OUTPUT_DIR}/${RES_NAME}.s
		DEPENDS ${file} ${RES_DEPENDS}
	)

	target_sources(
		${target}
		PRIVATE
			${RESOURCE_OUTPUT_DIR}/${RES_NAME}.s
			${RESOURCE_OUTPUT_DIR}/${RES_NAME}.h
	)

	target_include_directories(${target} PRIVATE ${RESOURCE_OUTPUT_DIR})
endfunction()
