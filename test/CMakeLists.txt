cmake_minimum_required(VERSION 3.25)
project(hello)

set(hello_SOURCES hello.c)
if (WIN32)
    list(APPEND hello_SOURCES hello.rc)
endif()
add_executable(hello ${hello_SOURCES})

if(CMAKE_VERSION VERSION_GREATER_EQUAL 4.5)
    if(NOT EXISTS CMAKE_CXX_STDLIB_MODULES_JSON)
        message(FATAL_ERROR "C++ standard library manifest json file doesn't exist")
    endif()
    add_executable(hello-cxx23 hello.cpp)
    target_compile_features(hello-cxx23 PUBLIC cxx_std_23)
    set_target_properties(hello-cxx23 PROPERTIES
        CXX_SCAN_FOR_MODULES ON
    )
endif()

if(CMAKE_CXX_COMPILER_ID STREQUAL "MSVC" AND DEFINED MSVCDIR)
    add_library(cxxmodules STATIC "${MSVCDIR}/modules/std.ixx")
    target_compile_options(cxxmodules PUBLIC /std:c++latest)
endif()
