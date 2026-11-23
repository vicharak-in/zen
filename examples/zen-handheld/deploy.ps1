# deploy.ps1 - copies the Zen Link module, the five bitstreams (menu, tetris, runner, chess, flight) and the board programs to the Zen 4
# Usage (PowerShell, from this folder, no other program using the port):  .\deploy.ps1 COM8 -FpgaMpy <path to fpga.mpy>
# fpga.mpy is the Zen Link MicroPython module from the Vicharak zink-alu example (firmware\RP2350).
param([string]$Port = "COM4", [string]$FpgaMpy = "fpga.mpy", [string]$BitsDir = ".\bitstream")
# Bitstream file of every game and the name it gets in the board's flash
$bits = @(
  @("gb_menu.hex.bin",       "menu.hex.bin"),
  @("tetris_fpga.hex.bin",   "tetris.hex.bin"),
  @("runner_fpga.hex.bin",   "runner.hex.bin"),
  @("chess_fpga.hex.bin",    "chess.hex.bin"),
  @("flight_fpga.hex.bin",   "flight.hex.bin"))
# The link module of the Zen board
python -m mpremote connect $Port cp $FpgaMpy :fpga.mpy
# Copy every bitstream that exists
foreach ($b in $bits) {
    $src = Join-Path $BitsDir $b[0]
    if (Test-Path $src) { Write-Host "copy $($b[1])"; python -m mpremote connect $Port cp $src ":$($b[1])" } else { Write-Host "MISSING $src (compile it first)" }
}
# Board programs: loader, launchers, drawing code, game views
python -m mpremote connect $Port cp mcu\loader.py mcu\launcher.py mcu\launcher_gfx.py mcu\gfx.py mcu\render.py mcu\sink_tft.py mcu\spi_display.py mcu\frame.py mcu\pacman_maze.py mcu\pacman_view.py mcu\runner_level.py mcu\doom_map.py mcu\arcade_view.py mcu\tetris_view.py mcu\runner_view.py mcu\chess_view.py mcu\chess_engine.py mcu\check_board.py mcu\camera_ov7670.py mcu\cordic.py mcu\flight.py :
# Boot file: the handheld starts at every power-up
python -m mpremote connect $Port cp mcu\boot_main_b.py :main.py
python -m mpremote connect $Port reset
Write-Host "Done. The picture appears on the TFT, no computer needed."
