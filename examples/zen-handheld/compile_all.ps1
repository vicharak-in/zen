# compile_all.ps1 - compiles the four Efinity projects of the Zen 4 handheld (T4F81), one after the other
# Usage (PowerShell, from this folder):  .\compile_all.ps1   (if it fails with error 0x7e, open the projects in the Efinity GUI and press Compile there)
# Efinity install folder; change it if yours differs
$env:EFINITY_HOME = "C:\Efinity\2026.1"
# Efinity's own Python and its flow script
$env:PYTHONHOME = "$env:EFINITY_HOME\python311"
Remove-Item Env:PYTHONPATH -ErrorAction SilentlyContinue
# The devicedb DLL needs the other Efinity DLLs, so put the Efinity bin folder on PATH
$env:PATH = "$env:EFINITY_HOME\bin;$env:EFINITY_HOME\python311;$env:EFINITY_HOME\python311\bin;$env:PATH"
$py  = "$env:EFINITY_HOME\python311\bin\python.exe"
$run = "$env:EFINITY_HOME\scripts\efx_run.py"
# Project file of every bitstream (folder and project name), run from the fpga folder
Set-Location (Join-Path $PSScriptRoot "fpga")
$projects = @("menu\gb_menu", "tetris\tetris_fpga", "runner\runner_fpga", "chess\chess_fpga", "flight\flight_fpga")
# Compile each one and report the bitstream
foreach ($p in $projects) {
    Write-Host "=== $p ==="
    $name = Split-Path $p -Leaf
    $file = Join-Path (Split-Path $p -Parent) "outflow\$name.hex.bin"
    # Move the old bitstream aside so a failed compile can not look like a success
    if (Test-Path $file) { Move-Item $file "$file.prev" -Force }
    & $py $run "$p.xml" --flow compile
    if (Test-Path $file) { Write-Host "OK   $file"; Remove-Item "$file.prev" -ErrorAction SilentlyContinue }
    else { Write-Host "FAIL $file (open the project in Efinity and check the log)"; if (Test-Path "$file.prev") { Move-Item "$file.prev" $file -Force; Write-Host "     old file kept" } }
}
