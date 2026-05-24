@echo off
rem
rem build.bat - Bootstrap hmake for Windows using FPC.
rem
rem Run from the repository root:
rem   tools\hmake\bootstrap\build.bat
rem
rem CopyLeft (c) 1995-2024 by PopolonY2k.
rem CopyLeft (c) since 2024 by Hinotori Team.

setlocal

set OUTDIR=build
set ENTRY=tools\hmake\src\main\fpc\hmake.pas
set TARGET=%OUTDIR%\hmake.exe

where fpc >nul 2>&1
if errorlevel 1 (
    echo Error: fpc not found in PATH. Install Free Pascal Compiler first.
    exit /b 1
)

if not exist "%OUTDIR%" mkdir "%OUTDIR%"

echo Building hmake...
fpc -FE%OUTDIR% -g -gw %ENTRY%
if errorlevel 1 (
    echo Build failed.
    exit /b 1
)

echo Done: %TARGET%
endlocal
