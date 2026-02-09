#!/usr/bin/env python3
"""
Generate 22 SNES-style (16-bit era) pixel art tiles.
Style: Zelda A Link to the Past — rich textures, dithering, 3+ tones per material.
All tiles are 16x16 pixels.
"""

import random
import math
from PIL import Image

random.seed(42)  # Reproducible results

OUT = "/Users/macbook/Flat101/godtest/vdh-godot/assets/sprites/tiles/"

def hex2rgb(h):
    h = h.lstrip("#")
    return (int(h[0:2], 16), int(h[2:4], 16), int(h[4:6], 16))

def make_img():
    return Image.new("RGBA", (16, 16), (0, 0, 0, 255))

def px(img, x, y, color):
    if 0 <= x < 16 and 0 <= y < 16:
        if isinstance(color, str):
            color = hex2rgb(color)
        if len(color) == 3:
            color = color + (255,)
        img.putpixel((x, y), color)

def gp(img, x, y):
    if 0 <= x < 16 and 0 <= y < 16:
        return img.getpixel((x, y))
    return (0, 0, 0, 255)

def dither_fill(img, x0, y0, w, h, c1, c2, density=0.5):
    """Fill rectangle with checkerboard dither between two colors."""
    if isinstance(c1, str): c1 = hex2rgb(c1)
    if isinstance(c2, str): c2 = hex2rgb(c2)
    for y in range(y0, y0 + h):
        for x in range(x0, x0 + w):
            if (x + y) % 2 == 0:
                px(img, x, y, c1 if random.random() > density * 0.3 else c2)
            else:
                px(img, x, y, c2 if random.random() > density * 0.3 else c1)

def noise_fill(img, x0, y0, w, h, colors, weights=None):
    """Fill rectangle with random noise from a palette."""
    if weights is None:
        weights = [1.0 / len(colors)] * len(colors)
    total = sum(weights)
    weights = [w / total for w in weights]
    for y in range(y0, y0 + h):
        for x in range(x0, x0 + w):
            r = random.random()
            cumulative = 0
            for i, w_val in enumerate(weights):
                cumulative += w_val
                if r <= cumulative:
                    c = colors[i]
                    if isinstance(c, str): c = hex2rgb(c)
                    px(img, x, y, c)
                    break

def rect(img, x0, y0, w, h, color):
    if isinstance(color, str): color = hex2rgb(color)
    for y in range(y0, y0 + h):
        for x in range(x0, x0 + w):
            px(img, x, y, color)

def hline(img, x0, x1, y, color):
    for x in range(x0, x1 + 1):
        px(img, x, y, color)

def vline(img, x, y0, y1, color):
    for y in range(y0, y1 + 1):
        px(img, x, y, color)


# ============================================================
# 1. floor_wood.png
# ============================================================
def gen_floor_wood():
    img = make_img()
    base = hex2rgb("#8B6B4A")
    highlight = hex2rgb("#A08060")
    shadow = hex2rgb("#6B4B2A")
    deep = hex2rgb("#5A3A1A")
    grain = hex2rgb("#9B7B5A")
    nail = hex2rgb("#4A3A2A")

    # 3 planks: rows 0-4, 5-9, 10-15
    plank_ranges = [(0, 4), (5, 9), (10, 15)]

    for pi, (py0, py1) in enumerate(plank_ranges):
        for y in range(py0, py1 + 1):
            for x in range(16):
                # Base fill with subtle dither
                if (x + y) % 7 == 0:
                    px(img, x, y, grain)
                elif (x * 3 + y * 5) % 11 == 0:
                    px(img, x, y, hex2rgb("#7B5B3A"))
                else:
                    px(img, x, y, base)

        # Highlight along top edge of plank
        for x in range(16):
            if random.random() > 0.15:
                px(img, x, py0, highlight)
            # Additional grain on highlight row
            if (x + py0) % 5 == 0:
                px(img, x, py0, grain)

        # Shadow at bottom of plank (plank gap)
        for x in range(16):
            px(img, x, py1, shadow)
            # Deep groove every other
            if x % 2 == 0:
                px(img, x, py1, deep)

    # Wood grain: scattered lighter pixels along planks
    random.seed(100)
    for _ in range(20):
        gx = random.randint(0, 15)
        gy = random.randint(0, 15)
        # Don't overwrite groove lines
        if gy not in [4, 9, 15]:
            px(img, gx, gy, grain)

    # Horizontal grain lines (subtle)
    for pi, (py0, py1) in enumerate(plank_ranges):
        gy = py0 + (py1 - py0) // 2
        for x in range(16):
            if (x + pi) % 4 == 0:
                px(img, x, gy, grain)

    # Nail dots at corners of planks
    for py0, py1 in plank_ranges:
        for nx in [1, 14]:
            px(img, nx, py0 + 1, nail)

    img.save(OUT + "floor_wood.png")
    print("  floor_wood.png")


# ============================================================
# 2. floor_tile_kitchen.png
# ============================================================
def gen_floor_tile_kitchen():
    img = make_img()
    light = hex2rgb("#D4C8B0")
    dark = hex2rgb("#C4B8A0")
    grout = hex2rgb("#AAA090")
    light_shade = hex2rgb("#CCC0A8")
    dark_shade = hex2rgb("#BCB098")

    # Two 8x8 squares arrangement: checkerboard of light and dark
    for ty in range(2):
        for tx in range(2):
            is_light = (tx + ty) % 2 == 0
            base = light if is_light else dark
            shade = light_shade if is_light else dark_shade
            x0 = tx * 8
            y0 = ty * 8

            for y in range(y0, y0 + 8):
                for x in range(x0, x0 + 8):
                    lx = x - x0
                    ly = y - y0

                    # Grout lines on edges (left and top of each square)
                    if lx == 0 or ly == 0:
                        px(img, x, y, grout)
                        continue

                    # Edge shading with dither
                    near_edge = (lx <= 1 or lx >= 6 or ly <= 1 or ly >= 6)
                    if near_edge and (x + y) % 2 == 0:
                        px(img, x, y, shade)
                    else:
                        # Subtle texture variation
                        if (x * 3 + y * 7) % 13 == 0:
                            px(img, x, y, shade)
                        else:
                            px(img, x, y, base)

    img.save(OUT + "floor_tile_kitchen.png")
    print("  floor_tile_kitchen.png")


# ============================================================
# 3. floor_grass.png
# ============================================================
def gen_floor_grass():
    img = make_img()
    base = hex2rgb("#4A8B3A")
    dark = hex2rgb("#3A6B2A")
    light = hex2rgb("#6AAB5A")
    flower_y = hex2rgb("#DDCC44")
    flower_w = (240, 240, 240)
    mid = hex2rgb("#408030")

    random.seed(77)
    for y in range(16):
        for x in range(16):
            # Dithered base between base and dark
            if (x + y) % 2 == 0:
                px(img, x, y, base)
            else:
                px(img, x, y, dark if random.random() > 0.4 else base)

    # Lighter grass tips scattered
    for _ in range(18):
        gx = random.randint(0, 15)
        gy = random.randint(0, 15)
        px(img, gx, gy, light)

    # Mid-tone tufts
    for _ in range(12):
        gx = random.randint(0, 15)
        gy = random.randint(0, 15)
        px(img, gx, gy, mid)

    # Dark tufts (clusters of 2-3 dark pixels)
    tuft_positions = [(2, 3), (3, 3), (8, 11), (9, 11), (13, 6), (14, 6), (5, 14), (1, 9)]
    for tx, ty in tuft_positions:
        px(img, tx, ty, dark)

    # Tiny flower dots
    flowers = [(4, 7, flower_y), (11, 2, flower_w), (1, 13, flower_y), (14, 10, flower_w)]
    for fx, fy, fc in flowers:
        px(img, fx, fy, fc)

    img.save(OUT + "floor_grass.png")
    print("  floor_grass.png")


# ============================================================
# 4. floor_concrete.png
# ============================================================
def gen_floor_concrete():
    img = make_img()
    base = hex2rgb("#B0B0B0")
    tex = hex2rgb("#A0A0A0")
    crack = hex2rgb("#888888")
    spot = hex2rgb("#C0C0C0")
    dark_spot = hex2rgb("#989898")

    random.seed(33)
    # Dithered base
    for y in range(16):
        for x in range(16):
            if (x + y) % 2 == 0:
                px(img, x, y, base)
            else:
                px(img, x, y, tex if random.random() > 0.5 else base)

    # Extra noise texture
    for _ in range(15):
        sx = random.randint(0, 15)
        sy = random.randint(0, 15)
        px(img, sx, sy, dark_spot)

    # Aggregate spots (lighter)
    for _ in range(12):
        sx = random.randint(0, 15)
        sy = random.randint(0, 15)
        px(img, sx, sy, spot)

    # Diagonal crack line
    for i in range(16):
        cx = i
        cy = i
        if 0 <= cx < 16 and 0 <= cy < 16:
            px(img, cx, cy, crack)
            # Crack shadow
            if cx + 1 < 16:
                if random.random() > 0.5:
                    px(img, cx + 1, cy, hex2rgb("#909090"))

    img.save(OUT + "floor_concrete.png")
    print("  floor_concrete.png")


# ============================================================
# 5. floor_asphalt.png
# ============================================================
def gen_floor_asphalt():
    img = make_img()
    base = hex2rgb("#505050")
    light = hex2rgb("#585858")
    dark = hex2rgb("#484848")
    speck = hex2rgb("#606060")
    very_dark = hex2rgb("#404040")

    random.seed(55)
    # Noise-dithered fill
    for y in range(16):
        for x in range(16):
            r = random.random()
            if r < 0.40:
                px(img, x, y, base)
            elif r < 0.65:
                px(img, x, y, light)
            elif r < 0.85:
                px(img, x, y, dark)
            else:
                px(img, x, y, very_dark)

    # Lighter speckles
    for _ in range(8):
        sx = random.randint(0, 15)
        sy = random.randint(0, 15)
        px(img, sx, sy, speck)

    # A few very dark pits
    for _ in range(5):
        sx = random.randint(0, 15)
        sy = random.randint(0, 15)
        px(img, sx, sy, hex2rgb("#3A3A3A"))

    img.save(OUT + "floor_asphalt.png")
    print("  floor_asphalt.png")


# ============================================================
# 6. floor_dirt.png
# ============================================================
def gen_floor_dirt():
    img = make_img()
    base = hex2rgb("#9B7B5A")
    tex = hex2rgb("#8B6B4A")
    pebble_dark = hex2rgb("#7B5B3A")
    pebble_light = hex2rgb("#B09070")
    twig = hex2rgb("#5A3A1A")
    mid = hex2rgb("#907050")

    random.seed(44)
    # Dithered base
    for y in range(16):
        for x in range(16):
            if (x + y) % 2 == 0:
                px(img, x, y, base)
            else:
                r = random.random()
                if r < 0.5:
                    px(img, x, y, tex)
                elif r < 0.75:
                    px(img, x, y, mid)
                else:
                    px(img, x, y, base)

    # Dark pebbles
    pebbles_d = [(3, 5), (10, 2), (7, 12), (14, 8), (1, 14), (12, 14)]
    for ppx, ppy in pebbles_d:
        px(img, ppx, ppy, pebble_dark)

    # Light pebbles
    pebbles_l = [(5, 9), (13, 4), (2, 11), (9, 7), (0, 3), (15, 1)]
    for ppx, ppy in pebbles_l:
        px(img, ppx, ppy, pebble_light)

    # Small twig detail
    px(img, 6, 6, twig)
    px(img, 7, 6, twig)
    px(img, 8, 7, twig)

    img.save(OUT + "floor_dirt.png")
    print("  floor_dirt.png")


# ============================================================
# 7. floor_classroom.png
# ============================================================
def gen_floor_classroom():
    img = make_img()
    base = hex2rgb("#C8B898")
    tex = hex2rgb("#C0B090")
    shine = hex2rgb("#D8C8A8")
    dark = hex2rgb("#B8A888")

    random.seed(22)
    # Subtle dithered base
    for y in range(16):
        for x in range(16):
            if (x + y) % 2 == 0:
                px(img, x, y, base)
            else:
                px(img, x, y, tex if random.random() > 0.6 else base)

    # Wax shine lines every 8 rows
    for y in [0, 8]:
        for x in range(16):
            if random.random() > 0.2:
                px(img, x, y, shine)

    # Very subtle extra texture
    for _ in range(8):
        sx = random.randint(0, 15)
        sy = random.randint(0, 15)
        px(img, sx, sy, dark)

    img.save(OUT + "floor_classroom.png")
    print("  floor_classroom.png")


# ============================================================
# 8. wall_house.png
# ============================================================
def gen_wall_house():
    img = make_img()
    wall_base = hex2rgb("#D8C8A8")
    wall_tex = hex2rgb("#D0C0A0")
    board_base = hex2rgb("#8B7B5B")
    board_shadow = hex2rgb("#6B5B3B")
    board_hi = hex2rgb("#A08B6B")
    wall_dark = hex2rgb("#C8B898")

    # Upper 14 rows: cream wall with subtle dither texture
    random.seed(88)
    for y in range(14):
        for x in range(16):
            if (x + y) % 2 == 0:
                px(img, x, y, wall_base)
            else:
                px(img, x, y, wall_tex if random.random() > 0.55 else wall_base)

    # Subtle wall texture dots
    for _ in range(10):
        sx = random.randint(0, 15)
        sy = random.randint(0, 13)
        px(img, sx, sy, wall_dark)

    # Lower 2 rows: baseboard
    # Row 14: highlight at top, then base
    for x in range(16):
        px(img, x, 14, board_hi)
        px(img, x, 15, board_base)
        # Shadow at very bottom
        if (x + 15) % 3 == 0:
            px(img, x, 15, board_shadow)

    # Baseboard detail: subtle wood grain
    for x in range(0, 16, 4):
        px(img, x, 15, board_shadow)

    img.save(OUT + "wall_house.png")
    print("  wall_house.png")


# ============================================================
# 9. wall_brick.png
# ============================================================
def gen_wall_brick():
    img = make_img()
    brick_base = hex2rgb("#8B4513")
    brick_hi = hex2rgb("#A05520")
    brick_shadow = hex2rgb("#6B3510")
    mortar = hex2rgb("#C0B090")
    brick_mid = hex2rgb("#7B3A10")

    random.seed(99)

    # Fill with mortar
    for y in range(16):
        for x in range(16):
            px(img, x, y, mortar)

    def draw_brick(x0, y0, w, h):
        """Draw one brick with highlight top/left, shadow bottom/right, textured fill."""
        for by in range(y0, y0 + h):
            for bx in range(x0, x0 + w):
                # Wrap for seamless tiling
                wx = bx % 16
                wy = by % 16
                lx = bx - x0
                ly = by - y0

                # Highlight on top and left edges
                if ly == 0 or lx == 0:
                    px(img, wx, wy, brick_hi)
                # Shadow on bottom and right edges
                elif ly == h - 1 or lx == w - 1:
                    px(img, wx, wy, brick_shadow)
                else:
                    # Textured fill with dither
                    if (wx + wy) % 3 == 0:
                        px(img, wx, wy, brick_mid)
                    elif (wx + wy) % 5 == 0:
                        px(img, wx, wy, brick_hi)
                    else:
                        px(img, wx, wy, brick_base)

    # Row 1 (y=0..6): mortar at y=0, bricks y=1..6
    # Two full bricks: x=0..6 and x=8..14, mortar at x=7, x=15
    # Mortar row at top
    for x in range(16):
        px(img, x, 0, mortar)
    draw_brick(0, 1, 7, 6)
    draw_brick(8, 1, 7, 6)
    # Mortar column
    for y in range(1, 7):
        px(img, 7, y, mortar)
        px(img, 15, y, mortar)

    # Mortar row between
    for x in range(16):
        px(img, x, 7, mortar)

    # Row 2 (y=8..14): offset bricks
    for x in range(16):
        px(img, x, 8, mortar)
    draw_brick(4, 9, 7, 6)
    # Left partial brick (wraps from right)
    draw_brick(-3, 9, 6, 6)
    # Right partial brick
    draw_brick(12, 9, 7, 6)

    # Mortar columns for row 2
    for y in range(9, 15):
        px(img, 3, y, mortar)
        px(img, 11, y, mortar)

    # Bottom mortar row
    for x in range(16):
        px(img, x, 15, mortar)

    img.save(OUT + "wall_brick.png")
    print("  wall_brick.png")


# ============================================================
# 10. wall_school.png
# ============================================================
def gen_wall_school():
    img = make_img()
    base = hex2rgb("#A0A8B8")
    stripe = hex2rgb("#98A0B0")
    baseboard = hex2rgb("#707880")
    board_hi = hex2rgb("#808890")
    wall_light = hex2rgb("#A8B0C0")

    random.seed(66)
    # Main wall area (rows 0-13)
    for y in range(14):
        for x in range(16):
            # Vertical dithered stripes
            if x % 4 == 0:
                if (x + y) % 2 == 0:
                    px(img, x, y, stripe)
                else:
                    px(img, x, y, base)
            elif x % 4 == 1 and (x + y) % 2 == 0:
                px(img, x, y, stripe)
            else:
                if (x + y) % 7 == 0:
                    px(img, x, y, wall_light)
                else:
                    px(img, x, y, base)

    # Baseboard: bottom 2 rows
    for x in range(16):
        px(img, x, 14, board_hi)
        px(img, x, 15, baseboard)

    img.save(OUT + "wall_school.png")
    print("  wall_school.png")


# ============================================================
# 11. wall_dark.png
# ============================================================
def gen_wall_dark():
    img = make_img()
    base = hex2rgb("#2A2A30")
    brick = hex2rgb("#323238")
    drip = hex2rgb("#222228")
    mortar = hex2rgb("#252530")
    highlight = hex2rgb("#38383E")

    random.seed(13)
    # Dark dithered base
    for y in range(16):
        for x in range(16):
            if (x + y) % 2 == 0:
                px(img, x, y, base)
            else:
                px(img, x, y, brick if random.random() > 0.4 else base)

    # Subtle brick pattern (barely visible)
    # Horizontal mortar lines
    for x in range(16):
        px(img, x, 0, mortar)
        px(img, x, 7, mortar)
        px(img, x, 15, mortar)

    # Vertical mortar (offset rows)
    for y in range(1, 7):
        px(img, 7, y, mortar)
        px(img, 15, y, mortar)
    for y in range(8, 15):
        px(img, 3, y, mortar)
        px(img, 11, y, mortar)

    # Drip stains
    for dy in range(3, 8):
        px(img, 5, dy, drip)
    for dy in range(10, 14):
        px(img, 12, dy, drip)

    # Rare highlight
    px(img, 2, 3, highlight)
    px(img, 10, 10, highlight)

    img.save(OUT + "wall_dark.png")
    print("  wall_dark.png")


# ============================================================
# 12. bed.png
# ============================================================
def gen_bed():
    img = make_img()

    frame = hex2rgb("#6B4B2A")
    frame_shadow = hex2rgb("#5A3A1A")
    pillow_base = hex2rgb("#E8E8E8")
    pillow_shadow = hex2rgb("#D0D0D0")
    pillow_crease = hex2rgb("#C0C0C0")
    blanket = hex2rgb("#3B5588")
    blanket_shadow = hex2rgb("#2A4470")
    blanket_hi = hex2rgb("#5B75A8")
    blanket_mid = hex2rgb("#334A78")

    # Bed frame outline
    for x in range(16):
        px(img, x, 0, frame)
        px(img, x, 15, frame_shadow)
    for y in range(16):
        px(img, 0, y, frame)
        px(img, 15, y, frame_shadow)
    # Inner shadow
    for x in range(1, 15):
        px(img, x, 1, frame)
    for y in range(1, 15):
        px(img, 1, y, frame)

    # Headboard thicker top
    for x in range(16):
        px(img, x, 0, frame)
        px(img, x, 1, frame)

    # Pillow area (rows 2-5, cols 3-12)
    for y in range(2, 6):
        for x in range(3, 13):
            if y == 2 or x == 3:
                px(img, x, y, pillow_base)
            elif y == 5 or x == 12:
                px(img, x, y, pillow_shadow)
            else:
                px(img, x, y, pillow_base)
    # Pillow crease line
    for x in range(5, 11):
        px(img, x, 4, pillow_crease)
    # Pillow rounded corners
    px(img, 3, 2, frame)
    px(img, 12, 2, frame)
    px(img, 3, 5, frame)
    px(img, 12, 5, frame)

    # Blanket area (rows 6-14, cols 2-14)
    for y in range(6, 15):
        for x in range(2, 15):
            if (x + y) % 2 == 0:
                px(img, x, y, blanket)
            else:
                px(img, x, y, blanket_mid)

    # Blanket shadow at bottom and right
    for x in range(2, 15):
        px(img, x, 14, blanket_shadow)
        px(img, x, 13, blanket_shadow if (x) % 2 == 0 else blanket)
    for y in range(6, 15):
        px(img, 14, y, blanket_shadow)

    # Blanket highlight fold line
    for x in range(3, 14):
        px(img, x, 7, blanket_hi)
        if x % 3 == 0:
            px(img, x, 8, blanket_hi)

    # Blanket top edge highlight
    for x in range(2, 15):
        px(img, x, 6, blanket_hi)

    img.save(OUT + "bed.png")
    print("  bed.png")


# ============================================================
# 13. desk.png
# ============================================================
def gen_desk():
    img = make_img()

    top = hex2rgb("#7B6B4A")
    top_shadow = hex2rgb("#6B5B3A")
    top_hi = hex2rgb("#8B7B5A")
    top_dark = hex2rgb("#5B4B2A")
    book = hex2rgb("#334488")
    book_spine = hex2rgb("#4455AA")
    pencil = hex2rgb("#DDCC44")
    pencil_tip = hex2rgb("#4A3A2A")
    leg = hex2rgb("#5A4A3A")

    # Desk surface
    for y in range(2, 14):
        for x in range(1, 15):
            if y == 2:
                px(img, x, y, top_hi)
            elif y == 13 or x == 14:
                px(img, x, y, top_shadow)
            elif x == 1:
                px(img, x, y, top_hi)
            else:
                # Subtle wood grain texture
                if (x + y) % 5 == 0:
                    px(img, x, y, top_hi)
                elif (x * 3 + y) % 7 == 0:
                    px(img, x, y, top_shadow)
                else:
                    px(img, x, y, top)

    # Front edge shadow
    for x in range(1, 15):
        px(img, x, 14, top_dark)

    # Desk edge highlight at top
    for x in range(1, 15):
        px(img, x, 1, top_shadow)

    # Legs at corners
    for lx, ly in [(1, 14), (1, 15), (14, 14), (14, 15)]:
        px(img, lx, ly, leg)
    px(img, 2, 15, leg)
    px(img, 13, 15, leg)

    # Blue book on desk
    for y in range(4, 9):
        for x in range(3, 7):
            px(img, x, y, book)
    # Book spine
    for y in range(4, 9):
        px(img, 3, y, book_spine)
    px(img, 4, 4, book_spine)

    # Yellow pencil
    for x in range(8, 13):
        px(img, x, 6, pencil)
    px(img, 13, 6, pencil_tip)
    px(img, 8, 6, hex2rgb("#CC9933"))

    img.save(OUT + "desk.png")
    print("  desk.png")


# ============================================================
# 14. door_open.png
# ============================================================
def gen_door_open():
    img = make_img()

    frame = hex2rgb("#6B4B2A")
    frame_shadow = hex2rgb("#5A3A1A")
    frame_hi = hex2rgb("#8B6B4A")
    interior_dark = hex2rgb("#1A1A20")
    interior_light = hex2rgb("#252530")
    floor = hex2rgb("#3A3A40")

    # Left frame
    for y in range(16):
        px(img, 0, y, frame_shadow)
        px(img, 1, y, frame)
        px(img, 2, y, frame_hi)
    # Right frame
    for y in range(16):
        px(img, 13, y, frame_hi)
        px(img, 14, y, frame)
        px(img, 15, y, frame_shadow)
    # Top frame
    for x in range(16):
        px(img, x, 0, frame_shadow)
        px(img, x, 1, frame)
        px(img, x, 2, frame_hi)

    # Dark interior
    for y in range(3, 16):
        for x in range(3, 13):
            if y < 8:
                px(img, x, y, interior_dark)
            elif y < 12:
                if (x + y) % 2 == 0:
                    px(img, x, y, interior_dark)
                else:
                    px(img, x, y, interior_light)
            else:
                px(img, x, y, interior_light)

    # Floor visible at bottom
    for x in range(4, 12):
        px(img, x, 14, floor)
        px(img, x, 15, floor)

    # Frame inner shadow
    for y in range(3, 16):
        px(img, 3, y, hex2rgb("#151518"))
        px(img, 12, y, hex2rgb("#151518"))

    img.save(OUT + "door_open.png")
    print("  door_open.png")


# ============================================================
# 15. door_closed.png
# ============================================================
def gen_door_closed():
    img = make_img()

    door = hex2rgb("#7B5B3A")
    door_shadow = hex2rgb("#6B4B2A")
    door_hi = hex2rgb("#9B7B5A")
    door_dark = hex2rgb("#5A3A1A")
    panel_shadow = hex2rgb("#5B3B1A")
    knob = hex2rgb("#CCAA44")
    knob_shadow = hex2rgb("#AA8833")
    knob_hi = hex2rgb("#DDBB55")
    frame = hex2rgb("#5A3A1A")

    # Door frame
    for x in range(16):
        px(img, x, 0, frame)
    for y in range(16):
        px(img, 0, y, frame)
        px(img, 15, y, frame)

    # Main door surface
    for y in range(1, 16):
        for x in range(1, 15):
            if x == 1:
                px(img, x, y, door_hi)
            elif x == 14:
                px(img, x, y, door_shadow)
            elif y == 1:
                px(img, x, y, door_hi)
            else:
                if (x + y) % 6 == 0:
                    px(img, x, y, door_hi)
                elif (x * 2 + y) % 9 == 0:
                    px(img, x, y, door_shadow)
                else:
                    px(img, x, y, door)

    # Upper recessed panel
    for x in range(3, 13):
        px(img, x, 3, panel_shadow)
    for y in range(3, 7):
        px(img, 3, y, panel_shadow)
    for x in range(3, 13):
        px(img, x, 6, door_hi)
    for y in range(3, 7):
        px(img, 12, y, door_hi)

    # Lower recessed panel
    for x in range(3, 13):
        px(img, x, 8, panel_shadow)
    for y in range(8, 14):
        px(img, 3, y, panel_shadow)
    for x in range(3, 13):
        px(img, x, 13, door_hi)
    for y in range(8, 14):
        px(img, 12, y, door_hi)

    # Doorknob
    px(img, 12, 9, knob_hi)
    px(img, 12, 10, knob)
    px(img, 13, 9, knob)
    px(img, 13, 10, knob_shadow)

    # Bottom edge
    for x in range(1, 15):
        px(img, x, 15, door_dark)

    img.save(OUT + "door_closed.png")
    print("  door_closed.png")


# ============================================================
# 16. tree.png
# ============================================================
def gen_tree():
    img = make_img()

    trunk = hex2rgb("#5B3B1A")
    trunk_shadow = hex2rgb("#4A2A10")
    trunk_hi = hex2rgb("#6B4B2A")
    canopy = hex2rgb("#3A7B2A")
    canopy_shadow = hex2rgb("#2A5B1A")
    canopy_hi = hex2rgb("#5A9B4A")
    canopy_mid = hex2rgb("#307020")

    # Fill transparent
    for y in range(16):
        for x in range(16):
            px(img, x, y, (0, 0, 0, 0))

    # Canopy (roughly circular)
    for y in range(0, 15):
        for x in range(0, 15):
            dx = x - 7
            dy = y - 7
            dist = math.sqrt(dx * dx + dy * dy)
            if dist <= 7.5:
                if dx + dy < -3:
                    px(img, x, y, canopy_hi)
                elif dx + dy > 3:
                    if (x + y) % 2 == 0:
                        px(img, x, y, canopy_shadow)
                    else:
                        px(img, x, y, canopy_mid)
                else:
                    if (x + y) % 3 == 0:
                        px(img, x, y, canopy_mid)
                    else:
                        px(img, x, y, canopy)

    # Dithered edge
    for y in range(1, 14):
        for x in range(1, 14):
            dx = x - 7
            dy = y - 7
            dist = math.sqrt(dx * dx + dy * dy)
            if 6.5 < dist <= 7.5:
                if (x + y) % 2 == 0:
                    px(img, x, y, canopy_shadow)

    # Trunk at bottom center
    for y in range(11, 16):
        for x in range(6, 10):
            if x == 6:
                px(img, x, y, trunk_shadow)
            elif x == 9:
                px(img, x, y, trunk_shadow)
            elif x == 7:
                px(img, x, y, trunk)
            else:
                px(img, x, y, trunk_hi)

    # Canopy over trunk top
    for x in range(5, 11):
        px(img, x, 11, canopy_shadow)

    # Canopy highlight scatter
    random.seed(111)
    for _ in range(10):
        hx = random.randint(2, 12)
        hy = random.randint(1, 9)
        dx = hx - 7
        dy = hy - 7
        if math.sqrt(dx * dx + dy * dy) <= 6:
            px(img, hx, hy, canopy_hi)

    img.save(OUT + "tree.png")
    print("  tree.png")


# ============================================================
# 17. fountain.png
# ============================================================
def gen_fountain():
    img = make_img()

    stone = hex2rgb("#808888")
    stone_shadow = hex2rgb("#606868")
    stone_hi = hex2rgb("#A0A8A8")
    water = hex2rgb("#4488CC")
    water_shadow = hex2rgb("#2266AA")
    water_hi = hex2rgb("#66AADD")
    stone_dark = hex2rgb("#505858")

    # Fill transparent
    for y in range(16):
        for x in range(16):
            px(img, x, y, (0, 0, 0, 0))

    cx, cy = 7.5, 7.5
    for y in range(16):
        for x in range(16):
            dx = x - cx
            dy = y - cy
            dist = math.sqrt(dx * dx + dy * dy)

            if dist <= 7.5:
                if dist >= 5.5:
                    # Stone rim
                    if dx + dy < -2:
                        px(img, x, y, stone_hi)
                    elif dx + dy > 2:
                        px(img, x, y, stone_shadow)
                    else:
                        px(img, x, y, stone)
                else:
                    # Water
                    if (x + y) % 3 == 0:
                        px(img, x, y, water_hi)
                    elif (x + y) % 2 == 0:
                        px(img, x, y, water)
                    else:
                        px(img, x, y, water_shadow)

    # 3D rim effect
    for y in range(3, 13):
        for x in range(3, 13):
            dx = x - cx
            dy = y - cy
            dist = math.sqrt(dx * dx + dy * dy)
            if 5.0 <= dist <= 5.8 and dx + dy < 0:
                px(img, x, y, stone_hi)
            elif 5.0 <= dist <= 5.8 and dx + dy > 0:
                px(img, x, y, stone_dark)

    # Water ripple lines
    for x in range(5, 11):
        if gp(img, x, 7)[3] > 0:
            px(img, x, 7, water_hi)
        if gp(img, x, 9)[3] > 0:
            px(img, x, 9, water_hi)

    # Center splash
    px(img, 7, 7, water_hi)
    px(img, 8, 7, water_hi)
    px(img, 7, 8, (200, 220, 240, 255))

    img.save(OUT + "fountain.png")
    print("  fountain.png")


# ============================================================
# 18. locker.png
# ============================================================
def gen_locker():
    img = make_img()

    base = hex2rgb("#707880")
    shadow = hex2rgb("#505860")
    hi = hex2rgb("#909898")
    vent = hex2rgb("#404850")
    handle = hex2rgb("#A0A8A8")
    division = hex2rgb("#606870")

    # Main body
    for y in range(16):
        for x in range(16):
            px(img, x, y, base)

    # Edges
    for y in range(16):
        px(img, 0, y, hi)
        px(img, 15, y, shadow)
    for x in range(16):
        px(img, x, 0, hi)
        px(img, x, 15, shadow)

    # Reflection highlight top-left
    for y in range(1, 4):
        for x in range(1, 5):
            if (x + y) % 2 == 0:
                px(img, x, y, hi)

    # Vertical division
    for y in range(16):
        px(img, 8, y, division)

    # Vent slits
    for vy in [2, 3, 4]:
        for x in range(2, 7):
            px(img, x, vy, vent)
        for x in range(10, 14):
            px(img, x, vy, vent)

    # Handles
    px(img, 12, 8, handle)
    px(img, 12, 9, handle)
    px(img, 5, 8, handle)
    px(img, 5, 9, handle)

    # Subtle texture
    random.seed(77)
    for _ in range(10):
        sx = random.randint(1, 14)
        sy = random.randint(5, 14)
        px(img, sx, sy, shadow if random.random() > 0.5 else hi)

    img.save(OUT + "locker.png")
    print("  locker.png")


# ============================================================
# 19. blackboard.png
# ============================================================
def gen_blackboard():
    img = make_img()

    board = hex2rgb("#2A4A3A")
    board_shadow = hex2rgb("#1A3A2A")
    frame_brown = hex2rgb("#5B3B1A")
    frame_hi = hex2rgb("#6B4B2A")
    frame_shadow = hex2rgb("#4A2A10")
    chalk = hex2rgb("#C0C0C0")
    chalk_dim = hex2rgb("#909090")
    tray = hex2rgb("#4A3A2A")
    tray_hi = hex2rgb("#5A4A3A")

    # Brown frame
    for x in range(16):
        px(img, x, 0, frame_brown)
        px(img, x, 1, frame_hi)
    for y in range(16):
        px(img, 0, y, frame_brown)
        px(img, 1, y, frame_hi)
        px(img, 14, y, frame_shadow)
        px(img, 15, y, frame_brown)

    # Board surface
    for y in range(2, 13):
        for x in range(2, 14):
            if (x + y) % 2 == 0:
                px(img, x, y, board)
            else:
                px(img, x, y, board_shadow if random.random() > 0.6 else board)

    # Chalk marks
    for x in [3, 4, 5, 7, 8, 10, 11, 12]:
        px(img, x, 4, chalk)
    px(img, 6, 4, chalk_dim)
    for x in [3, 4, 6, 7, 8, 9, 11, 12]:
        px(img, x, 6, chalk)
    for x in range(3, 13):
        px(img, x, 8, chalk_dim)

    # Chalk tray
    for x in range(1, 15):
        px(img, x, 13, tray_hi)
        px(img, x, 14, tray)
        px(img, x, 15, frame_shadow)

    # Chalk pieces on tray
    px(img, 5, 13, chalk)
    px(img, 6, 13, chalk)
    px(img, 10, 13, hex2rgb("#DDDD55"))

    img.save(OUT + "blackboard.png")
    print("  blackboard.png")


# ============================================================
# 20. table_student.png
# ============================================================
def gen_table_student():
    img = make_img()

    surface = hex2rgb("#A08B6B")
    surface_shadow = hex2rgb("#8B7B5B")
    surface_hi = hex2rgb("#B09B7B")
    surface_dark = hex2rgb("#7B6B4B")
    leg = hex2rgb("#606060")
    leg_shadow = hex2rgb("#505050")

    # Fill transparent
    for y in range(16):
        for x in range(16):
            px(img, x, y, (0, 0, 0, 0))

    # Table surface
    for y in range(2, 13):
        for x in range(1, 15):
            if y == 2:
                px(img, x, y, surface_hi)
            elif y == 12:
                px(img, x, y, surface_shadow)
            elif x == 1:
                px(img, x, y, surface_hi)
            elif x == 14:
                px(img, x, y, surface_shadow)
            else:
                cx_dist = abs(x - 7)
                cy_dist = abs(y - 7)
                if cx_dist <= 3 and cy_dist <= 3 and (x + y) % 3 == 0:
                    px(img, x, y, surface_hi)
                elif (x + y) % 5 == 0:
                    px(img, x, y, surface_shadow)
                else:
                    px(img, x, y, surface)

    # Front edge shadow
    for x in range(1, 15):
        px(img, x, 13, surface_dark)

    # Metal legs
    for lx, ly in [(2, 14), (2, 15), (3, 14), (3, 15)]:
        px(img, lx, ly, leg)
    for lx, ly in [(12, 14), (12, 15), (13, 14), (13, 15)]:
        px(img, lx, ly, leg)
    px(img, 3, 15, leg_shadow)
    px(img, 13, 15, leg_shadow)

    # Top edge
    for x in range(1, 15):
        px(img, x, 1, surface_dark)

    img.save(OUT + "table_student.png")
    print("  table_student.png")


# ============================================================
# 21. fridge.png
# ============================================================
def gen_fridge():
    img = make_img()

    top = hex2rgb("#E8E8E8")
    body = hex2rgb("#D0D0D0")
    shadow = hex2rgb("#C0C0C0")
    dark_shadow = hex2rgb("#B0B0B0")
    handle = hex2rgb("#A0A0A0")
    division = hex2rgb("#B8B8B8")
    highlight = hex2rgb("#F0F0F0")

    # Main body
    for y in range(16):
        for x in range(16):
            px(img, x, y, body)

    # Top (freezer) lighter
    for y in range(0, 6):
        for x in range(1, 14):
            if (x + y) % 3 == 0:
                px(img, x, y, top)
            else:
                px(img, x, y, body if y > 1 else top)

    for x in range(16):
        px(img, x, 0, top)

    # Division line
    for x in range(1, 14):
        px(img, x, 6, division)
        px(img, x, 7, dark_shadow)

    # Highlight top-left
    for y in range(1, 3):
        for x in range(1, 4):
            px(img, x, y, highlight)

    # Handle
    for y in range(2, 5):
        px(img, 13, y, handle)
    for y in range(9, 13):
        px(img, 13, y, handle)

    # Shadow right edge
    for y in range(16):
        px(img, 14, y, shadow)
        px(img, 15, y, dark_shadow)

    # Left edge
    for y in range(16):
        px(img, 0, y, shadow)

    # Bottom
    for x in range(16):
        px(img, x, 15, dark_shadow)

    # Body texture
    random.seed(200)
    for _ in range(8):
        sx = random.randint(2, 12)
        sy = random.randint(8, 14)
        px(img, sx, sy, shadow)

    img.save(OUT + "fridge.png")
    print("  fridge.png")


# ============================================================
# 22. counter.png
# ============================================================
def gen_counter():
    img = make_img()

    top_base = hex2rgb("#C8B898")
    top_shadow = hex2rgb("#B0A080")
    top_hi = hex2rgb("#D8C8A8")
    cabinet = hex2rgb("#8B7B5B")
    cabinet_shadow = hex2rgb("#6B5B3B")
    cabinet_hi = hex2rgb("#9B8B6B")
    knob = hex2rgb("#CCAA44")
    knob_shadow = hex2rgb("#AA8833")
    knob_hi = hex2rgb("#DDBB55")
    edge = hex2rgb("#A09070")

    # Countertop (top 6 rows)
    for y in range(0, 6):
        for x in range(16):
            if y == 0:
                px(img, x, y, top_hi)
            elif y == 5:
                px(img, x, y, top_shadow)
            else:
                if (x + y) % 4 == 0:
                    px(img, x, y, top_hi)
                elif (x + y) % 6 == 0:
                    px(img, x, y, top_shadow)
                else:
                    px(img, x, y, top_base)

    # Front edge
    for x in range(16):
        px(img, x, 5, edge)
        px(img, x, 6, top_shadow)

    # Cabinet door (rows 7-15)
    for y in range(7, 16):
        for x in range(16):
            if x == 0:
                px(img, x, y, cabinet_hi)
            elif x == 15:
                px(img, x, y, cabinet_shadow)
            elif y == 7:
                px(img, x, y, cabinet_hi)
            elif y == 15:
                px(img, x, y, cabinet_shadow)
            else:
                if (x + y) % 5 == 0:
                    px(img, x, y, cabinet_hi)
                elif (x + y) % 7 == 0:
                    px(img, x, y, cabinet_shadow)
                else:
                    px(img, x, y, cabinet)

    # Cabinet panel inset
    for x in range(2, 14):
        px(img, x, 8, cabinet_shadow)
        px(img, x, 14, cabinet_hi)
    for y in range(8, 15):
        px(img, 2, y, cabinet_shadow)
        px(img, 13, y, cabinet_hi)

    # Knob
    px(img, 7, 10, knob_shadow)
    px(img, 8, 10, knob)
    px(img, 7, 11, knob)
    px(img, 8, 11, knob_hi)

    img.save(OUT + "counter.png")
    print("  counter.png")


# ============================================================
# Main
# ============================================================
if __name__ == "__main__":
    print("Generating 22 SNES-style 16x16 pixel art tiles...")
    print()

    print("FLOORS:")
    gen_floor_wood()
    gen_floor_tile_kitchen()
    gen_floor_grass()
    gen_floor_concrete()
    gen_floor_asphalt()
    gen_floor_dirt()
    gen_floor_classroom()

    print()
    print("WALLS:")
    gen_wall_house()
    gen_wall_brick()
    gen_wall_school()
    gen_wall_dark()

    print()
    print("FURNITURE:")
    gen_bed()
    gen_desk()
    gen_door_open()
    gen_door_closed()
    gen_tree()
    gen_fountain()
    gen_locker()
    gen_blackboard()
    gen_table_student()
    gen_fridge()
    gen_counter()

    print()
    print("All 22 tiles generated successfully!")
