@echo off
::
:: Build batch file for RoverOs
:: Written by JGN1722 (Github)
::
:: View the source on Github:
:: github.com/JGN1722/RoverOs
::

cd /d %~dp0

set RUN=%1

:: create the target directory
if not exist "image\" mkdir "image\"

:: build the boot sector
echo ======= BOOT SECTOR =======
compilers\FASM.EXE main_source\boot_sect.asm image\boot_sect.bin
if not %errorlevel% == 0 (
	goto _l_end
)
echo.

:: build the kernel
echo ======= KERNEL =======
compilers\roverc.py main_source\kernel.c image\kernel.bin
if not %errorlevel% == 0 (
	goto _l_end
)
echo.

:: build the file system
echo ======= FILE SYSTEM =======
main_source\build_fs.py
if not %errorlevel% == 0 (
	goto _l_end
)
echo.

:: create the image
echo ======= IMAGE FILE =======
copy /b image\boot_sect.bin+image\fs.bin image\image.bin
if not %errorlevel% == 0 (
	goto _l_end
)
echo.

:: create the bochs script
echo floppya: 1_44=%~dp0image\image.bin, status=inserted > image\bochsrc
echo boot: a >> image\bochsrc
echo.

echo Done !

if "%RUN%" == "-run" (
	bochs.exe -f image\bochsrc
)

:_l_end
