@echo off
rem Compresses a file through the Zen board:  .\compress FILE   (writes FILE.lzb next to it and prints sizes)
python "%~dp0compengine.py" compress %*
