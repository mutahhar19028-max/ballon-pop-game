import re

# === Configuration ===
input_c_file = "DoYourThing.c"
output_asm_file = "font.asm"
label_name = "font"

# === Read the input ===
with open(input_c_file, "r", encoding="utf-8") as f:
    data = f.read()

# === Extract the glyph_bitmap array ===
match = re.search(r"const\s+uint8_t\s+glyph_bitmap\[\]\s*=\s*\{([\s\S]*?)\};", data)
if not match:
    raise SystemExit("Error: glyph_bitmap[] array not found!")

content = match.group(1).strip()

# === Split by glyph comments ===
entries = re.split(r"/\*\s*U\+([0-9A-Fa-f]+)\s*\"(.)\"\s*\*/", content)
# entries structure: ['', '0030', '0', '0xff, 0x0,', '0031', '1', '0xff, 0x0,', ... ]

glyphs = []
for i in range(1, len(entries), 3):
    code_hex = entries[i]
    char = entries[i + 1]
    bytes_part = entries[i + 2].strip().rstrip(",")
    bytes_list = [b.strip() for b in bytes_part.split(",") if b.strip()]
    glyphs.append((code_hex, char, bytes_list))

# === Write NASM file ===
with open(output_asm_file, "w", encoding="utf-8") as f:
    f.write("; ============================================\n")
    f.write(f"; Auto-generated NASM font data from {input_c_file}\n")
    f.write("; ============================================\n\n")
    f.write("section .data\n\n")
    f.write(f"{label_name}:\n")

    for code_hex, char, bytes_list in glyphs:
        label = f"    ; U+{code_hex} '{char}'\n"
        if bytes_list:
            line = "    db " + ", ".join(bytes_list) + "\n"
        else:
            line = "    ; (no data)\n"
        f.write(label)
        f.write(line)

    f.write("\n; end of font data\n")

print(f"✅ Done. NASM data written to {output_asm_file}")
