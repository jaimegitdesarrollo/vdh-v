#!/usr/bin/env python3
"""
Generate 16x16 pixel art sprites for collectibles and UI elements
for the 2D RPG "Versos de Hero".
All sprites drawn pixel by pixel using Pillow.
"""

from PIL import Image, ImageDraw
import os
import math

COLLECTIBLES_DIR = "/Users/macbook/Flat101/godtest/vdh-godot/assets/sprites/collectibles/"
UI_DIR = "/Users/macbook/Flat101/godtest/vdh-godot/assets/sprites/ui/"

os.makedirs(COLLECTIBLES_DIR, exist_ok=True)
os.makedirs(UI_DIR, exist_ok=True)

T = (0, 0, 0, 0)  # Transparent


# =============================================================================
# 1. comic_page.png (16x16)
# =============================================================================
def make_comic_page():
    img = Image.new("RGBA", (16, 16), T)
    paper = (240, 240, 232, 255)
    fold = (210, 210, 200, 255)
    fold_dark = (190, 190, 180, 255)
    border = (26, 26, 26, 255)
    red_panel = (200, 50, 50, 255)
    blue_panel = (50, 80, 200, 255)
    green_panel = (50, 160, 80, 255)
    line_color = (80, 80, 80, 255)

    # Fill paper area (rows 1-14, cols 1-14)
    for y in range(1, 15):
        for x in range(1, 15):
            img.putpixel((x, y), paper)

    # Border - top and bottom edges
    for x in range(1, 15):
        img.putpixel((x, 0), border)
        img.putpixel((x, 15), border)
    # Border - left and right edges
    for y in range(1, 15):
        img.putpixel((0, y), border)
        img.putpixel((15, y), border)
    # Corners
    img.putpixel((0, 0), border)
    img.putpixel((15, 0), border)
    img.putpixel((0, 15), border)
    img.putpixel((15, 15), border)

    # Folded corner (top-right) - triangle fold
    fold_pixels = [
        (12, 1), (13, 1), (14, 1),
        (13, 2), (14, 2),
        (14, 3),
    ]
    for px, py in fold_pixels:
        img.putpixel((px, py), fold)
    # Fold crease line
    img.putpixel((12, 1), fold_dark)
    img.putpixel((13, 2), fold_dark)
    img.putpixel((14, 3), fold_dark)

    # Comic panels - small colored rectangles suggesting panels
    # Panel 1: red rectangle (top-left area)
    for y in range(3, 6):
        for x in range(3, 7):
            img.putpixel((x, y), red_panel)

    # Panel 2: blue rectangle (top-right area)
    for y in range(3, 6):
        for x in range(8, 11):
            img.putpixel((x, y), blue_panel)

    # Panel 3: green rectangle (bottom-left)
    for y in range(7, 10):
        for x in range(3, 7):
            img.putpixel((x, y), green_panel)

    # Panel 4: line art panel (bottom-right) - just border
    for y in range(7, 10):
        for x in range(8, 11):
            img.putpixel((x, y), paper)
    for x in range(8, 11):
        img.putpixel((x, 7), line_color)
        img.putpixel((x, 9), line_color)
    for y in range(7, 10):
        img.putpixel((8, y), line_color)
        img.putpixel((10, y), line_color)

    # Small text lines at bottom
    for x in range(3, 12):
        if x % 2 == 0:
            img.putpixel((x, 11), line_color)
            img.putpixel((x, 13), line_color)

    img.save(os.path.join(COLLECTIBLES_DIR, "comic_page.png"))
    print("  [OK] comic_page.png")


# =============================================================================
# 2. grandma_memory.png (16x16)
# =============================================================================
def make_grandma_memory():
    img = Image.new("RGBA", (16, 16), T)
    cx, cy = 7.5, 7.5  # center

    for y in range(16):
        for x in range(16):
            dist = math.sqrt((x - cx) ** 2 + (y - cy) ** 2)
            if dist <= 2.5:
                # Bright inner core
                img.putpixel((x, y), (240, 216, 136, 255))
            elif dist <= 4.0:
                # Golden center
                img.putpixel((x, y), (212, 168, 68, 255))
            elif dist <= 5.5:
                # Warm glow ring
                alpha = int(255 * (1.0 - (dist - 4.0) / 1.5))
                alpha = max(0, min(255, alpha))
                img.putpixel((x, y), (240, 200, 100, alpha))
            elif dist <= 7.0:
                # Fading outer glow
                alpha = int(160 * (1.0 - (dist - 5.5) / 1.5))
                alpha = max(0, min(255, alpha))
                img.putpixel((x, y), (220, 180, 80, alpha))
            elif dist <= 8.0:
                # Very faint outer edge
                alpha = int(60 * (1.0 - (dist - 7.0) / 1.0))
                alpha = max(0, min(255, alpha))
                img.putpixel((x, y), (200, 160, 60, alpha))

    # Add sparkle highlights
    sparkles = [(6, 6), (9, 5), (5, 9), (8, 8)]
    for sx, sy in sparkles:
        img.putpixel((sx, sy), (255, 248, 220, 255))

    img.save(os.path.join(COLLECTIBLES_DIR, "grandma_memory.png"))
    print("  [OK] grandma_memory.png")


# =============================================================================
# 3. graffiti.png (16x16)
# =============================================================================
def make_graffiti():
    img = Image.new("RGBA", (16, 16), T)
    brick = (128, 128, 128, 255)
    mortar = (100, 100, 100, 255)
    magenta = (221, 68, 170, 255)
    mag_light = (240, 120, 200, 255)
    drip = (180, 50, 140, 255)

    # Fill brick background
    for y in range(16):
        for x in range(16):
            img.putpixel((x, y), brick)

    # Mortar lines (horizontal)
    for x in range(16):
        img.putpixel((x, 3), mortar)
        img.putpixel((x, 7), mortar)
        img.putpixel((x, 11), mortar)
        img.putpixel((x, 15), mortar)

    # Mortar lines (vertical, offset per row)
    for y in range(0, 4):
        img.putpixel((7, y), mortar)
    for y in range(4, 8):
        img.putpixel((3, y), mortar)
        img.putpixel((11, y), mortar)
    for y in range(8, 12):
        img.putpixel((7, y), mortar)
    for y in range(12, 16):
        img.putpixel((3, y), mortar)
        img.putpixel((11, y), mortar)

    # Spray paint heart shape in magenta (centered around 7,7)
    heart_pixels = [
        # Top bumps
        (5, 4), (6, 4), (8, 4), (9, 4),
        (4, 5), (5, 5), (6, 5), (7, 5), (8, 5), (9, 5), (10, 5),
        (4, 6), (5, 6), (6, 6), (7, 6), (8, 6), (9, 6), (10, 6),
        # Middle body
        (5, 7), (6, 7), (7, 7), (8, 7), (9, 7),
        # Taper
        (6, 8), (7, 8), (8, 8),
        (7, 9),
    ]
    for px, py in heart_pixels:
        img.putpixel((px, py), magenta)

    # Highlight on top bumps
    img.putpixel((5, 4), mag_light)
    img.putpixel((9, 4), mag_light)

    # Drip below heart
    img.putpixel((7, 10), drip)
    img.putpixel((7, 11), drip)
    img.putpixel((5, 9), drip)
    img.putpixel((5, 10), drip)

    img.save(os.path.join(COLLECTIBLES_DIR, "graffiti.png"))
    print("  [OK] graffiti.png")


# =============================================================================
# 4. safe_spot.png (16x16)
# =============================================================================
def make_safe_spot():
    img = Image.new("RGBA", (16, 16), T)
    cx, cy = 7.5, 7.5

    # Warm glow background
    for y in range(16):
        for x in range(16):
            dist = math.sqrt((x - cx) ** 2 + (y - cy) ** 2)
            if dist <= 3.0:
                img.putpixel((x, y), (221, 204, 68, 200))
            elif dist <= 5.0:
                alpha = int(160 * (1.0 - (dist - 3.0) / 2.0))
                alpha = max(0, min(255, alpha))
                img.putpixel((x, y), (221, 204, 68, alpha))
            elif dist <= 7.5:
                alpha = int(80 * (1.0 - (dist - 5.0) / 2.5))
                alpha = max(0, min(255, alpha))
                img.putpixel((x, y), (200, 180, 60, alpha))

    bench_brown = (139, 107, 74, 255)
    bench_top = (160, 130, 90, 255)

    # Small bench shape in center-bottom area
    # Seat (horizontal plank)
    for x in range(5, 12):
        img.putpixel((x, 9), bench_top)
        img.putpixel((x, 10), bench_brown)

    # Legs
    img.putpixel((5, 11), bench_brown)
    img.putpixel((5, 12), bench_brown)
    img.putpixel((11, 11), bench_brown)
    img.putpixel((11, 12), bench_brown)

    # Back rest
    for x in range(5, 12):
        img.putpixel((x, 8), bench_brown)
    img.putpixel((5, 7), bench_brown)
    img.putpixel((11, 7), bench_brown)

    # Warm highlight sparkles
    highlights = [(4, 4), (10, 3), (3, 8), (12, 6), (7, 2)]
    for hx, hy in highlights:
        img.putpixel((hx, hy), (255, 240, 150, 180))

    img.save(os.path.join(COLLECTIBLES_DIR, "safe_spot.png"))
    print("  [OK] safe_spot.png")


# =============================================================================
# 5. heart_full.png (8x8)
# =============================================================================
def make_heart_full():
    img = Image.new("RGBA", (8, 8), T)
    red = (224, 32, 32, 255)
    highlight = (255, 96, 96, 255)

    heart = [
        [],                          # row 0
        [1, 2, 5, 6],               # row 1 - two bumps
        [0, 1, 2, 3, 4, 5, 6, 7],   # row 2
        [0, 1, 2, 3, 4, 5, 6, 7],   # row 3
        [1, 2, 3, 4, 5, 6],         # row 4
        [2, 3, 4, 5],               # row 5
        [3, 4],                      # row 6
        [],                          # row 7
    ]

    for y, row in enumerate(heart):
        for x in row:
            img.putpixel((x, y), red)

    # Highlight at top-left of each bump
    img.putpixel((1, 1), highlight)
    img.putpixel((5, 1), highlight)

    img.save(os.path.join(UI_DIR, "heart_full.png"))
    print("  [OK] heart_full.png")


# =============================================================================
# 6. heart_half.png (8x8)
# =============================================================================
def make_heart_half():
    img = Image.new("RGBA", (8, 8), T)
    red = (224, 32, 32, 255)
    gray = (64, 64, 64, 255)
    highlight = (255, 96, 96, 255)

    heart = [
        [],                          # row 0
        [1, 2, 5, 6],               # row 1
        [0, 1, 2, 3, 4, 5, 6, 7],   # row 2
        [0, 1, 2, 3, 4, 5, 6, 7],   # row 3
        [1, 2, 3, 4, 5, 6],         # row 4
        [2, 3, 4, 5],               # row 5
        [3, 4],                      # row 6
        [],                          # row 7
    ]

    mid = 4  # dividing line: left half = x < 4

    for y, row in enumerate(heart):
        for x in row:
            if x < mid:
                img.putpixel((x, y), red)
            else:
                img.putpixel((x, y), gray)

    # Highlight on left bump only
    img.putpixel((1, 1), highlight)

    img.save(os.path.join(UI_DIR, "heart_half.png"))
    print("  [OK] heart_half.png")


# =============================================================================
# 7. heart_empty.png (8x8)
# =============================================================================
def make_heart_empty():
    img = Image.new("RGBA", (8, 8), T)
    dark = (64, 64, 64, 255)
    inner = (80, 80, 80, 255)

    # Outline of heart
    outline = [
        [],
        [1, 2, 5, 6],
        [0, 7],
        [0, 7],
        [1, 6],
        [2, 5],
        [3, 4],
        [],
    ]

    # Interior fill
    interior = [
        [],
        [],
        [1, 2, 3, 4, 5, 6],
        [1, 2, 3, 4, 5, 6],
        [2, 3, 4, 5],
        [3, 4],
        [],
        [],
    ]

    for y, row in enumerate(interior):
        for x in row:
            img.putpixel((x, y), inner)

    for y, row in enumerate(outline):
        for x in row:
            img.putpixel((x, y), dark)

    img.save(os.path.join(UI_DIR, "heart_empty.png"))
    print("  [OK] heart_empty.png")


# =============================================================================
# 8. soul_heart.png (16x16) - Undertale-style soul heart
# =============================================================================
def make_soul_heart():
    img = Image.new("RGBA", (16, 16), T)
    red = (255, 0, 0, 255)
    highlight = (255, 255, 255, 255)
    dark_red = (200, 0, 0, 255)

    # Heart shape rows (scaled up for 16x16)
    heart = {
        2:  [3, 4, 5, 6, 9, 10, 11, 12],
        3:  [2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13],
        4:  [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14],
        5:  [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14],
        6:  [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14],
        7:  [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14],
        8:  [2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13],
        9:  [3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
        10: [4, 5, 6, 7, 8, 9, 10, 11],
        11: [5, 6, 7, 8, 9, 10],
        12: [6, 7, 8, 9],
        13: [7, 8],
    }

    for y, cols in heart.items():
        for x in cols:
            img.putpixel((x, y), red)

    # Slight dark edge at bottom for depth
    for x in heart.get(13, []):
        img.putpixel((x, 13), dark_red)
    for x in [6, 9]:
        img.putpixel((x, 12), dark_red)

    # White highlight pixel (top-left of left bump)
    img.putpixel((4, 3), highlight)
    img.putpixel((4, 4), highlight)

    img.save(os.path.join(UI_DIR, "soul_heart.png"))
    print("  [OK] soul_heart.png")


# =============================================================================
# 9. arrow_continue.png (8x8) - downward triangle
# =============================================================================
def make_arrow_continue():
    img = Image.new("RGBA", (8, 8), T)
    white = (255, 255, 255, 255)

    # Downward pointing triangle
    triangle = {
        1: [1, 2, 3, 4, 5, 6],
        2: [1, 2, 3, 4, 5, 6],
        3: [2, 3, 4, 5],
        4: [2, 3, 4, 5],
        5: [3, 4],
        6: [3, 4],
    }

    for y, cols in triangle.items():
        for x in cols:
            img.putpixel((x, y), white)

    img.save(os.path.join(UI_DIR, "arrow_continue.png"))
    print("  [OK] arrow_continue.png")


# =============================================================================
# 10. interact_icon.png (16x16) - "E" key icon
# =============================================================================
def make_interact_icon():
    img = Image.new("RGBA", (16, 16), T)
    bg = (240, 232, 208, 255)
    border_c = (139, 123, 91, 255)
    dark = (42, 42, 42, 255)

    # Rounded square background (rows 1-14, cols 1-14, with rounded corners)
    for y in range(1, 15):
        for x in range(1, 15):
            img.putpixel((x, y), bg)

    # Remove corner pixels for roundedness
    corners = [(1, 1), (14, 1), (1, 14), (14, 14)]
    for cx, cy in corners:
        img.putpixel((cx, cy), T)

    # Border - top
    for x in range(2, 14):
        img.putpixel((x, 0), border_c)
    # Border - bottom
    for x in range(2, 14):
        img.putpixel((x, 15), border_c)
    # Border - left
    for y in range(2, 14):
        img.putpixel((0, y), border_c)
    # Border - right
    for y in range(2, 14):
        img.putpixel((15, y), border_c)

    # Rounded corners of border
    img.putpixel((1, 0), border_c)
    img.putpixel((14, 0), border_c)
    img.putpixel((0, 1), border_c)
    img.putpixel((15, 1), border_c)
    img.putpixel((1, 15), border_c)
    img.putpixel((14, 15), border_c)
    img.putpixel((0, 14), border_c)
    img.putpixel((15, 14), border_c)

    # Letter "E" in center (dark color)
    # E spans roughly cols 5-10, rows 4-12
    # Vertical bar
    for y in range(4, 13):
        img.putpixel((5, y), dark)
        img.putpixel((6, y), dark)

    # Top horizontal bar
    for x in range(5, 11):
        img.putpixel((x, 4), dark)
        img.putpixel((x, 5), dark)

    # Middle horizontal bar
    for x in range(5, 10):
        img.putpixel((x, 8), dark)

    # Bottom horizontal bar
    for x in range(5, 11):
        img.putpixel((x, 11), dark)
        img.putpixel((x, 12), dark)

    img.save(os.path.join(UI_DIR, "interact_icon.png"))
    print("  [OK] interact_icon.png")


# =============================================================================
# 11. diary_icon.png (16x16)
# =============================================================================
def make_diary_icon():
    img = Image.new("RGBA", (16, 16), T)
    cover = (139, 107, 58, 255)
    front = (160, 136, 74, 255)
    spine = (100, 76, 40, 255)
    clasp = (204, 170, 68, 255)
    pages = (240, 235, 220, 255)
    dark = (80, 60, 30, 255)

    # Back cover (slightly offset)
    for y in range(2, 15):
        for x in range(3, 14):
            img.putpixel((x, y), cover)

    # Spine (left edge)
    for y in range(1, 15):
        img.putpixel((2, y), spine)
        img.putpixel((3, y), spine)

    # Page edges visible between covers
    for y in range(3, 14):
        img.putpixel((4, y), pages)

    # Front cover (main face)
    for y in range(1, 14):
        for x in range(5, 14):
            img.putpixel((x, y), front)

    # Top and bottom edges
    for x in range(4, 14):
        img.putpixel((x, 1), cover)
        img.putpixel((x, 14), cover)

    # Dark line details on cover
    for x in range(6, 13):
        img.putpixel((x, 3), dark)
        img.putpixel((x, 12), dark)
    for y in range(3, 13):
        img.putpixel((6, y), dark)
        img.putpixel((12, y), dark)

    # Clasp/strap on right edge
    for y in range(6, 9):
        img.putpixel((13, y), clasp)
        img.putpixel((14, y), clasp)

    # Center decoration on cover (small diamond)
    img.putpixel((9, 6), clasp)
    img.putpixel((8, 7), clasp)
    img.putpixel((9, 7), clasp)
    img.putpixel((10, 7), clasp)
    img.putpixel((9, 8), clasp)

    img.save(os.path.join(UI_DIR, "diary_icon.png"))
    print("  [OK] diary_icon.png")


# =============================================================================
# 12. guitar_icon.png (16x16)
# =============================================================================
def make_guitar_icon():
    img = Image.new("RGBA", (16, 16), T)
    body = (123, 91, 42, 255)
    front = (160, 136, 80, 255)
    sound_hole = (42, 26, 10, 255)
    neck = (100, 76, 40, 255)
    neck_light = (139, 107, 58, 255)
    strings = (200, 190, 160, 255)
    pegs = (80, 60, 30, 255)
    headstock = (90, 66, 30, 255)

    # Guitar body (round-ish, lower portion) rows 8-14
    body_shape = {
        7:  [6, 7, 8, 9],
        8:  [5, 6, 7, 8, 9, 10],
        9:  [4, 5, 6, 7, 8, 9, 10, 11],
        10: [4, 5, 6, 7, 8, 9, 10, 11],
        11: [4, 5, 6, 7, 8, 9, 10, 11],
        12: [5, 6, 7, 8, 9, 10],
        13: [6, 7, 8, 9],
    }

    # Draw body outline
    for y, cols in body_shape.items():
        for x in cols:
            img.putpixel((x, y), body)

    # Front face (lighter inner area)
    front_shape = {
        8:  [6, 7, 8, 9],
        9:  [5, 6, 7, 8, 9, 10],
        10: [5, 6, 7, 8, 9, 10],
        11: [5, 6, 7, 8, 9, 10],
        12: [6, 7, 8, 9],
    }
    for y, cols in front_shape.items():
        for x in cols:
            img.putpixel((x, y), front)

    # Sound hole (dark circle in center of body)
    hole = {
        9:  [7, 8],
        10: [7, 8],
    }
    for y, cols in hole.items():
        for x in cols:
            img.putpixel((x, y), sound_hole)

    # Bridge
    for x in range(6, 10):
        img.putpixel((x, 12), body)

    # Neck (going up from body)
    for y in range(2, 8):
        img.putpixel((7, y), neck)
        img.putpixel((8, y), neck_light)

    # Headstock at top
    for x in range(6, 10):
        img.putpixel((x, 1), headstock)
        img.putpixel((x, 0), headstock)

    # Tuning pegs
    img.putpixel((5, 0), pegs)
    img.putpixel((5, 1), pegs)
    img.putpixel((10, 0), pegs)
    img.putpixel((10, 1), pegs)

    # Strings on neck
    for y in range(2, 13):
        img.putpixel((7, y), strings)

    # Nut (where neck meets headstock)
    for x in range(6, 10):
        img.putpixel((x, 2), neck)

    img.save(os.path.join(UI_DIR, "guitar_icon.png"))
    print("  [OK] guitar_icon.png")


# =============================================================================
# Run all generators
# =============================================================================
if __name__ == "__main__":
    print("Generating collectible sprites...")
    make_comic_page()
    make_grandma_memory()
    make_graffiti()
    make_safe_spot()

    print("\nGenerating UI sprites...")
    make_heart_full()
    make_heart_half()
    make_heart_empty()
    make_soul_heart()
    make_arrow_continue()
    make_interact_icon()
    make_diary_icon()
    make_guitar_icon()

    print("\nAll 12 sprites generated successfully!")
