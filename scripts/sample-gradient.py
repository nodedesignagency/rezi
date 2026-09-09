#!/usr/bin/env python3
"""
Read the reference gradient and write its real colours into ReziColor.swift.

Samples the source at exactly the positions the sky mesh uses for its control
points, so what ships is the client's gradient rather than an estimate of it.

    python3 scripts/sample-gradient.py [path-to-image]

Defaults to assets/raw/sky-gradient.png. Only stdlib is used, so it runs on a
stock macOS python3. Large images are downscaled with `sips` first when it is
available (it is, on macOS); otherwise the file is decoded directly.
"""
import os
import re
import struct
import subprocess
import sys
import tempfile
import zlib

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
SWIFT = os.path.join(ROOT, "Rezi/DesignSystem/ReziColor.swift")

# Must match AnimatedSky.meshPoints: three columns, and rows weighted to the
# top because only the upper part of the sky is ever visible.
COLUMNS = [0.0, 0.5, 1.0]
ROWS = [0.0, 0.20, 0.52, 1.0]

BEGIN = "// sky-mesh:begin"
END = "// sky-mesh:end"


def decode_png(path):
    """Minimal PNG reader: 8-bit greyscale, RGB, or RGBA, non-interlaced."""
    data = open(path, "rb").read()
    if data[:8] != b"\x89PNG\r\n\x1a\n":
        raise ValueError(f"{path} is not a PNG")

    pos, idat, meta = 8, b"", None
    while pos < len(data):
        length = struct.unpack(">I", data[pos:pos + 4])[0]
        kind = data[pos + 4:pos + 8]
        chunk = data[pos + 8:pos + 8 + length]
        if kind == b"IHDR":
            meta = struct.unpack(">IIBBBBB", chunk)
        elif kind == b"IDAT":
            idat += chunk
        elif kind == b"IEND":
            break
        pos += 12 + length

    width, height, depth, ctype, _, _, interlace = meta
    if depth != 8 or interlace != 0:
        raise ValueError("need an 8-bit, non-interlaced PNG")
    channels = {0: 1, 2: 3, 4: 2, 6: 4}.get(ctype)
    if channels is None:
        raise ValueError(f"unsupported PNG colour type {ctype} (palette?)")

    raw = zlib.decompress(idat)
    stride = width * channels
    out = bytearray(height * stride)
    prev = bytearray(stride)
    pos = 0

    for y in range(height):
        filt = raw[pos]
        pos += 1
        line = bytearray(raw[pos:pos + stride])
        pos += stride
        if filt == 1:
            for i in range(channels, stride):
                line[i] = (line[i] + line[i - channels]) & 255
        elif filt == 2:
            for i in range(stride):
                line[i] = (line[i] + prev[i]) & 255
        elif filt == 3:
            for i in range(stride):
                left = line[i - channels] if i >= channels else 0
                line[i] = (line[i] + ((left + prev[i]) >> 1)) & 255
        elif filt == 4:
            for i in range(stride):
                a = line[i - channels] if i >= channels else 0
                c = prev[i - channels] if i >= channels else 0
                b = prev[i]
                p = a + b - c
                pa, pb, pc = abs(p - a), abs(p - b), abs(p - c)
                pred = a if (pa <= pb and pa <= pc) else (b if pb <= pc else c)
                line[i] = (line[i] + pred) & 255
        out[y * stride:(y + 1) * stride] = line
        prev = line

    return width, height, channels, out


def shrink_with_sips(path, target=160):
    """macOS ships sips; use it so we decode a tiny image, not a huge one."""
    try:
        tmp = os.path.join(tempfile.mkdtemp(), "small.png")
        subprocess.run(
            ["sips", "-s", "format", "png", "-Z", str(target), path, "--out", tmp],
            check=True, capture_output=True,
        )
        return tmp
    except Exception:
        return None


def average(px, width, height, channels, ux, uy, box=0.02):
    """Average a small patch, so one noisy pixel cannot set a whole cell."""
    half_x = max(1, int(width * box))
    half_y = max(1, int(height * box))
    cx = min(width - 1, max(0, round(ux * (width - 1))))
    cy = min(height - 1, max(0, round(uy * (height - 1))))

    totals, count = [0, 0, 0], 0
    for y in range(max(0, cy - half_y), min(height, cy + half_y + 1)):
        for x in range(max(0, cx - half_x), min(width, cx + half_x + 1)):
            i = (y * width + x) * channels
            if channels <= 2:
                r = g = b = px[i]
            else:
                r, g, b = px[i], px[i + 1], px[i + 2]
            totals[0] += r
            totals[1] += g
            totals[2] += b
            count += 1
    return tuple(round(v / count) for v in totals)


def main():
    source = sys.argv[1] if len(sys.argv) > 1 else None
    if source is None:
        for name in ("sky-gradient.png", "sky-gradient.jpg", "sky-gradient.jpeg"):
            candidate = os.path.join(ROOT, "assets/raw", name)
            if os.path.exists(candidate):
                source = candidate
                break
    if source is None or not os.path.exists(source):
        sys.exit(
            "No gradient found.\n"
            "Put the reference image at assets/raw/sky-gradient.png "
            "(or pass a path), then run this again."
        )

    working = source
    if not source.lower().endswith(".png") or os.path.getsize(source) > 400_000:
        small = shrink_with_sips(source)
        if small:
            working = small
        elif not source.lower().endswith(".png"):
            sys.exit("Need a PNG, or macOS `sips` to convert it. Export as PNG.")

    width, height, channels, px = decode_png(working)

    rows = []
    print(f"\nSampling {os.path.basename(source)} ({width} x {height} working copy)\n")
    for uy in ROWS:
        cells = []
        for ux in COLUMNS:
            r, g, b = average(px, width, height, channels, ux, uy)
            cells.append(f"0x{r:02X}{g:02X}{b:02X}")
        rows.append(cells)
        print(f"  y={uy:<5}  " + "  ".join(c.replace('0x', '#') for c in cells))

    labels = ["top", "upper middle", "lower middle", "bottom"]
    lines = [
        f"    {BEGIN} — generated by scripts/sample-gradient.py, do not hand-edit",
        "    static let skyMesh: [Color] = [",
    ]
    for index, (cells, label) in enumerate(zip(rows, labels)):
        lines.append(f"        // {label}")
        joined = ", ".join(f"Color(hex: {c})" for c in cells)
        comma = "" if index == len(rows) - 1 else ","
        lines.append(f"        {joined}{comma}")
    lines.append("    ]")
    lines.append(f"    {END}")
    block = "\n".join(lines)

    swift = open(SWIFT).read()
    pattern = re.compile(
        rf"[ \t]*{re.escape(BEGIN)}.*?{re.escape(END)}", re.S
    )
    if not pattern.search(swift):
        sys.exit(f"Markers {BEGIN} / {END} not found in ReziColor.swift")
    open(SWIFT, "w").write(pattern.sub(block, swift))

    print(f"\nWrote 12 colours into {os.path.relpath(SWIFT, ROOT)}")
    print("Rebuild to see them.\n")


if __name__ == "__main__":
    main()
