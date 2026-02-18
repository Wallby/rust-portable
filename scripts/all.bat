pushd %~dp0\..
set rustPortablePath=%cd%
popd
set CARGO_HOME=%rustPortablePath%\.cargo
set RUSTUP_HOME=%rustPortablePath%\.rustup