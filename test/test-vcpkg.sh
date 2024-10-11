#!/bin/bash
#
# Copyright (c) 2024 Huang Qinjin
#
# Permission to use, copy, modify, and/or distribute this software for any
# purpose with or without fee is hereby granted, provided that the above
# copyright notice and this permission notice appear in all copies.
#
# THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
# WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
# MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
# ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
# WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
# ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
# OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.

. "${0%/*}/test.sh"


ARCH=$(. "${BIN}msvcenv.sh" && echo $ARCH)

# Create the triplet file.
cat >$ARCH-windows.cmake <<EOF
set(VCPKG_TARGET_ARCHITECTURE $ARCH)
set(VCPKG_CRT_LINKAGE dynamic)
set(VCPKG_LIBRARY_LINKAGE dynamic)
set(VCPKG_CHAINLOAD_TOOLCHAIN_FILE \$ENV{VCPKG_ROOT}/scripts/toolchains/windows.cmake)

set(ENV{CC} cl.exe)
set(ENV{CXX} cl.exe)
set(ENV{PATH} "${BIN}:\$ENV{PATH}")
EOF

# Install dependencies.
EXEC "" vcpkg install sqlite3:$ARCH-windows --overlay-triplets=.

# Create source files.
cat >main.c <<EOF
#include <sqlite3.h>
#include <stdio.h>

int main() {
    printf("%s\n", sqlite3_libversion());
}
EOF

cat >CMakeLists.txt <<EOF
cmake_minimum_required(VERSION 3.25)
project(hello)

find_package(unofficial-sqlite3 CONFIG REQUIRED)

add_executable(hello main.c)
target_link_libraries(hello PRIVATE unofficial::sqlite3::sqlite3)
EOF

CMAKE_ARGS=(
    -DCMAKE_SYSTEM_NAME=Windows
    -DCMAKE_TOOLCHAIN_FILE=$VCPKG_ROOT/scripts/buildsystems/vcpkg.cmake
    -DVCPKG_TARGET_TRIPLET=$ARCH-windows
)

# Vcpkg uses pwsh and dumpbin to copy dependencies into the output directory for executables.
if command -v pwsh &>/dev/null; then
    export PATH=${BIN}:$PATH
else
    CMAKE_ARGS+=(
        -DVCPKG_APPLOCAL_DEPS=OFF
    )
fi

case $OSTYPE in
    darwin*)
        CMAKE_ARGS+=(
            # No winbind package available on macOS.
            # https://github.com/mstorsjo/msvc-wine/issues/6
            -DCMAKE_MSVC_DEBUG_INFORMATION_FORMAT=Embedded
        ) ;;
esac

EXEC "" CC=${BIN}cl CXX=${BIN}cl RC=${BIN}rc cmake -S. -G"Ninja Multi-Config" "${CMAKE_ARGS[@]}"
EXEC "" cmake --build . --config Debug -- -v
EXEC "" cmake --build . --config Release -- -v

if command -v pwsh &>/dev/null; then
    EXEC "" file Debug/sqlite3.dll
    EXEC "" file Release/sqlite3.dll
fi


EXIT
