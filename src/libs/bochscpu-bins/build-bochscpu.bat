REM # Axel '0vercl0k' Souchet - May 2 2020
REM  If you want to enable source debugging, you can set _CL_=/Z7, set _LINK_=/DEBUG:FULL.
REM set _CL_=/Z7
REM set _LINK_=/DEBUG:FULL

pushd .

mkdir bxbuild-win
cd bxbuild-win

REM Use WSL to configure / clone the repositories.
bash -c "git clone https://github.com/yrp604/bochscpu-build.git && git clone https://github.com/yrp604/bochscpu && git clone https://github.com/yrp604/bochscpu-ffi && cd bochscpu-build && git checkout tags/v0.5"
bash -c "cd bochscpu-build && BOCHS_REV=$(cat bochscpu-build/BOCHS_REV) bash prep.sh && cd Bochs/bochs && bash .conf.cpu-msvc"

REM Build bochs; libinstrument.a is expected to fail to build so don't freak out.
REM You can run nmake all-clean to clean up the build.
cd bochscpu-build\Bochs\bochs
nmake

REM Remove old files in bochscpu.
rmdir /s /q ..\..\..\bochscpu\bochs
rmdir /s /q ..\..\..\bochscpu\lib

REM Create the libs directory where we stuff all the libs.
mkdir ..\..\..\bochscpu\lib
copy cpu\libcpu.a ..\..\..\bochscpu\lib\cpu.lib
copy cpu\fpu\libfpu.a ..\..\..\bochscpu\lib\fpu.lib
copy cpu\avx\libavx.a ..\..\..\bochscpu\lib\avx.lib
copy cpu\cpudb\libcpudb.a ..\..\..\bochscpu\lib\cpudb.lib
copy cpu\softfloat3e\libsoftfloat.a ..\..\..\bochscpu\lib\softfloat.lib

REM Now we want to copy the bochs directory over there.
mkdir ..\..\..\bochscpu\bochs
robocopy . ..\..\..\bochscpu\bochs /e

REM Now its time to build it (`RUSTFLAGS` to build a static version, otherwise the `.lib`'s size is blowing up (64mb+)).
cd ..\..\..\bochscpu-ffi
set RUSTFLAGS=-C target-feature=+crt-static
cargo clean
REM cargo build
cargo build --release

REM Get back to where we were.
popd