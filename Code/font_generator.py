# ==============================================================
# font_generator.py — Converts IBM VGA 9x16 .bdf font to ASM/BIN
# No dependencies — works on any Python 3 installation
# ==============================================================

INPUT_BDF = "iv9x16u.bdf"   # your font file
ASM_OUT   = "font9x16.asm"
BIN_OUT   = "font9x16.bin"

WIDTH = 9
HEIGHT = 16

def parse_bdf(path):
    glyphs = {}
    with open(path, "r", encoding="utf-8", errors="ignore") as f:
        lines = f.readlines()

    i = 0
    while i < len(lines):
        line = lines[i].strip()
        if line.startswith("STARTCHAR"):
            encoding = None
            bitmap = []
            while not lines[i].startswith("ENDCHAR"):
                parts = lines[i].strip().split()
                if len(parts) >= 2 and parts[0] == "ENCODING":
                    try:
                        encoding = int(parts[1])
                    except:
                        encoding = None
                elif parts[0] == "BITMAP":
                    i += 1
                    while not lines[i].startswith("ENDCHAR"):
                        hex_line = lines[i].strip()
                        if all(c in "0123456789ABCDEF" for c in hex_line):
                            bitmap.append(int(hex_line, 16))
                        i += 1
                    break
                i += 1
            if encoding is not None and bitmap:
                glyphs[encoding] = bitmap
        i += 1
    return glyphs

def normalize_bitmap(bitmap, height):
    """Ensure exactly HEIGHT rows."""
    if len(bitmap) > height:
        return bitmap[:height]
    elif len(bitmap) < height:
        return bitmap + [0] * (height - len(bitmap))
    return bitmap

def main():
    print(f"📂 Reading {INPUT_BDF} ...")
    glyphs = parse_bdf(INPUT_BDF)
    print(f"✅ Parsed {len(glyphs)} glyphs.")

    asm_lines = []
    asm_lines.append("; ==============================================\n")
    asm_lines.append("; IBM VGA 9x16 Font — auto-generated\n")
    asm_lines.append("; Each char = 16 rows, 9 bits per row (stored as word)\n")
    asm_lines.append("; ==============================================\n\n")
    asm_lines.append("font9x16:\n")

    bin_data = bytearray()

    for code in range(256):
        bitmap = glyphs.get(code, [0]*HEIGHT)
        bitmap = normalize_bitmap(bitmap, HEIGHT)
        asm_lines.append(f"; char {code}\n")
        for row in bitmap:
            val = row & 0x1FF  # 9 bits
            bin_data += val.to_bytes(2, "little")
            asm_lines.append(f"    dw 0{val:09b}b\n")

    asm_lines.append("\n; End of font\n")

    with open(ASM_OUT, "w") as f:
        f.writelines(asm_lines)
    with open(BIN_OUT, "wb") as f:
        f.write(bin_data)

    print(f"💾 Saved {ASM_OUT} and {BIN_OUT}")
    print("✅ Done — Ready to include in NASM project!")

if __name__ == "__main__":
    main()
