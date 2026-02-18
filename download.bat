@echo off

rem https://learn.microsoft.com/en-us/windows/win32/winprog64/wow64-implementation-details
if exist %~dp0\rustup-init.exe goto install

if %PROCESSOR_ARCHITECTURE%=="ARM64" (
    set url=https://static.rust-lang.org/rustup/dist/aarch64-pc-windows-msvc/rustup-init.exe
    goto download
)
if %PROCESSOR_ARCHITECTURE%=="x86" (
    set url=https://static.rust-lang.org/rustup/dist/i686-pc-windows-msvc/rustup-init.exe
    goto download
rem else must be on the same line as ), otherwise batch doesn't recognise it
) else ( rem "AMD64" or "IA64"
    set url=https://static.rust-lang.org/rustup/dist/x86_64-pc-windows-msvc/rustup-init.exe
)

:download
pushd %~dp0
powershell -Command "Invoke-WebRequest '%url%' -OutFile 'rustup-init.exe'"
popd

:install
call %~dp0\scripts\all

pushd %~dp0
powershell -ExecutionPolicy Bypass "scripts/install"
popd