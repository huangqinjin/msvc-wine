@REM
@REM Copyright (c) 2024 Huang Qinjin
@REM
@REM Permission to use, copy, modify, and/or distribute this software for any
@REM purpose with or without fee is hereby granted, provided that the above
@REM copyright notice and this permission notice appear in all copies.
@REM
@REM THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
@REM WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
@REM MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
@REM ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
@REM WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
@REM ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF
@REM OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
@REM
@echo off

if "%~1"=="" (
    echo %0 ^<dest^>
    exit /B 0
)

if not exist "%~1\" (
    echo "%~1" is not a existing directory
    exit /B 1
)

pushd "%~1"

for /R "%~dp0patches" %%f in (*.patch) do (
    git --work-tree=. apply --quiet --reverse --check "%%f"
    if errorlevel 1 git --work-tree=. apply "%%f"
)

popd
