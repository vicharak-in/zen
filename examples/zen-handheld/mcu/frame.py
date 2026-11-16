# frame.py - draws the falling piece onto the locked board (runs on the RP2350 and on the PC, no hardware code)
# The FPGA sends the locked board (25 bytes, cell i = row * 10 + column is bit i % 8 of byte i // 8) and the falling piece as a 4x4 mask with its x and y

# Board size in cells
W = 10
H = 20


# Return the 25 frame bytes: the locked board plus the falling piece (the piece is hidden after game over)
def overlay(board, mask, x, y, over):
    # Copy of the board so the original is not changed
    out = bytearray(board)
    # No piece after game over
    if over:
        return bytes(out)
    # Go through the four rows of the piece box
    for row in range(4):
        # And the four columns
        for col in range(4):
            # Cell is part of the piece
            if (mask >> (row * 4 + col)) & 1:
                # Position on the board
                cx = x + col
                cy = y + row
                # Only cells on the board are drawn
                if 0 <= cx < W and 0 <= cy < H:
                    # Cell index and its bit
                    i = cy * W + cx
                    out[i >> 3] |= 1 << (i & 7)
    # Frame bytes
    return bytes(out)
