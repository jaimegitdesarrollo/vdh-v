#!/usr/bin/env python3
"""
SNES-style (16-bit era) pixel art sprite generator.
Style: Final Fantasy VI / Zelda: A Link to the Past
All sprites use transparent backgrounds with proper shading (3+ tones).
"""

from PIL import Image
import math
import os

COLLECTIBLES = "/Users/macbook/Flat101/godtest/vdh-godot/assets/sprites/collectibles/"
UI = "/Users/macbook/Flat101/godtest/vdh-godot/assets/sprites/ui/"

T = (0, 0, 0, 0)  # transparent


def px(img, x, y, color):
    """Set pixel with bounds checking."""
    if 0 <= x < img.width and 0 <= y < img.height:
        if len(color) == 3:
            color = color + (255,)
        img.putpixel((x, y), color)


def fill_rect(img, x0, y0, x1, y1, color):
    """Fill a rectangle inclusive."""
    if len(color) == 3:
        color = color + (255,)
    for yy in range(y0, y1 + 1):
        for xx in range(x0, x1 + 1):
            px(img, xx, yy, color)


def paint_shape(img, rows, body_color, rim_color, dark_color):
    """Paint a silhouette from string rows with rim lighting and dark core."""
    filled = set()
    for y, row in enumerate(rows):
        for x, ch in enumerate(row):
            if ch == 'x':
                filled.add((x, y))
                img.putpixel((x, y), body_color)

    # Rim light on right side and top
    for (fx, fy) in filled:
        if (fx + 1, fy) not in filled:
            img.putpixel((fx, fy), rim_color)
        elif (fx, fy - 1) not in filled and fy > 0:
            img.putpixel((fx, fy), rim_color)

    # Dark core for deep interior pixels
    for (fx, fy) in filled:
        if all((fx + dx, fy + dy) in filled for dx in [-2, 0, 2] for dy in [-2, 0, 2] if not (dx == 0 and dy == 0)):
            img.putpixel((fx, fy), dark_color)


# =============================================================================
# 1. COMIC PAGE (16x16)
# =============================================================================
def make_comic_page():
    img = Image.new("RGBA", (16, 16), T)
    border = (24, 20, 37, 255)
    paper = (240, 240, 232, 255)
    shadow = (216, 216, 208, 255)
    fold_light = (200, 200, 192, 255)
    fold_dark = (180, 180, 172, 255)
    red = (204, 68, 68, 255)
    blue = (68, 102, 170, 255)
    black = (24, 20, 37, 255)
    dither = (228, 228, 220, 255)

    # Paper body (rows 2-14, cols 2-13)
    for y in range(2, 15):
        for x in range(2, 14):
            img.putpixel((x, y), paper)

    # Dithering texture
    for y in range(3, 14):
        for x in range(3, 13):
            if (x + y) % 5 == 0:
                img.putpixel((x, y), dither)

    # Shadow on right and bottom edges of paper
    for y in range(3, 15):
        img.putpixel((13, y), shadow)
    for x in range(3, 14):
        img.putpixel((x, 14), shadow)

    # Border
    for x in range(2, 14):
        px(img, x, 1, border)
        px(img, x, 15, border)
    for y in range(1, 16):
        px(img, 1, y, border)
        px(img, 14, y, border)

    # Folded corner (top-right): cut triangle and draw fold
    # Remove paper from corner area
    for pos in [(12, 2), (13, 2), (13, 3)]:
        img.putpixel(pos, T)
    # Border adjustments for fold
    px(img, 14, 2, T)
    px(img, 14, 3, T)
    px(img, 13, 1, T)
    px(img, 12, 1, border)
    # Fold triangle
    px(img, 11, 2, fold_light)
    px(img, 12, 2, fold_dark)
    px(img, 11, 3, paper)
    px(img, 12, 3, fold_dark)
    px(img, 13, 3, fold_dark)
    px(img, 13, 4, border)
    px(img, 14, 4, border)

    # Comic panels inside
    # Panel 1: red (top-left)
    fill_rect(img, 3, 4, 6, 6, red)
    for x in range(3, 7):
        px(img, x, 4, black)
        px(img, x, 6, black)
    px(img, 3, 5, black)
    px(img, 6, 5, black)

    # Panel 2: blue (top-right area)
    fill_rect(img, 7, 4, 10, 6, blue)
    for x in range(7, 11):
        px(img, x, 4, black)
        px(img, x, 6, black)
    px(img, 7, 5, black)
    px(img, 10, 5, black)

    # Panel 3: larger bottom panel
    for x in range(3, 11):
        px(img, x, 8, black)
        px(img, x, 12, black)
    for y in range(8, 13):
        px(img, 3, y, black)
        px(img, 10, y, black)
    # Tiny sketch lines inside
    px(img, 5, 9, black)
    px(img, 6, 9, black)
    px(img, 7, 9, black)
    px(img, 5, 10, red)
    px(img, 6, 10, blue)
    px(img, 8, 10, black)
    px(img, 5, 11, black)
    px(img, 6, 11, black)

    img.save(COLLECTIBLES + "comic_page.png")
    print("  [OK] comic_page.png")


# =============================================================================
# 2. GRANDMA MEMORY (16x16)
# =============================================================================
def make_grandma_memory():
    img = Image.new("RGBA", (16, 16), T)
    cx, cy = 7.5, 7.5

    glow_rings = [
        (1.5, (255, 255, 220, 255)),   # white-hot core
        (2.5, (255, 232, 136, 255)),    # bright core
        (3.5, (221, 187, 68, 255)),     # golden center
        (4.8, (204, 170, 51, 230)),     # mid glow
        (6.0, (170, 136, 34, 180)),     # outer glow
        (7.5, (140, 110, 28, 100)),     # fading
        (9.0, (120, 95, 22, 50)),       # near transparent
    ]

    for y in range(16):
        for x in range(16):
            d = math.sqrt((x - cx) ** 2 + (y - cy) ** 2)
            for max_d, col in glow_rings:
                if d <= max_d:
                    img.putpixel((x, y), col)
                    break

    # Sparkles at cardinal points
    white = (255, 255, 255, 255)
    bright = (255, 245, 200, 220)
    for sx, sy in [(7, 1), (8, 1)]:
        px(img, sx, sy, white)
    for sx, sy in [(7, 0), (8, 0)]:
        px(img, sx, sy, bright)
    for sx, sy in [(7, 14), (8, 14)]:
        px(img, sx, sy, white)
    for sx, sy in [(7, 15), (8, 15)]:
        px(img, sx, sy, bright)
    for sx, sy in [(1, 7), (1, 8)]:
        px(img, sx, sy, white)
    for sx, sy in [(0, 7), (0, 8)]:
        px(img, sx, sy, bright)
    for sx, sy in [(14, 7), (14, 8)]:
        px(img, sx, sy, white)
    for sx, sy in [(15, 7), (15, 8)]:
        px(img, sx, sy, bright)

    # Diagonal sparkle hints
    for pos in [(3, 3), (12, 3), (3, 12), (12, 12)]:
        px(img, pos[0], pos[1], (255, 255, 255, 160))

    img.save(COLLECTIBLES + "grandma_memory.png")
    print("  [OK] grandma_memory.png")


# =============================================================================
# 3. GRAFFITI (16x16)
# =============================================================================
def make_graffiti():
    img = Image.new("RGBA", (16, 16), T)
    base = (112, 112, 112, 255)
    brick_shadow = (96, 96, 96, 255)
    mortar = (136, 136, 136, 255)
    dark_brick = (88, 88, 88, 255)

    # Brick pattern fill
    for y in range(16):
        for x in range(16):
            if y % 4 == 0:
                img.putpixel((x, y), mortar)
            elif x % 8 == (0 if (y // 4) % 2 == 0 else 4):
                img.putpixel((x, y), mortar)
            else:
                bx = x % 8
                by = y % 4
                if bx < 2 and by < 2:
                    img.putpixel((x, y), brick_shadow)
                elif bx > 5 and by > 2:
                    img.putpixel((x, y), dark_brick)
                else:
                    img.putpixel((x, y), base)

    # Spray-painted heart
    heart_base = (221, 68, 170, 255)
    heart_hi = (255, 102, 204, 255)
    heart_sh = (187, 34, 136, 255)

    heart_coords = [
        (5, 3), (6, 3), (9, 3), (10, 3),
        (4, 4), (5, 4), (6, 4), (7, 4), (8, 4), (9, 4), (10, 4), (11, 4),
        (4, 5), (5, 5), (6, 5), (7, 5), (8, 5), (9, 5), (10, 5), (11, 5),
        (4, 6), (5, 6), (6, 6), (7, 6), (8, 6), (9, 6), (10, 6), (11, 6),
        (5, 7), (6, 7), (7, 7), (8, 7), (9, 7), (10, 7),
        (6, 8), (7, 8), (8, 8), (9, 8),
        (7, 9), (8, 9),
        (7, 10),
    ]
    for hx, hy in heart_coords:
        img.putpixel((hx, hy), heart_base)

    # Highlights (upper bumps)
    for hx, hy in [(5, 3), (6, 3), (4, 4), (5, 4), (9, 3), (10, 3), (5, 5), (6, 4)]:
        px(img, hx, hy, heart_hi)

    # Shadows (bottom-right)
    for hx, hy in [(10, 7), (9, 8), (8, 9), (7, 10), (11, 5), (11, 6), (10, 6)]:
        px(img, hx, hy, heart_sh)

    # Paint drips
    px(img, 7, 11, (221, 68, 170, 200))
    px(img, 7, 12, (221, 68, 170, 140))
    px(img, 9, 9, (221, 68, 170, 200))
    px(img, 9, 10, (221, 68, 170, 200))
    px(img, 9, 11, (221, 68, 170, 140))

    img.save(COLLECTIBLES + "graffiti.png")
    print("  [OK] graffiti.png")


# =============================================================================
# 4. SAFE SPOT (16x16)
# =============================================================================
def make_safe_spot():
    img = Image.new("RGBA", (16, 16), T)
    cx, cy = 7.5, 7.5

    # Radial warm glow
    for y in range(16):
        for x in range(16):
            d = math.sqrt((x - cx) ** 2 + (y - cy) ** 2)
            if d <= 2.5:
                img.putpixel((x, y), (255, 238, 136, 200))
            elif d <= 4.5:
                img.putpixel((x, y), (221, 204, 85, 150))
            elif d <= 6.5:
                img.putpixel((x, y), (170, 153, 51, 100))
            elif d <= 8.5:
                img.putpixel((x, y), (140, 125, 40, 50))

    # Bench
    bench_base = (123, 91, 58, 255)
    bench_sh = (90, 58, 32, 255)
    bench_hi = (155, 123, 90, 255)

    # Backrest
    for x in range(5, 12):
        px(img, x, 6, bench_sh)
        px(img, x, 7, bench_base)
    px(img, 5, 7, bench_hi)
    px(img, 6, 6, bench_hi)

    # Seat
    for x in range(5, 12):
        px(img, x, 8, bench_hi)
        px(img, x, 9, bench_base)

    # Legs
    for y in [10, 11]:
        px(img, 5, y, bench_sh)
        px(img, 11, y, bench_sh)
    px(img, 6, 10, bench_base)
    px(img, 10, 10, bench_base)

    # Sparkles
    white = (255, 255, 255, 255)
    dim = (255, 255, 220, 180)
    for sx, sy in [(3, 2), (12, 4), (10, 2), (11, 13)]:
        px(img, sx, sy, white)
    for sx, sy in [(2, 10), (13, 6), (5, 13), (1, 5)]:
        px(img, sx, sy, dim)

    img.save(COLLECTIBLES + "safe_spot.png")
    print("  [OK] safe_spot.png")


# =============================================================================
# 5. HEART FULL (8x8)
# =============================================================================
def make_heart_full():
    img = Image.new("RGBA", (8, 8), T)
    base = (224, 32, 32, 255)
    hi = (255, 64, 64, 255)
    sh = (170, 24, 24, 255)
    dk = (130, 16, 16, 255)

    shape = [
        [0, 0, 0, 0, 0, 0, 0, 0],
        [0, 1, 1, 0, 0, 1, 1, 0],
        [1, 1, 1, 1, 1, 1, 1, 1],
        [1, 1, 1, 1, 1, 1, 1, 1],
        [0, 1, 1, 1, 1, 1, 1, 0],
        [0, 0, 1, 1, 1, 1, 0, 0],
        [0, 0, 0, 1, 1, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0],
    ]

    hi_set = {(1, 1), (2, 1), (5, 1), (6, 1), (1, 2), (2, 2), (5, 2), (6, 2), (0, 2), (0, 3)}
    sh_set = {(7, 2), (7, 3), (6, 4), (5, 5), (4, 5), (4, 6), (3, 6), (6, 3)}
    dk_set = {(7, 3), (6, 4), (5, 5), (4, 6)}

    for y in range(8):
        for x in range(8):
            if shape[y][x]:
                if (x, y) in dk_set:
                    img.putpixel((x, y), dk)
                elif (x, y) in sh_set:
                    img.putpixel((x, y), sh)
                elif (x, y) in hi_set:
                    img.putpixel((x, y), hi)
                else:
                    img.putpixel((x, y), base)

    img.save(UI + "heart_full.png")
    print("  [OK] heart_full.png")


# =============================================================================
# 6. HEART HALF (8x8)
# =============================================================================
def make_heart_half():
    img = Image.new("RGBA", (8, 8), T)
    red_base = (224, 32, 32, 255)
    red_hi = (255, 64, 64, 255)
    red_sh = (170, 24, 24, 255)
    gray_base = (64, 64, 64, 255)
    gray_hi = (80, 80, 80, 255)
    gray_sh = (48, 48, 48, 255)

    shape = [
        [0, 0, 0, 0, 0, 0, 0, 0],
        [0, 1, 1, 0, 0, 1, 1, 0],
        [1, 1, 1, 1, 1, 1, 1, 1],
        [1, 1, 1, 1, 1, 1, 1, 1],
        [0, 1, 1, 1, 1, 1, 1, 0],
        [0, 0, 1, 1, 1, 1, 0, 0],
        [0, 0, 0, 1, 1, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0],
    ]

    for y in range(8):
        for x in range(8):
            if shape[y][x]:
                if x < 4:  # Left = red
                    if y <= 2 and x <= 2:
                        img.putpixel((x, y), red_hi)
                    elif y >= 5 or x >= 3:
                        img.putpixel((x, y), red_sh)
                    else:
                        img.putpixel((x, y), red_base)
                else:  # Right = gray
                    if y <= 2 and x >= 5:
                        img.putpixel((x, y), gray_hi)
                    elif y >= 5 or x >= 6:
                        img.putpixel((x, y), gray_sh)
                    else:
                        img.putpixel((x, y), gray_base)

    img.save(UI + "heart_half.png")
    print("  [OK] heart_half.png")


# =============================================================================
# 7. HEART EMPTY (8x8)
# =============================================================================
def make_heart_empty():
    img = Image.new("RGBA", (8, 8), T)
    outline = (64, 64, 64, 255)
    fill = (53, 53, 53, 255)
    hi = (69, 69, 69, 255)
    inner_sh = (40, 40, 40, 255)

    shape = [
        [0, 0, 0, 0, 0, 0, 0, 0],
        [0, 1, 1, 0, 0, 1, 1, 0],
        [1, 1, 1, 1, 1, 1, 1, 1],
        [1, 1, 1, 1, 1, 1, 1, 1],
        [0, 1, 1, 1, 1, 1, 1, 0],
        [0, 0, 1, 1, 1, 1, 0, 0],
        [0, 0, 0, 1, 1, 0, 0, 0],
        [0, 0, 0, 0, 0, 0, 0, 0],
    ]

    outline_set = set()
    for y in range(8):
        for x in range(8):
            if shape[y][x]:
                for dx, dy in [(-1, 0), (1, 0), (0, -1), (0, 1)]:
                    nx, ny = x + dx, y + dy
                    if nx < 0 or nx >= 8 or ny < 0 or ny >= 8 or not shape[ny][nx]:
                        outline_set.add((x, y))
                        break

    for y in range(8):
        for x in range(8):
            if shape[y][x]:
                if (x, y) in outline_set:
                    img.putpixel((x, y), outline)
                elif y <= 3:
                    img.putpixel((x, y), hi)
                elif y >= 5:
                    img.putpixel((x, y), inner_sh)
                else:
                    img.putpixel((x, y), fill)

    img.save(UI + "heart_empty.png")
    print("  [OK] heart_empty.png")


# =============================================================================
# 8. SOUL HEART (16x16)
# =============================================================================
def make_soul_heart():
    img = Image.new("RGBA", (16, 16), T)
    base = (255, 0, 0, 255)
    hi = (255, 68, 68, 255)
    shadow = (204, 0, 0, 255)
    outline_col = (136, 0, 0, 255)
    white = (255, 255, 255, 255)
    bright_hi = (255, 120, 120, 255)

    rows = [
        "                ",  # 0
        "  xxxx  xxxx    ",  # 1
        " xxxxxx xxxxxx  ",  # 2 (note: 7th col is gap between bumps)
        " xxxxxxxxxxxxxx ",  # 3
        " xxxxxxxxxxxxxx ",  # 4
        " xxxxxxxxxxxxxx ",  # 5
        "  xxxxxxxxxxxx  ",  # 6
        "  xxxxxxxxxxxx  ",  # 7
        "   xxxxxxxxxx   ",  # 8
        "    xxxxxxxx    ",  # 9
        "     xxxxxx     ",  # 10
        "      xxxx      ",  # 11
        "       xx       ",  # 12
        "                ",  # 13
        "                ",  # 14
        "                ",  # 15
    ]

    filled = set()
    for y, row in enumerate(rows):
        for x, ch in enumerate(row):
            if ch == 'x':
                filled.add((x, y))

    outline_set = set()
    for (fx, fy) in filled:
        for dx, dy in [(-1, 0), (1, 0), (0, -1), (0, 1), (-1, -1), (1, -1), (-1, 1), (1, 1)]:
            if (fx + dx, fy + dy) not in filled:
                outline_set.add((fx, fy))
                break

    for (x, y) in filled:
        if (x, y) in outline_set:
            img.putpixel((x, y), outline_col)
        elif y <= 4 and x <= 7:
            img.putpixel((x, y), hi)
        elif y >= 9:
            img.putpixel((x, y), shadow)
        else:
            img.putpixel((x, y), base)

    # White highlights on upper bumps
    for hx, hy in [(3, 2), (4, 2), (3, 3), (10, 2), (11, 2), (10, 3)]:
        if (hx, hy) in filled:
            img.putpixel((hx, hy), white)
    for hx, hy in [(4, 3), (5, 2), (11, 3), (12, 2)]:
        if (hx, hy) in filled:
            img.putpixel((hx, hy), bright_hi)

    img.save(UI + "soul_heart.png")
    print("  [OK] soul_heart.png")


# =============================================================================
# 9. ARROW CONTINUE (8x8)
# =============================================================================
def make_arrow_continue():
    img = Image.new("RGBA", (8, 8), T)
    white = (255, 255, 255, 255)
    shadow = (192, 192, 192, 255)
    dk_shadow = (160, 160, 160, 255)

    arrow = [
        "        ",
        " xxxxxx ",
        " xxxxxx ",
        "  xxxx  ",
        "  xxxx  ",
        "   xx   ",
        "   xx   ",
        "        ",
    ]

    for y in range(8):
        for x in range(8):
            if arrow[y][x] == 'x':
                right_edge = (x + 1 >= 8 or arrow[y][x + 1] == ' ')
                bot_edge = (y + 1 >= 8 or arrow[y + 1][x] == ' ')
                if right_edge and bot_edge:
                    img.putpixel((x, y), dk_shadow)
                elif right_edge or bot_edge:
                    img.putpixel((x, y), shadow)
                else:
                    img.putpixel((x, y), white)

    img.save(UI + "arrow_continue.png")
    print("  [OK] arrow_continue.png")


# =============================================================================
# 10. INTERACT ICON (16x16)
# =============================================================================
def make_interact_icon():
    img = Image.new("RGBA", (16, 16), T)
    bg_base = (232, 224, 200, 255)
    bg_shadow = (208, 200, 176, 255)
    bg_hi = (240, 232, 216, 255)
    border = (123, 107, 75, 255)
    letter = (42, 42, 42, 255)

    # Rounded rectangle background
    for y in range(1, 15):
        for x in range(1, 15):
            if (x in [1, 14] and y in [1, 14]):
                continue  # skip hard corners
            if y <= 5:
                img.putpixel((x, y), bg_hi)
            elif y >= 11:
                img.putpixel((x, y), bg_shadow)
            else:
                img.putpixel((x, y), bg_base)

    # Border
    for x in range(2, 14):
        px(img, x, 0, border)
        px(img, x, 15, border)
    for y in range(2, 14):
        px(img, 0, y, border)
        px(img, 15, y, border)
    # Rounded corner connections
    for cx, cy in [(1, 0), (14, 0), (0, 1), (15, 1), (1, 15), (14, 15), (0, 14), (15, 14), (1, 1), (14, 1), (1, 14), (14, 14)]:
        px(img, cx, cy, border)

    # "E" centered: vertical bar cols 5-6, horizontals extend to col 11
    for y in range(4, 13):
        px(img, 5, y, letter)
        px(img, 6, y, letter)
    # Top bar
    for x in range(5, 12):
        px(img, x, 4, letter)
        px(img, x, 5, letter)
    # Middle bar
    for x in range(5, 11):
        px(img, x, 7, letter)
        px(img, x, 8, letter)
    # Bottom bar
    for x in range(5, 12):
        px(img, x, 11, letter)
        px(img, x, 12, letter)

    img.save(UI + "interact_icon.png")
    print("  [OK] interact_icon.png")


# =============================================================================
# 11. DIARY ICON (16x16)
# =============================================================================
def make_diary_icon():
    img = Image.new("RGBA", (16, 16), T)
    cover = (123, 91, 58, 255)
    cover_sh = (90, 58, 32, 255)
    cover_hi = (155, 123, 90, 255)
    spine_dark = (70, 42, 20, 255)
    spine = (90, 58, 32, 255)
    gold = (204, 170, 68, 255)
    gold_hi = (221, 187, 85, 255)
    pages = (232, 224, 208, 255)
    pages_sh = (210, 200, 185, 255)
    outline = (50, 30, 15, 255)

    # Outline
    for y in range(1, 15):
        px(img, 2, y, outline)
        px(img, 14, y, outline)
    for x in range(2, 15):
        px(img, x, 0, outline)
        px(img, x, 15, outline)

    # Spine (cols 3-4)
    for y in range(1, 15):
        px(img, 3, y, spine_dark)
        px(img, 4, y, spine)

    # Cover
    for y in range(1, 15):
        for x in range(5, 14):
            if y <= 3:
                img.putpixel((x, y), cover_hi)
            elif y >= 12:
                img.putpixel((x, y), cover_sh)
            else:
                img.putpixel((x, y), cover)

    # Page edges (right)
    for y in range(2, 14):
        px(img, 13, y, pages)
        px(img, 12, y, pages_sh)

    # Gold clasp
    for cx, cy in [(12, 7), (13, 7), (14, 7), (12, 8), (13, 8), (14, 8)]:
        px(img, cx, cy, gold)
    px(img, 14, 7, gold_hi)
    px(img, 14, 8, gold_hi)

    # Decorative lines
    for x in range(6, 12):
        px(img, x, 3, cover_sh)
        px(img, x, 12, cover_sh)

    # Diamond on cover center
    px(img, 9, 6, gold)
    px(img, 8, 7, gold)
    px(img, 9, 7, gold_hi)
    px(img, 10, 7, gold)
    px(img, 9, 8, gold)

    img.save(UI + "diary_icon.png")
    print("  [OK] diary_icon.png")


# =============================================================================
# 12. GUITAR ICON (16x16)
# =============================================================================
def make_guitar_icon():
    img = Image.new("RGBA", (16, 16), T)
    body = (123, 91, 42, 255)
    body_sh = (90, 58, 24, 255)
    body_hi = (155, 123, 74, 255)
    front = (160, 136, 80, 255)
    hole = (42, 26, 10, 255)
    neck_col = (100, 75, 35, 255)
    neck_hi = (130, 100, 55, 255)
    fret = (180, 170, 150, 255)
    head = (70, 50, 25, 255)
    peg = (200, 190, 170, 255)
    string = (210, 200, 180, 255)
    bridge = (80, 55, 20, 255)

    # Headstock (top)
    for x in range(6, 11):
        for y in range(0, 2):
            px(img, x, y, head)
    # Tuning pegs
    px(img, 5, 0, peg)
    px(img, 5, 1, peg)
    px(img, 11, 0, peg)
    px(img, 11, 1, peg)

    # Neck (cols 7-9, rows 2-6)
    for y in range(2, 7):
        px(img, 7, y, neck_col)
        px(img, 8, y, neck_hi)
        px(img, 9, y, neck_col)
    # Fret lines
    for fy in [3, 5]:
        for x in range(7, 10):
            px(img, x, fy, fret)

    # Upper bout (rows 7-9)
    for y in range(7, 10):
        for x in range(5, 12):
            if (x == 5 or x == 11) and y == 7:
                continue
            if x <= 6:
                px(img, x, y, body_sh)
            elif x >= 10:
                px(img, x, y, body_sh)
            else:
                px(img, x, y, body)
    # Highlight
    for hx, hy in [(6, 7), (7, 7), (6, 8), (5, 8), (5, 9)]:
        px(img, hx, hy, body_hi)

    # Waist (row 10)
    for x in range(6, 11):
        px(img, x, 10, body)

    # Sound hole
    for hx, hy in [(7, 9), (8, 9), (9, 9), (7, 10), (8, 10), (9, 10)]:
        px(img, hx, hy, hole)

    # Lower bout (rows 11-14, wider)
    for y in range(11, 15):
        for x in range(4, 13):
            if y == 14 and (x == 4 or x == 12):
                continue
            if y == 11 and (x == 4 or x == 12):
                continue
            if 6 <= x <= 10 and 12 <= y <= 13:
                px(img, x, y, front)
            elif x <= 5:
                px(img, x, y, body_sh)
            elif x >= 11:
                px(img, x, y, body_sh)
            else:
                px(img, x, y, body)

    # Bridge
    for x in range(6, 11):
        px(img, x, 13, bridge)

    # Strings
    for y in [2, 4, 6, 8, 11, 12]:
        px(img, 8, y, string)

    img.save(UI + "guitar_icon.png")
    print("  [OK] guitar_icon.png")


# =============================================================================
# 13. PROJ INSULT (16x8)
# =============================================================================
def make_proj_insult():
    img = Image.new("RGBA", (16, 8), T)
    base = (170, 34, 34, 255)
    shadow = (136, 34, 34, 255)
    hi = (204, 68, 68, 255)
    outline = (100, 20, 20, 255)
    text = (224, 224, 224, 255)

    pill = [
        "  xxxxxxxxxxxx  ",
        " xxxxxxxxxxxxxx ",
        "xxxxxxxxxxxxxxxx",
        "xxxxxxxxxxxxxxxx",
        "xxxxxxxxxxxxxxxx",
        "xxxxxxxxxxxxxxxx",
        " xxxxxxxxxxxxxx ",
        "  xxxxxxxxxxxx  ",
    ]

    filled = set()
    for y in range(8):
        for x in range(16):
            if pill[y][x] == 'x':
                filled.add((x, y))

    outline_set = set()
    for (fx, fy) in filled:
        for dx, dy in [(-1, 0), (1, 0), (0, -1), (0, 1)]:
            if (fx + dx, fy + dy) not in filled:
                outline_set.add((fx, fy))
                break

    for (fx, fy) in filled:
        if (fx, fy) in outline_set:
            img.putpixel((fx, fy), outline)
        elif fy <= 2:
            img.putpixel((fx, fy), hi)
        elif fy >= 6:
            img.putpixel((fx, fy), shadow)
        else:
            img.putpixel((fx, fy), base)

    # Squiggly text
    for x in [4, 5, 6, 7, 8, 9, 10, 11]:
        ty = 3 if x % 3 == 0 else 4
        px(img, x, ty, text)

    img.save(UI + "proj_insult.png")
    print("  [OK] proj_insult.png")


# =============================================================================
# 14. PROJ SLAP (12x12)
# =============================================================================
def make_proj_slap():
    img = Image.new("RGBA", (12, 12), T)
    skin = (232, 184, 136, 255)
    skin_sh = (200, 152, 104, 255)
    skin_hi = (255, 208, 168, 255)
    outline = (80, 50, 30, 255)

    fist = [
        "            ",
        "   xxxxxx   ",
        "  xxxxxxxx  ",
        " xxxxxxxxxx ",
        " xxxxxxxxxx ",
        " xxxxxxxxxx ",
        " xxxxxxxxxx ",
        " xxxxxxxxxx ",
        "  xxxxxxxx  ",
        "  xxxxxxxx  ",
        "   xxxxxx   ",
        "            ",
    ]

    filled = set()
    for y in range(12):
        for x in range(12):
            if fist[y][x] == 'x':
                filled.add((x, y))

    outline_set = set()
    for (fx, fy) in filled:
        for dx, dy in [(-1, 0), (1, 0), (0, -1), (0, 1)]:
            if (fx + dx, fy + dy) not in filled:
                outline_set.add((fx, fy))
                break

    for (fx, fy) in filled:
        if (fx, fy) in outline_set:
            img.putpixel((fx, fy), outline)
        elif fx <= 4 and fy <= 4:
            img.putpixel((fx, fy), skin_hi)
        elif fx >= 8 or fy >= 8:
            img.putpixel((fx, fy), skin_sh)
        else:
            img.putpixel((fx, fy), skin)

    # Finger curl lines
    for x in range(4, 9):
        px(img, x, 4, skin_sh)
        px(img, x, 6, skin_sh)
        px(img, x, 8, skin_sh)
    # Knuckle bumps
    for x in range(4, 9):
        px(img, x, 3, skin_hi)

    # Thumb
    px(img, 2, 5, outline)
    px(img, 2, 6, skin_hi)
    px(img, 2, 7, skin)
    px(img, 2, 8, outline)

    img.save(UI + "proj_slap.png")
    print("  [OK] proj_slap.png")


# =============================================================================
# 15. PROJ LAUGH (16x8)
# =============================================================================
def make_proj_laugh():
    img = Image.new("RGBA", (16, 8), T)
    base = (255, 221, 0, 255)
    shadow = (221, 187, 0, 255)
    hi = (255, 238, 68, 255)
    extrude = (180, 150, 0, 255)

    j_pixels = [
        (1, 1), (2, 1), (3, 1), (4, 1), (5, 1),
        (3, 2), (4, 2),
        (3, 3), (4, 3),
        (3, 4), (4, 4),
        (1, 5), (2, 5), (3, 5), (4, 5),
        (1, 4), (2, 4),
        (1, 6), (2, 6),
    ]

    a_pixels = [
        (9, 1), (10, 1),
        (8, 2), (9, 2), (10, 2), (11, 2),
        (7, 3), (8, 3), (11, 3), (12, 3),
        (7, 4), (8, 4), (9, 4), (10, 4), (11, 4), (12, 4),
        (7, 5), (8, 5), (11, 5), (12, 5),
        (7, 6), (8, 6), (11, 6), (12, 6),
    ]

    all_px = j_pixels + a_pixels
    all_set = set(all_px)

    for lx, ly in all_px:
        if ly <= 2:
            img.putpixel((lx, ly), hi)
        elif ly >= 5:
            img.putpixel((lx, ly), shadow)
        else:
            img.putpixel((lx, ly), base)

    # 3D extrusion shadow
    for lx, ly in all_px:
        sx, sy = lx + 1, ly + 1
        if (sx, sy) not in all_set and 0 <= sx < 16 and 0 <= sy < 8:
            px(img, sx, sy, extrude)

    img.save(UI + "proj_laugh.png")
    print("  [OK] proj_laugh.png")


# =============================================================================
# 16. PROJ PAPERBALL (8x8)
# =============================================================================
def make_proj_paperball():
    img = Image.new("RGBA", (8, 8), T)
    base = (232, 224, 208, 255)
    shadow = (208, 200, 184, 255)
    hi = (240, 232, 224, 255)
    fold = (190, 182, 168, 255)
    outline = (150, 140, 125, 255)
    drop = (120, 115, 105, 180)

    ball = [
        "  xxxx  ",
        " xxxxxx ",
        "xxxxxxxx",
        "xxxxxxxx",
        "xxxxxxxx",
        "xxxxxxxx",
        " xxxxxx ",
        "        ",
    ]

    filled = set()
    for y in range(7):
        for x in range(8):
            if ball[y][x] == 'x':
                filled.add((x, y))

    outline_set = set()
    for (fx, fy) in filled:
        for dx, dy in [(-1, 0), (1, 0), (0, -1), (0, 1)]:
            if (fx + dx, fy + dy) not in filled:
                outline_set.add((fx, fy))
                break

    for (fx, fy) in filled:
        if (fx, fy) in outline_set:
            img.putpixel((fx, fy), outline)
        elif fx <= 3 and fy <= 2:
            img.putpixel((fx, fy), hi)
        elif fx >= 5 and fy >= 4:
            img.putpixel((fx, fy), shadow)
        else:
            img.putpixel((fx, fy), base)

    # Crumple lines
    for cx, cy in [(3, 2), (4, 3), (5, 2), (2, 4), (3, 5), (5, 4), (6, 3)]:
        px(img, cx, cy, fold)

    # Drop shadow
    px(img, 3, 7, drop)
    px(img, 4, 7, drop)

    img.save(UI + "proj_paperball.png")
    print("  [OK] proj_paperball.png")


# =============================================================================
# 17. SILHOUETTE BULLY 1 (24x32) — Stocky, menacing
# =============================================================================
def make_silhouette_bully1():
    img = Image.new("RGBA", (24, 32), T)
    sil = [
        "                        ",  # 0
        "        xxxxxx          ",  # 1
        "       xxxxxxxx         ",  # 2
        "       xxxxxxxx         ",  # 3
        "        xxxxxx          ",  # 4
        "         xxxx           ",  # 5
        "     xxxxxxxxxxxx       ",  # 6
        "    xxxxxxxxxxxxxx      ",  # 7
        "   xxxxxxxxxxxxxxxx     ",  # 8
        "  xxxxxxxxxxxxxxxxxx    ",  # 9
        "  xxxxxxxxxxxxxxxxxx    ",  # 10
        "  xxxxxxxxxxxxxxxxxx    ",  # 11
        "  xxxxxxxxxxxxxxxxxx    ",  # 12
        "  xxxxxxxxxxxxxxxxxx    ",  # 13
        "  xxxxxxxxxxxxxxxxxx    ",  # 14
        "  xxxxxxxxxxxxxxxxxx    ",  # 15
        "  xxxxxxxxxxxxxxxxxx    ",  # 16
        "  xxxxxxxxxxxxxxxxxx    ",  # 17
        "   xxxxxxxxxxxxxxxx     ",  # 18
        "   xxxxxxxxxxxxxxxx     ",  # 19
        "    xxxxxxxxxxxxxxxx    ",  # 20
        "    xxxxxxxxxxxxxxxx    ",  # 21
        "    xxxx      xxxxxx    ",  # 22
        "    xxxx      xxxxxx    ",  # 23
        "    xxxx       xxxxx    ",  # 24
        "    xxxx       xxxxx    ",  # 25
        "    xxxx       xxxxx    ",  # 26
        "    xxxx       xxxxx    ",  # 27
        "   xxxxx       xxxxxx   ",  # 28
        "   xxxxx       xxxxxx   ",  # 29
        "                        ",  # 30
        "                        ",  # 31
    ]
    paint_shape(img, sil, (26, 26, 26, 255), (42, 42, 42, 255), (18, 18, 18, 255))
    img.save(UI + "silhouette_bully1.png")
    print("  [OK] silhouette_bully1.png")


# =============================================================================
# 18. SILHOUETTE BULLY 2 (24x32) — Tall thin, arm raised pointing
# =============================================================================
def make_silhouette_bully2():
    img = Image.new("RGBA", (24, 32), T)
    sil = [
        "                        ",  # 0
        "       xxxxx            ",  # 1
        "      xxxxxxx           ",  # 2
        "      xxxxxxx           ",  # 3
        "       xxxxx            ",  # 4
        "        xxx             ",  # 5
        "      xxxxxxxxx         ",  # 6
        "     xxxxxxxxxxx        ",  # 7
        "    xxxxxxxxxxxxx       ",  # 8
        "   xxxxxxxxxxxxxxx      ",  # 9
        "    xxxxxxxxxxxx xxx    ",  # 10
        "     xxxxxxxxxx  xxx   x",  # 11
        "     xxxxxxxxxx   xxx xx",  # 12
        "      xxxxxxxx     xxxx ",  # 13
        "      xxxxxxxx          ",  # 14
        "      xxxxxxxx          ",  # 15
        "      xxxxxxxx          ",  # 16
        "       xxxxxx           ",  # 17
        "       xxxxxx           ",  # 18
        "       xxxxxx           ",  # 19
        "       xxxxxxx          ",  # 20
        "      xxxxxxxx          ",  # 21
        "      xxx  xxxx         ",  # 22
        "      xxx  xxxx         ",  # 23
        "     xxxx   xxxx        ",  # 24
        "     xxxx   xxxx        ",  # 25
        "     xxxx   xxxx        ",  # 26
        "     xxxx   xxxx        ",  # 27
        "    xxxxx   xxxxx       ",  # 28
        "    xxxxx   xxxxx       ",  # 29
        "                        ",  # 30
        "                        ",  # 31
    ]
    paint_shape(img, sil, (26, 26, 26, 255), (42, 42, 42, 255), (18, 18, 18, 255))
    img.save(UI + "silhouette_bully2.png")
    print("  [OK] silhouette_bully2.png")


# =============================================================================
# 19. SILHOUETTE BULLY 3 (24x32) — Medium build, arms crossed
# =============================================================================
def make_silhouette_bully3():
    img = Image.new("RGBA", (24, 32), T)
    sil = [
        "                        ",  # 0
        "        xxxxx           ",  # 1
        "       xxxxxxx          ",  # 2
        "       xxxxxxx          ",  # 3
        "        xxxxx           ",  # 4
        "         xxx            ",  # 5
        "     xxxxxxxxxxx        ",  # 6
        "    xxxxxxxxxxxxx       ",  # 7
        "   xxxxxxxxxxxxxxx      ",  # 8
        "  xxxxx xxxxxxx xxxx    ",  # 9
        "  xxxx  xxxxxxx  xxxx   ",  # 10
        "  xxx   xxxxxxx   xxx   ",  # 11
        "   xx  xxxxxxxxx  xx    ",  # 12
        "    xx xxxxxxxxx xx     ",  # 13
        "     xxxxxxxxxxxx       ",  # 14
        "      xxxxxxxxxx        ",  # 15
        "      xxxxxxxxxx        ",  # 16
        "      xxxxxxxxxx        ",  # 17
        "       xxxxxxxx         ",  # 18
        "       xxxxxxxx         ",  # 19
        "       xxxxxxxx         ",  # 20
        "       xxxxxxxxx        ",  # 21
        "      xxxx  xxxxx       ",  # 22
        "      xxxx  xxxxx       ",  # 23
        "      xxxx   xxxx       ",  # 24
        "     xxxxx   xxxxx      ",  # 25
        "     xxxxx   xxxxx      ",  # 26
        "     xxxxx   xxxxx      ",  # 27
        "    xxxxxx   xxxxxx     ",  # 28
        "    xxxxxx   xxxxxx     ",  # 29
        "                        ",  # 30
        "                        ",  # 31
    ]
    paint_shape(img, sil, (26, 26, 26, 255), (42, 42, 42, 255), (18, 18, 18, 255))
    img.save(UI + "silhouette_bully3.png")
    print("  [OK] silhouette_bully3.png")


# =============================================================================
# 20. SILHOUETTE BULLY 4 (24x32) — Stocky, leaning forward
# =============================================================================
def make_silhouette_bully4():
    img = Image.new("RGBA", (24, 32), T)
    sil = [
        "                        ",  # 0
        "          xxxxx         ",  # 1
        "         xxxxxxx        ",  # 2
        "         xxxxxxx        ",  # 3
        "          xxxxx         ",  # 4
        "          xxxx          ",  # 5
        "       xxxxxxxxxxx      ",  # 6
        "      xxxxxxxxxxxxx     ",  # 7
        "     xxxxxxxxxxxxxxx    ",  # 8
        "     xxxxxxxxxxxxxxx    ",  # 9
        "     xxxxxxxxxxxxxxx    ",  # 10
        "    xxxxxxxxxxxxxxxxx   ",  # 11
        "    xxxxxxxxxxxxxxxxx   ",  # 12
        "    xxxxxxxxxxxxxxxxx   ",  # 13
        "    xxxxxxxxxxxxxxxxx   ",  # 14
        "     xxxxxxxxxxxxxxxx   ",  # 15
        "     xxxxxxxxxxxxxxxx   ",  # 16
        "      xxxxxxxxxxxxxxx   ",  # 17
        "      xxxxxxxxxxxxxxx   ",  # 18
        "       xxxxxxxxxxxx     ",  # 19
        "       xxxxxxxxxxxx     ",  # 20
        "       xxxxxxxxxxxx     ",  # 21
        "       xxxx   xxxxx     ",  # 22
        "      xxxxx   xxxxxx    ",  # 23
        "      xxxxx    xxxxx    ",  # 24
        "      xxxxx    xxxxx    ",  # 25
        "     xxxxxx    xxxxxx   ",  # 26
        "     xxxxxx    xxxxxx   ",  # 27
        "    xxxxxxx    xxxxxxx  ",  # 28
        "    xxxxxxx    xxxxxxx  ",  # 29
        "                        ",  # 30
        "                        ",  # 31
    ]
    # Rim light on LEFT side since leaning right
    body = (26, 26, 26, 255)
    rim = (42, 42, 42, 255)
    dark = (18, 18, 18, 255)

    filled = set()
    for y, row in enumerate(sil):
        for x, ch in enumerate(row):
            if ch == 'x':
                filled.add((x, y))
                img.putpixel((x, y), body)

    # Rim on left side and top
    for (fx, fy) in filled:
        if (fx - 1, fy) not in filled:
            img.putpixel((fx, fy), rim)
        elif (fx, fy - 1) not in filled and fy > 0:
            img.putpixel((fx, fy), rim)

    # Dark core
    for (fx, fy) in filled:
        if all((fx + dx, fy + dy) in filled for dx in [-2, 0, 2] for dy in [-2, 0, 2] if not (dx == 0 and dy == 0)):
            img.putpixel((fx, fy), dark)

    img.save(UI + "silhouette_bully4.png")
    print("  [OK] silhouette_bully4.png")


# =============================================================================
# MAIN
# =============================================================================
if __name__ == "__main__":
    os.makedirs(COLLECTIBLES, exist_ok=True)
    os.makedirs(UI, exist_ok=True)

    print("Generating SNES-style pixel art sprites...")
    print()

    print("COLLECTIBLES:")
    make_comic_page()
    make_grandma_memory()
    make_graffiti()
    make_safe_spot()
    print()

    print("UI - HEARTS:")
    make_heart_full()
    make_heart_half()
    make_heart_empty()
    make_soul_heart()
    print()

    print("UI - INTERFACE:")
    make_arrow_continue()
    make_interact_icon()
    make_diary_icon()
    make_guitar_icon()
    print()

    print("BATTLE PROJECTILES:")
    make_proj_insult()
    make_proj_slap()
    make_proj_laugh()
    make_proj_paperball()
    print()

    print("BULLY SILHOUETTES:")
    make_silhouette_bully1()
    make_silhouette_bully2()
    make_silhouette_bully3()
    make_silhouette_bully4()
    print()

    print("All 20 sprites generated successfully!")
