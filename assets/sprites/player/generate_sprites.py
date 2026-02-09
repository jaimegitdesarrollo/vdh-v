#!/usr/bin/env python3
"""
Generate SNES-style (16-bit era) pixel art sprites for player character "Cristian".
Style: Final Fantasy VI field sprites / Zelda: A Link to the Past.
Size: 16x24 pixels, transparent background, 3/4 top-down perspective.
12 sprites total: 4 idle directions + 8 walk frames.
"""

from PIL import Image
import os

# === COLOR PALETTE ===
T = (0, 0, 0, 0)  # Transparent

# Outline — near-black with slight purple tint (SNES style)
OL = (24, 20, 37, 255)  # #181425

# Hair — brown messy, 3 shades
HB = (107, 66, 38, 255)   # #6B4226 base
HH = (139, 90, 52, 255)   # #8B5A34 highlight
HS = (74, 42, 20, 255)    # #4A2A14 shadow

# Skin — warm tones, 3 shades
SB = (242, 200, 160, 255)  # #F2C8A0 base
SS = (212, 168, 120, 255)  # #D4A878 shadow
SH = (255, 224, 192, 255)  # #FFE0C0 highlight

# Eyes
EY = (43, 27, 14, 255)    # #2B1B0E dark brown
EW = (255, 255, 255, 255)  # white highlight dot

# Blue hoodie — 3 shades
CB = (59, 89, 152, 255)   # #3B5998 base
CS = (42, 64, 112, 255)   # #2A4070 shadow
CH = (91, 121, 184, 255)  # #5B79B8 highlight

# Dark pants — 2 shades
PB = (43, 43, 59, 255)    # #2B2B3B base
PS = (27, 27, 43, 255)    # #1B1B2B shadow

# Brown shoes — 2 shades
ShB = (90, 59, 32, 255)   # #5A3B20 base
ShS = (58, 37, 16, 255)   # #3A2510 shadow

W, H = 16, 24


def new_grid():
    """Return a blank 16x24 transparent grid."""
    return [[T] * W for _ in range(H)]


def make_image(pixels):
    """Create a 16x24 RGBA image from a 2D pixel array."""
    img = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    for y in range(H):
        for x in range(W):
            if y < len(pixels) and x < len(pixels[y]):
                img.putpixel((x, y), pixels[y][x])
    return img


def mirror_image(img):
    """Flip image horizontally for right-facing variants."""
    return img.transpose(Image.FLIP_LEFT_RIGHT)


def set_row(p, r, data):
    """Set pixels in row r from a dict of {col: color}."""
    for x, c in data.items():
        p[r][x] = c


def copy_head_front(p):
    """Draw the front-facing head (rows 0-8) — shared by idle_down and walk_down frames."""
    # Row 0: top of hair dome
    set_row(p, 0, {5: OL, 6: OL, 7: OL, 8: OL, 9: OL, 10: OL})

    # Row 1: hair top with highlight
    set_row(p, 1, {4: OL, 5: HH, 6: HH, 7: HH, 8: HH, 9: HB, 10: HB, 11: OL})

    # Row 2: hair expands — messy texture
    set_row(p, 2, {3: OL, 4: HH, 5: HH, 6: HB, 7: HH, 8: HB, 9: HB, 10: HS, 11: HB, 12: OL})

    # Row 3: hair fringe over forehead
    set_row(p, 3, {3: OL, 4: HB, 5: HS, 6: HB, 7: HB, 8: HB, 9: HB, 10: HS, 11: HB, 12: OL})

    # Row 4: hair fringe lower — some spiky texture
    set_row(p, 4, {3: OL, 4: HB, 5: HS, 6: HB, 7: HH, 8: HH, 9: HB, 10: HS, 11: HB, 12: OL})

    # Row 5: eyes row — skin + eyes between hair sideburns
    set_row(p, 5, {3: OL, 4: HB, 5: SH, 6: EY, 7: EW, 8: SB, 9: EY, 10: EW, 11: HB, 12: OL})

    # Row 6: mid-face — cheeks, subtle nose
    set_row(p, 6, {3: OL, 4: HB, 5: SB, 6: SH, 7: SB, 8: SB, 9: SH, 10: SB, 11: HB, 12: OL})

    # Row 7: chin — shadow line for mouth hint
    set_row(p, 7, {4: OL, 5: SB, 6: SB, 7: SS, 8: SS, 9: SB, 10: SB, 11: OL})

    # Row 8: neck
    set_row(p, 8, {5: OL, 6: SS, 7: SB, 8: SB, 9: SS, 10: OL})


def copy_head_back(p):
    """Draw the back-facing head (rows 0-8) — all hair, no face."""
    set_row(p, 0, {5: OL, 6: OL, 7: OL, 8: OL, 9: OL, 10: OL})
    set_row(p, 1, {4: OL, 5: HH, 6: HH, 7: HH, 8: HB, 9: HB, 10: HB, 11: OL})
    set_row(p, 2, {3: OL, 4: HH, 5: HH, 6: HB, 7: HH, 8: HB, 9: HB, 10: HS, 11: HB, 12: OL})
    set_row(p, 3, {3: OL, 4: HB, 5: HB, 6: HS, 7: HB, 8: HB, 9: HS, 10: HB, 11: HB, 12: OL})
    set_row(p, 4, {3: OL, 4: HB, 5: HS, 6: HB, 7: HB, 8: HB, 9: HB, 10: HS, 11: HB, 12: OL})
    set_row(p, 5, {3: OL, 4: HB, 5: HB, 6: HS, 7: HB, 8: HS, 9: HB, 10: HB, 11: HB, 12: OL})
    set_row(p, 6, {3: OL, 4: HS, 5: HB, 6: HB, 7: HS, 8: HB, 9: HB, 10: HS, 11: HS, 12: OL})
    set_row(p, 7, {4: OL, 5: HS, 6: HB, 7: HS, 8: HS, 9: HB, 10: HS, 11: OL})
    set_row(p, 8, {5: OL, 6: SS, 7: SB, 8: SB, 9: SS, 10: OL})


def copy_head_left(p):
    """Draw the left-facing head (rows 0-8) — profile, one eye."""
    set_row(p, 0, {5: OL, 6: OL, 7: OL, 8: OL, 9: OL, 10: OL})
    set_row(p, 1, {4: OL, 5: HH, 6: HH, 7: HH, 8: HB, 9: HB, 10: OL})
    set_row(p, 2, {3: OL, 4: HH, 5: HH, 6: HB, 7: HB, 8: HS, 9: HB, 10: HB, 11: OL})
    set_row(p, 3, {3: OL, 4: HB, 5: HS, 6: HB, 7: HB, 8: HB, 9: HS, 10: HB, 11: OL})
    set_row(p, 4, {3: OL, 4: HB, 5: HB, 6: HS, 7: HB, 8: HB, 9: HB, 10: HS, 11: OL})
    # Eye row — profile: one eye visible on left side
    set_row(p, 5, {3: OL, 4: SH, 5: EY, 6: EW, 7: SB, 8: SB, 9: HB, 10: HS, 11: OL})
    # Nose protrudes slightly
    set_row(p, 6, {2: OL, 3: SB, 4: SH, 5: SB, 6: SB, 7: SB, 8: SS, 9: HB, 10: OL})
    # Chin
    set_row(p, 7, {3: OL, 4: SB, 5: SS, 6: SS, 7: SB, 8: SB, 9: OL})
    # Neck
    set_row(p, 8, {5: OL, 6: SS, 7: SB, 8: SS, 9: OL})


def draw_torso_front_idle(p):
    """Hoodie torso for front idle (rows 9-14)."""
    # Row 9: collar
    set_row(p, 9, {3: OL, 4: CH, 5: CH, 6: CB, 7: CH, 8: CH, 9: CB, 10: CH, 11: CH, 12: OL})
    # Row 10: shoulders (widest ~12px)
    set_row(p, 10, {2: OL, 3: CH, 4: CB, 5: CB, 6: CH, 7: CB, 8: CB, 9: CH, 10: CB, 11: CB, 12: CS, 13: OL})
    # Row 11: upper torso with fold detail
    set_row(p, 11, {2: OL, 3: CB, 4: CB, 5: CS, 6: CB, 7: CB, 8: CB, 9: CB, 10: CS, 11: CB, 12: CB, 13: OL})
    # Row 12: mid torso
    set_row(p, 12, {2: OL, 3: CS, 4: CB, 5: CB, 6: CB, 7: CS, 8: CS, 9: CB, 10: CB, 11: CB, 12: CS, 13: OL})
    # Row 13: lower torso — tapers
    set_row(p, 13, {3: OL, 4: CB, 5: CB, 6: CS, 7: CB, 8: CB, 9: CS, 10: CB, 11: CB, 12: OL})
    # Row 14: hoodie hem
    set_row(p, 14, {3: OL, 4: CS, 5: CS, 6: CB, 7: CS, 8: CS, 9: CB, 10: CS, 11: CS, 12: OL})


def draw_legs_front_idle(p):
    """Legs/feet for front idle — feet together (rows 15-23)."""
    set_row(p, 15, {4: OL, 5: PB, 6: PB, 7: PS, 8: PS, 9: PB, 10: PB, 11: OL})
    set_row(p, 16, {4: OL, 5: PB, 6: PB, 7: PS, 8: PS, 9: PB, 10: PB, 11: OL})
    set_row(p, 17, {4: OL, 5: PB, 6: PS, 7: OL, 8: OL, 9: PS, 10: PB, 11: OL})
    set_row(p, 18, {4: OL, 5: PB, 6: PS, 7: OL, 8: OL, 9: PS, 10: PB, 11: OL})
    set_row(p, 19, {4: OL, 5: PB, 6: PB, 7: OL, 8: OL, 9: PB, 10: PB, 11: OL})
    set_row(p, 20, {4: OL, 5: PS, 6: PS, 7: OL, 8: OL, 9: PS, 10: PS, 11: OL})
    # Shoes
    set_row(p, 21, {3: OL, 4: ShB, 5: ShB, 6: ShS, 7: OL, 8: OL, 9: ShS, 10: ShB, 11: ShB, 12: OL})
    set_row(p, 22, {3: OL, 4: ShB, 5: ShS, 6: ShS, 7: OL, 8: OL, 9: ShS, 10: ShS, 11: ShB, 12: OL})
    # Soles
    set_row(p, 23, {4: OL, 5: OL, 6: OL, 8: OL, 9: OL, 10: OL, 11: OL})


def draw_torso_back_idle(p):
    """Hoodie torso for back idle (rows 9-14)."""
    set_row(p, 9, {3: OL, 4: CS, 5: CB, 6: CB, 7: CS, 8: CS, 9: CB, 10: CB, 11: CS, 12: OL})
    set_row(p, 10, {2: OL, 3: CB, 4: CB, 5: CS, 6: CB, 7: CB, 8: CB, 9: CS, 10: CB, 11: CB, 12: CB, 13: OL})
    set_row(p, 11, {2: OL, 3: CB, 4: CS, 5: CB, 6: CB, 7: CS, 8: CS, 9: CB, 10: CB, 11: CS, 12: CB, 13: OL})
    set_row(p, 12, {2: OL, 3: CS, 4: CB, 5: CB, 6: CS, 7: CB, 8: CB, 9: CS, 10: CB, 11: CB, 12: CS, 13: OL})
    set_row(p, 13, {3: OL, 4: CB, 5: CS, 6: CB, 7: CB, 8: CB, 9: CB, 10: CS, 11: CB, 12: OL})
    set_row(p, 14, {3: OL, 4: CS, 5: CS, 6: CB, 7: CS, 8: CS, 9: CB, 10: CS, 11: CS, 12: OL})


def draw_legs_back_idle(p):
    """Legs for back idle (rows 15-23) — same structure as front."""
    set_row(p, 15, {4: OL, 5: PB, 6: PB, 7: PS, 8: PS, 9: PB, 10: PB, 11: OL})
    set_row(p, 16, {4: OL, 5: PB, 6: PS, 7: PS, 8: PS, 9: PS, 10: PB, 11: OL})
    set_row(p, 17, {4: OL, 5: PB, 6: PS, 7: OL, 8: OL, 9: PS, 10: PB, 11: OL})
    set_row(p, 18, {4: OL, 5: PB, 6: PS, 7: OL, 8: OL, 9: PS, 10: PB, 11: OL})
    set_row(p, 19, {4: OL, 5: PB, 6: PB, 7: OL, 8: OL, 9: PB, 10: PB, 11: OL})
    set_row(p, 20, {4: OL, 5: PS, 6: PS, 7: OL, 8: OL, 9: PS, 10: PS, 11: OL})
    set_row(p, 21, {3: OL, 4: ShB, 5: ShS, 6: ShS, 7: OL, 8: OL, 9: ShS, 10: ShS, 11: ShB, 12: OL})
    set_row(p, 22, {3: OL, 4: ShS, 5: ShS, 6: ShS, 7: OL, 8: OL, 9: ShS, 10: ShS, 11: ShS, 12: OL})
    set_row(p, 23, {4: OL, 5: OL, 6: OL, 8: OL, 9: OL, 10: OL, 11: OL})


# ============================================================
# IDLE DOWN — Front-facing, arms at sides, feet together
# ============================================================
def make_idle_down():
    p = new_grid()
    copy_head_front(p)
    draw_torso_front_idle(p)
    draw_legs_front_idle(p)
    return make_image(p)


# ============================================================
# IDLE UP — Back view
# ============================================================
def make_idle_up():
    p = new_grid()
    copy_head_back(p)
    draw_torso_back_idle(p)
    draw_legs_back_idle(p)
    return make_image(p)


# ============================================================
# IDLE LEFT — Left-facing profile
# ============================================================
def make_idle_left():
    p = new_grid()
    copy_head_left(p)

    # Torso — side view (narrower ~8-9px)
    set_row(p, 9,  {4: OL, 5: CH, 6: CB, 7: CB, 8: CB, 9: CS, 10: CB, 11: OL})
    set_row(p, 10, {3: OL, 4: CB, 5: CH, 6: CB, 7: CB, 8: CB, 9: CS, 10: CB, 11: OL})
    set_row(p, 11, {3: OL, 4: CS, 5: CB, 6: CB, 7: CS, 8: CB, 9: CB, 10: CS, 11: OL})
    set_row(p, 12, {3: OL, 4: CB, 5: CS, 6: CB, 7: CB, 8: CS, 9: CB, 10: CB, 11: OL})
    set_row(p, 13, {4: OL, 5: CB, 6: CS, 7: CB, 8: CB, 9: CS, 10: CB, 11: OL})
    set_row(p, 14, {4: OL, 5: CS, 6: CB, 7: CS, 8: CS, 9: CB, 10: CS, 11: OL})

    # Legs — profile (narrower)
    set_row(p, 15, {5: OL, 6: PB, 7: PB, 8: PS, 9: PB, 10: OL})
    set_row(p, 16, {5: OL, 6: PB, 7: PS, 8: PS, 9: PB, 10: OL})
    set_row(p, 17, {5: OL, 6: PB, 7: PS, 8: PB, 9: OL})
    set_row(p, 18, {5: OL, 6: PB, 7: PS, 8: PB, 9: OL})
    set_row(p, 19, {5: OL, 6: PB, 7: PB, 8: PB, 9: OL})
    set_row(p, 20, {5: OL, 6: PS, 7: PS, 8: PS, 9: OL})
    # Shoes
    set_row(p, 21, {4: OL, 5: ShB, 6: ShB, 7: ShS, 8: ShS, 9: OL})
    set_row(p, 22, {3: OL, 4: ShB, 5: ShB, 6: ShS, 7: ShS, 8: ShS, 9: OL})
    set_row(p, 23, {4: OL, 5: OL, 6: OL, 7: OL, 8: OL})

    return make_image(p)


# ============================================================
# WALK DOWN 1 — Left leg forward, right arm swings forward
# ============================================================
def make_walk_down_1():
    p = new_grid()
    copy_head_front(p)

    # Torso — right arm swings forward slightly (skin pixel visible)
    set_row(p, 9,  {3: OL, 4: CH, 5: CH, 6: CB, 7: CH, 8: CH, 9: CB, 10: CH, 11: CH, 12: OL})
    set_row(p, 10, {2: OL, 3: CH, 4: CB, 5: CB, 6: CH, 7: CB, 8: CB, 9: CH, 10: CB, 11: CB, 12: CS, 13: OL})
    set_row(p, 11, {2: OL, 3: CB, 4: CB, 5: CS, 6: CB, 7: CB, 8: CB, 9: CB, 10: CS, 11: CB, 12: CB, 13: OL})
    set_row(p, 12, {2: OL, 3: CS, 4: CB, 5: CB, 6: CB, 7: CS, 8: CS, 9: CB, 10: CB, 11: CB, 12: CS, 13: OL})
    set_row(p, 13, {3: OL, 4: CB, 5: CB, 6: CS, 7: CB, 8: CB, 9: CS, 10: CB, 11: CB, 12: OL})
    set_row(p, 14, {3: OL, 4: CS, 5: CS, 6: CB, 7: CS, 8: CS, 9: CB, 10: CS, 11: CS, 12: OL})

    # Legs — left leg steps forward, right leg back
    set_row(p, 15, {4: OL, 5: PB, 6: PB, 7: PS, 8: PS, 9: PB, 10: PB, 11: OL})
    set_row(p, 16, {3: OL, 4: PB, 5: PB, 6: PS, 7: OL, 8: OL, 9: PS, 10: PB, 11: OL})
    set_row(p, 17, {3: OL, 4: PB, 5: PS, 6: OL, 8: OL, 9: PS, 10: PB, 11: OL})
    set_row(p, 18, {3: OL, 4: PB, 5: PS, 6: OL, 9: OL, 10: PB, 11: OL})
    set_row(p, 19, {3: OL, 4: PB, 5: PB, 6: OL, 9: OL, 10: PB, 11: OL})
    set_row(p, 20, {3: OL, 4: PS, 5: PS, 6: OL, 9: OL, 10: PS, 11: OL})
    # Left shoe forward, right shoe back
    set_row(p, 21, {2: OL, 3: ShB, 4: ShB, 5: ShS, 6: OL, 9: OL, 10: ShS, 11: ShB, 12: OL})
    set_row(p, 22, {2: OL, 3: ShS, 4: ShS, 5: ShS, 6: OL, 9: OL, 10: ShS, 11: ShS, 12: OL})
    set_row(p, 23, {3: OL, 4: OL, 5: OL, 6: OL, 10: OL, 11: OL, 12: OL})

    return make_image(p)


# ============================================================
# WALK DOWN 2 — Right leg forward, left arm swings forward
# ============================================================
def make_walk_down_2():
    p = new_grid()
    copy_head_front(p)

    # Torso — left arm forward
    set_row(p, 9,  {3: OL, 4: CH, 5: CH, 6: CB, 7: CH, 8: CH, 9: CB, 10: CH, 11: CH, 12: OL})
    set_row(p, 10, {2: OL, 3: CS, 4: CB, 5: CB, 6: CH, 7: CB, 8: CB, 9: CH, 10: CB, 11: CB, 12: CH, 13: OL})
    set_row(p, 11, {2: OL, 3: CB, 4: CB, 5: CS, 6: CB, 7: CB, 8: CB, 9: CB, 10: CS, 11: CB, 12: CB, 13: OL})
    set_row(p, 12, {2: OL, 3: CS, 4: CB, 5: CB, 6: CB, 7: CS, 8: CS, 9: CB, 10: CB, 11: CB, 12: CS, 13: OL})
    set_row(p, 13, {3: OL, 4: CB, 5: CB, 6: CS, 7: CB, 8: CB, 9: CS, 10: CB, 11: CB, 12: OL})
    set_row(p, 14, {3: OL, 4: CS, 5: CS, 6: CB, 7: CS, 8: CS, 9: CB, 10: CS, 11: CS, 12: OL})

    # Legs — right leg forward, left leg back
    set_row(p, 15, {4: OL, 5: PB, 6: PB, 7: PS, 8: PS, 9: PB, 10: PB, 11: OL})
    set_row(p, 16, {4: OL, 5: PB, 6: PS, 7: OL, 8: OL, 9: PB, 10: PB, 11: PB, 12: OL})
    set_row(p, 17, {4: OL, 5: PB, 6: PS, 7: OL, 9: OL, 10: PS, 11: PB, 12: OL})
    set_row(p, 18, {4: OL, 5: PB, 6: OL, 9: OL, 10: PS, 11: PB, 12: OL})
    set_row(p, 19, {4: OL, 5: PB, 6: OL, 9: OL, 10: PB, 11: PB, 12: OL})
    set_row(p, 20, {4: OL, 5: PS, 6: OL, 9: OL, 10: PS, 11: PS, 12: OL})
    # Left shoe back, right shoe forward
    set_row(p, 21, {3: OL, 4: ShB, 5: ShS, 6: OL, 9: OL, 10: ShS, 11: ShB, 12: ShB, 13: OL})
    set_row(p, 22, {3: OL, 4: ShS, 5: ShS, 6: OL, 9: OL, 10: ShS, 11: ShS, 12: ShS, 13: OL})
    set_row(p, 23, {3: OL, 4: OL, 5: OL, 10: OL, 11: OL, 12: OL, 13: OL})

    return make_image(p)


# ============================================================
# WALK UP 1 — Walking back, left leg forward
# ============================================================
def make_walk_up_1():
    p = new_grid()
    copy_head_back(p)

    # Torso — arm swing (right arm forward from behind)
    set_row(p, 9,  {3: OL, 4: CS, 5: CB, 6: CB, 7: CS, 8: CS, 9: CB, 10: CB, 11: CS, 12: OL})
    set_row(p, 10, {2: OL, 3: CB, 4: CB, 5: CS, 6: CB, 7: CB, 8: CB, 9: CS, 10: CB, 11: CB, 12: CB, 13: OL})
    set_row(p, 11, {2: OL, 3: CB, 4: CS, 5: CB, 6: CB, 7: CS, 8: CS, 9: CB, 10: CB, 11: CS, 12: CB, 13: OL})
    set_row(p, 12, {2: OL, 3: CS, 4: CB, 5: CB, 6: CS, 7: CB, 8: CB, 9: CS, 10: CB, 11: CB, 12: CS, 13: OL})
    set_row(p, 13, {3: OL, 4: CB, 5: CS, 6: CB, 7: CB, 8: CB, 9: CB, 10: CS, 11: CB, 12: OL})
    set_row(p, 14, {3: OL, 4: CS, 5: CS, 6: CB, 7: CS, 8: CS, 9: CB, 10: CS, 11: CS, 12: OL})

    # Legs — left forward, right back
    set_row(p, 15, {4: OL, 5: PB, 6: PB, 7: PS, 8: PS, 9: PB, 10: PB, 11: OL})
    set_row(p, 16, {3: OL, 4: PB, 5: PB, 6: PS, 7: OL, 8: OL, 9: PS, 10: PB, 11: OL})
    set_row(p, 17, {3: OL, 4: PB, 5: PS, 6: OL, 8: OL, 9: PS, 10: PB, 11: OL})
    set_row(p, 18, {3: OL, 4: PB, 5: PS, 6: OL, 9: OL, 10: PB, 11: OL})
    set_row(p, 19, {3: OL, 4: PB, 5: PB, 6: OL, 9: OL, 10: PB, 11: OL})
    set_row(p, 20, {3: OL, 4: PS, 5: PS, 6: OL, 9: OL, 10: PS, 11: OL})
    set_row(p, 21, {2: OL, 3: ShB, 4: ShS, 5: ShS, 6: OL, 9: OL, 10: ShS, 11: ShB, 12: OL})
    set_row(p, 22, {2: OL, 3: ShS, 4: ShS, 5: ShS, 6: OL, 9: OL, 10: ShS, 11: ShS, 12: OL})
    set_row(p, 23, {3: OL, 4: OL, 5: OL, 6: OL, 10: OL, 11: OL, 12: OL})

    return make_image(p)


# ============================================================
# WALK UP 2 — Walking back, right leg forward
# ============================================================
def make_walk_up_2():
    p = new_grid()
    copy_head_back(p)

    # Torso — opposite arm swing
    set_row(p, 9,  {3: OL, 4: CS, 5: CB, 6: CB, 7: CS, 8: CS, 9: CB, 10: CB, 11: CS, 12: OL})
    set_row(p, 10, {2: OL, 3: CB, 4: CB, 5: CS, 6: CB, 7: CB, 8: CB, 9: CS, 10: CB, 11: CB, 12: CB, 13: OL})
    set_row(p, 11, {2: OL, 3: CB, 4: CS, 5: CB, 6: CB, 7: CS, 8: CS, 9: CB, 10: CB, 11: CS, 12: CB, 13: OL})
    set_row(p, 12, {2: OL, 3: CS, 4: CB, 5: CB, 6: CS, 7: CB, 8: CB, 9: CS, 10: CB, 11: CB, 12: CS, 13: OL})
    set_row(p, 13, {3: OL, 4: CB, 5: CS, 6: CB, 7: CB, 8: CB, 9: CB, 10: CS, 11: CB, 12: OL})
    set_row(p, 14, {3: OL, 4: CS, 5: CS, 6: CB, 7: CS, 8: CS, 9: CB, 10: CS, 11: CS, 12: OL})

    # Legs — right forward, left back
    set_row(p, 15, {4: OL, 5: PB, 6: PB, 7: PS, 8: PS, 9: PB, 10: PB, 11: OL})
    set_row(p, 16, {4: OL, 5: PB, 6: PS, 7: OL, 8: OL, 9: PB, 10: PB, 11: PB, 12: OL})
    set_row(p, 17, {4: OL, 5: PB, 6: PS, 7: OL, 9: OL, 10: PS, 11: PB, 12: OL})
    set_row(p, 18, {4: OL, 5: PB, 6: OL, 9: OL, 10: PS, 11: PB, 12: OL})
    set_row(p, 19, {4: OL, 5: PB, 6: OL, 9: OL, 10: PB, 11: PB, 12: OL})
    set_row(p, 20, {4: OL, 5: PS, 6: OL, 9: OL, 10: PS, 11: PS, 12: OL})
    set_row(p, 21, {3: OL, 4: ShB, 5: ShS, 6: OL, 9: OL, 10: ShS, 11: ShB, 12: ShB, 13: OL})
    set_row(p, 22, {3: OL, 4: ShS, 5: ShS, 6: OL, 9: OL, 10: ShS, 11: ShS, 12: ShS, 13: OL})
    set_row(p, 23, {3: OL, 4: OL, 5: OL, 10: OL, 11: OL, 12: OL, 13: OL})

    return make_image(p)


# ============================================================
# WALK LEFT 1 — Walking left, stride pose 1 (front leg forward)
# ============================================================
def make_walk_left_1():
    p = new_grid()
    copy_head_left(p)

    # Torso — side view with arm swing (front arm forward)
    set_row(p, 9,  {4: OL, 5: CH, 6: CB, 7: CB, 8: CB, 9: CS, 10: CB, 11: OL})
    set_row(p, 10, {3: OL, 4: CB, 5: CH, 6: CB, 7: CB, 8: CB, 9: CS, 10: CB, 11: OL})
    # Front arm swings forward — hand pixel
    set_row(p, 11, {2: OL, 3: SS, 4: OL, 5: CB, 6: CB, 7: CS, 8: CB, 9: CB, 10: CS, 11: OL})
    set_row(p, 12, {3: OL, 4: CB, 5: CS, 6: CB, 7: CB, 8: CS, 9: CB, 10: CB, 11: OL})
    set_row(p, 13, {4: OL, 5: CB, 6: CS, 7: CB, 8: CB, 9: CS, 10: CB, 11: OL})
    set_row(p, 14, {4: OL, 5: CS, 6: CB, 7: CS, 8: CS, 9: CB, 10: CS, 11: OL})

    # Legs — stride: front leg forward, back leg behind
    set_row(p, 15, {5: OL, 6: PB, 7: PB, 8: PS, 9: PB, 10: OL})
    set_row(p, 16, {4: OL, 5: PB, 6: PB, 7: PS, 8: PB, 9: PB, 10: OL})
    set_row(p, 17, {3: OL, 4: PB, 5: PS, 6: OL, 8: OL, 9: PB, 10: OL})
    set_row(p, 18, {3: OL, 4: PB, 5: PS, 6: OL, 8: OL, 9: PB, 10: OL})
    set_row(p, 19, {3: OL, 4: PB, 5: PB, 6: OL, 9: OL, 10: PB, 11: OL})
    set_row(p, 20, {3: OL, 4: PS, 5: PS, 6: OL, 9: OL, 10: PS, 11: OL})
    # Front shoe forward, back shoe behind
    set_row(p, 21, {2: OL, 3: ShB, 4: ShB, 5: ShS, 6: OL, 9: OL, 10: ShS, 11: OL})
    set_row(p, 22, {1: OL, 2: ShB, 3: ShS, 4: ShS, 5: ShS, 6: OL, 9: OL, 10: ShS, 11: OL})
    set_row(p, 23, {2: OL, 3: OL, 4: OL, 5: OL, 6: OL, 10: OL, 11: OL})

    return make_image(p)


# ============================================================
# WALK LEFT 2 — Walking left, stride pose 2 (back leg forward)
# ============================================================
def make_walk_left_2():
    p = new_grid()
    copy_head_left(p)

    # Torso — opposite arm swing (back arm visible)
    set_row(p, 9,  {4: OL, 5: CH, 6: CB, 7: CB, 8: CB, 9: CS, 10: CB, 11: OL})
    set_row(p, 10, {3: OL, 4: CB, 5: CH, 6: CB, 7: CB, 8: CB, 9: CS, 10: CB, 11: OL})
    # Back arm swings forward — hand pixel behind body
    set_row(p, 11, {3: OL, 4: CS, 5: CB, 6: CB, 7: CS, 8: CB, 9: CB, 10: CS, 11: OL, 12: SS, 13: OL})
    set_row(p, 12, {3: OL, 4: CB, 5: CS, 6: CB, 7: CB, 8: CS, 9: CB, 10: CB, 11: OL})
    set_row(p, 13, {4: OL, 5: CB, 6: CS, 7: CB, 8: CB, 9: CS, 10: CB, 11: OL})
    set_row(p, 14, {4: OL, 5: CS, 6: CB, 7: CS, 8: CS, 9: CB, 10: CS, 11: OL})

    # Legs — opposite stride
    set_row(p, 15, {5: OL, 6: PB, 7: PB, 8: PS, 9: PB, 10: OL})
    set_row(p, 16, {5: OL, 6: PB, 7: PS, 8: PB, 9: PB, 10: PB, 11: OL})
    set_row(p, 17, {5: OL, 6: PB, 7: OL, 8: OL, 9: PS, 10: PB, 11: OL})
    set_row(p, 18, {5: OL, 6: PB, 7: OL, 8: OL, 9: PS, 10: PB, 11: OL})
    set_row(p, 19, {4: OL, 5: PB, 6: OL, 9: OL, 10: PB, 11: PB, 12: OL})
    set_row(p, 20, {4: OL, 5: PS, 6: OL, 9: OL, 10: PS, 11: PS, 12: OL})
    # Back shoe behind, front shoe forward
    set_row(p, 21, {4: OL, 5: ShS, 6: OL, 8: OL, 9: ShS, 10: ShB, 11: ShB, 12: OL})
    set_row(p, 22, {4: OL, 5: ShS, 6: OL, 8: OL, 9: ShS, 10: ShS, 11: ShB, 12: ShB, 13: OL})
    set_row(p, 23, {4: OL, 5: OL, 9: OL, 10: OL, 11: OL, 12: OL, 13: OL})

    return make_image(p)


# ============================================================
# MAIN — Generate all 12 sprites
# ============================================================
def main():
    out_dir = "/Users/macbook/Flat101/godtest/vdh-godot/assets/sprites/player"
    os.makedirs(out_dir, exist_ok=True)

    sprites = {}

    # Idle sprites
    print("Generating idle_down...")
    sprites["idle_down"] = make_idle_down()

    print("Generating idle_up...")
    sprites["idle_up"] = make_idle_up()

    print("Generating idle_left...")
    sprites["idle_left"] = make_idle_left()

    print("Generating idle_right (mirror of left)...")
    sprites["idle_right"] = mirror_image(sprites["idle_left"])

    # Walk down sprites
    print("Generating walk_down_1...")
    sprites["walk_down_1"] = make_walk_down_1()

    print("Generating walk_down_2...")
    sprites["walk_down_2"] = make_walk_down_2()

    # Walk up sprites
    print("Generating walk_up_1...")
    sprites["walk_up_1"] = make_walk_up_1()

    print("Generating walk_up_2...")
    sprites["walk_up_2"] = make_walk_up_2()

    # Walk left sprites
    print("Generating walk_left_1...")
    sprites["walk_left_1"] = make_walk_left_1()

    print("Generating walk_left_2...")
    sprites["walk_left_2"] = make_walk_left_2()

    # Walk right sprites (mirror of left)
    print("Generating walk_right_1 (mirror of walk_left_1)...")
    sprites["walk_right_1"] = mirror_image(sprites["walk_left_1"])

    print("Generating walk_right_2 (mirror of walk_left_2)...")
    sprites["walk_right_2"] = mirror_image(sprites["walk_left_2"])

    # Save all sprites
    print("\nSaving sprites...")
    for name, img in sprites.items():
        filepath = os.path.join(out_dir, f"{name}.png")
        img.save(filepath)
        print(f"  Saved: {filepath} ({img.size[0]}x{img.size[1]})")

    # Verification
    print("\n=== VERIFICATION ===")
    expected = [
        "idle_down.png", "idle_up.png", "idle_left.png", "idle_right.png",
        "walk_down_1.png", "walk_down_2.png", "walk_up_1.png", "walk_up_2.png",
        "walk_left_1.png", "walk_left_2.png", "walk_right_1.png", "walk_right_2.png",
    ]
    all_ok = True
    for fname in expected:
        fpath = os.path.join(out_dir, fname)
        if os.path.exists(fpath):
            img = Image.open(fpath)
            if img.size == (16, 24) and img.mode == "RGBA":
                # Count non-transparent pixels
                data = list(img.getdata())
                opaque = sum(1 for px in data if px[3] > 0)
                print(f"  [OK] {fname} — 16x24 RGBA, {opaque} opaque pixels")
            else:
                print(f"  [WARN] {fname} — size={img.size}, mode={img.mode}")
                all_ok = False
        else:
            print(f"  [FAIL] {fname} — NOT FOUND")
            all_ok = False

    if all_ok:
        print(f"\nAll {len(expected)} sprites generated successfully!")
    else:
        print("\nSome sprites had issues — check warnings above.")

    # Color palette summary
    print("\n=== COLOR PALETTE ===")
    print("  Outline:        #181425 (near-black)")
    print("  Hair:           #6B4226 base / #8B5A34 highlight / #4A2A14 shadow")
    print("  Skin:           #F2C8A0 base / #FFE0C0 highlight / #D4A878 shadow")
    print("  Eyes:           #2B1B0E dark / #FFFFFF highlight")
    print("  Hoodie:         #3B5998 base / #5B79B8 highlight / #2A4070 shadow")
    print("  Pants:          #2B2B3B base / #1B1B2B shadow")
    print("  Shoes:          #5A3B20 base / #3A2510 shadow")


if __name__ == "__main__":
    main()
