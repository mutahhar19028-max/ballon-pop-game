#!/usr/bin/env python3
from PIL import Image
import os, sys

# --- Config ---
IN_FILE  = "background.png"
RAW_OUT  = "imgData.raw"
PAL_OUT  = "palette.bin"
WIDTH, HEIGHT = 320, 200

def main():
    if not os.path.exists(IN_FILE):
        print(f"❌ Input file not found: {IN_FILE}")
        sys.exit(1)

    # --- Load and resize ---
    img = Image.open(IN_FILE).convert("RGB")
    img = img.resize((WIDTH, HEIGHT), Image.LANCZOS)

    # --- Quantize to 256 colors (VGA) ---
    img = img.quantize(colors=256)

    # --- Get palette (RGB 0–255) ---
    palette = img.getpalette()[:768]

    # Convert to 6-bit (0–63 per channel) for VGA DAC
    palette_6bit = bytes((v // 4 for v in palette))

    # --- Get pixel indices ---
    pixel_data = img.tobytes()

    # --- Write .raw ---
    with open(RAW_OUT, "wb") as f:
        f.write(pixel_data)

    # --- Write .bin palette ---
    with open(PAL_OUT, "wb") as f:
        f.write(palette_6bit)

    print(f"Conversion complete.")
    print(f" - Image resized to {WIDTH}x{HEIGHT}")
    print(f" - Wrote {RAW_OUT} ({len(pixel_data)} bytes)")
    print(f" - Wrote {PAL_OUT} (768 bytes palette)")

if __name__ == "__main__":
    main()
