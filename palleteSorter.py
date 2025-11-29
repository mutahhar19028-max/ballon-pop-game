# palette_sort_by_brightness.py
# Reads palette.bin, computes brightness, sorts from darkest → lightest, outputs to palette_sorted.txt

def read_palette(input_file):
    with open(input_file, "rb") as f:
        data = f.read()

    colors = []
    for i in range(0, len(data), 3):
        r, g, b = data[i], data[i+1], data[i+2]
        index = i // 3
        colors.append((index, r, g, b))
    return colors

def luminance(r, g, b):
    # Perceptual brightness (ITU-R BT.709)
    return 0.2126 * r + 0.7152 * g + 0.0722 * b

def sort_by_brightness(colors):
    return sorted(colors, key=lambda c: luminance(c[1], c[2], c[3]))

def write_palette(output_file, colors):
    with open(output_file, "w") as out:
        for i, (index, r, g, b) in enumerate(colors):
            lum = luminance(r, g, b)
            out.write(f"{i:03d}: (orig:{index:03d}) RGB=({r}, {g}, {b}) Lum={lum:.2f}\n")

    print(f"[+] {len(colors)} colors sorted by brightness written to {output_file}")

if __name__ == "__main__":
    palette = read_palette("palette.bin")
    sorted_palette = sort_by_brightness(palette)
    write_palette("palette_sorted.txt", sorted_palette)
