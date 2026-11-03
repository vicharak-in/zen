@echo off
rem Restores a .lzb file on the PC:  .\decompress FILE.lzb   (never overwrites; prints sizes)
python "%~dp0compengine.py" decompress %*
