#!/usr/bin/env python3
"""
Sprite generator for "Versos de Heroe" - 2D RPG about bullying.
Generates 16x16 pixel art sprites for enemies and NPCs using Pillow.
All sprites are drawn pixel by pixel.
"""

from PIL import Image
import os

# --- Output directories ---
ENEMY_DIR = "/Users/macbook/Flat101/godtest/vdh-godot/assets/sprites/enemies"
NPC_DIR = "/Users/macbook/Flat101/godtest/vdh-godot/assets/sprites/npcs"

# --- Color constants ---
T = (0, 0, 0, 0)  # Transparent

# Skin tones
SKIN = (235, 195, 154, 255)
SKIN_DARK = (210, 170, 130, 255)

# Common colors
BLACK = (20, 20, 20, 255)
WHITE = (255, 255, 255, 255)
DARK_BROWN_HAIR = (50, 30, 20, 255)
BROWN_HAIR = (100, 65, 35, 255)
GRAY_HAIR = (180, 180, 180, 255)
WHITE_HAIR = (220, 220, 220, 255)
EYE_BLACK = (10, 10, 10, 255)
EYE_WHITE = (255, 255, 255, 255)
MOUTH = (180, 80, 80, 255)
SHOE_BLACK = (30, 30, 30, 255)
SHOE_BROWN = (80, 50, 30, 255)
PANTS_BLUE = (50, 60, 120, 255)
PANTS_DARK = (40, 40, 60, 255)
PANTS_BROWN = (100, 70, 40, 255)
PANTS_GRAY = (100, 100, 110, 255)
TIE_RED = (180, 40, 40, 255)


def make_image():
    """Create a new 16x16 RGBA image filled with transparency."""
    return Image.new("RGBA", (16, 16), T)


def px(img, x, y, color):
    """Set a single pixel, bounds-checked."""
    if 0 <= x < 16 and 0 <= y < 16:
        img.putpixel((x, y), color)


def fill_rect(img, x0, y0, w, h, color):
    """Fill a rectangle of pixels."""
    for yy in range(y0, y0 + h):
        for xx in range(x0, x0 + w):
            px(img, xx, yy, color)


def save(img, path):
    """Save image and print confirmation."""
    img.save(path)
    print(f"  Saved: {path}")


# =============================================================================
# ENEMY SPRITES
# =============================================================================

def generate_enemy_fear():
    """Fear: Purple ghostly figure, wispy/smoke shape, glowing white eyes."""
    img = make_image()

    PURPLE_DARK = (107, 31, 138, 255)
    PURPLE_MED = (130, 50, 160, 240)
    PURPLE_LIGHT = (160, 80, 190, 180)
    PURPLE_WISP = (140, 60, 170, 120)
    PURPLE_EDGE = (120, 40, 150, 80)
    GLOW_WHITE = (255, 255, 255, 255)
    GLOW_DIM = (220, 200, 255, 200)

    # Row 0: wispy top tendrils
    px(img, 6, 0, PURPLE_EDGE)
    px(img, 9, 0, PURPLE_EDGE)

    # Row 1: upper wisp
    px(img, 5, 1, PURPLE_WISP)
    px(img, 6, 1, PURPLE_LIGHT)
    px(img, 7, 1, PURPLE_LIGHT)
    px(img, 8, 1, PURPLE_LIGHT)
    px(img, 9, 1, PURPLE_WISP)

    # Row 2: head forming
    px(img, 4, 2, PURPLE_EDGE)
    px(img, 5, 2, PURPLE_MED)
    px(img, 6, 2, PURPLE_DARK)
    px(img, 7, 2, PURPLE_DARK)
    px(img, 8, 2, PURPLE_DARK)
    px(img, 9, 2, PURPLE_MED)
    px(img, 10, 2, PURPLE_EDGE)

    # Row 3: head top
    px(img, 4, 3, PURPLE_MED)
    px(img, 5, 3, PURPLE_DARK)
    px(img, 6, 3, PURPLE_DARK)
    px(img, 7, 3, PURPLE_DARK)
    px(img, 8, 3, PURPLE_DARK)
    px(img, 9, 3, PURPLE_DARK)
    px(img, 10, 3, PURPLE_MED)

    # Row 4: eyes row
    px(img, 3, 4, PURPLE_EDGE)
    px(img, 4, 4, PURPLE_DARK)
    px(img, 5, 4, GLOW_WHITE)
    px(img, 6, 4, GLOW_DIM)
    px(img, 7, 4, PURPLE_DARK)
    px(img, 8, 4, GLOW_DIM)
    px(img, 9, 4, GLOW_WHITE)
    px(img, 10, 4, PURPLE_DARK)
    px(img, 11, 4, PURPLE_EDGE)

    # Row 5: below eyes - mouth area (menacing slit)
    px(img, 3, 5, PURPLE_MED)
    px(img, 4, 5, PURPLE_DARK)
    px(img, 5, 5, PURPLE_DARK)
    px(img, 6, 5, PURPLE_DARK)
    px(img, 7, 5, PURPLE_MED)
    px(img, 8, 5, PURPLE_DARK)
    px(img, 9, 5, PURPLE_DARK)
    px(img, 10, 5, PURPLE_DARK)
    px(img, 11, 5, PURPLE_MED)

    # Row 6: mouth/jagged opening
    px(img, 3, 6, PURPLE_MED)
    px(img, 4, 6, PURPLE_DARK)
    px(img, 5, 6, PURPLE_DARK)
    px(img, 6, 6, (40, 10, 50, 255))  # dark mouth
    px(img, 7, 6, (60, 20, 70, 255))
    px(img, 8, 6, (40, 10, 50, 255))
    px(img, 9, 6, PURPLE_DARK)
    px(img, 10, 6, PURPLE_DARK)
    px(img, 11, 6, PURPLE_MED)

    # Row 7: body widens
    px(img, 3, 7, PURPLE_LIGHT)
    px(img, 4, 7, PURPLE_MED)
    px(img, 5, 7, PURPLE_DARK)
    px(img, 6, 7, PURPLE_DARK)
    px(img, 7, 7, PURPLE_DARK)
    px(img, 8, 7, PURPLE_DARK)
    px(img, 9, 7, PURPLE_DARK)
    px(img, 10, 7, PURPLE_MED)
    px(img, 11, 7, PURPLE_LIGHT)

    # Row 8: torso
    px(img, 2, 8, PURPLE_EDGE)
    px(img, 3, 8, PURPLE_MED)
    px(img, 4, 8, PURPLE_DARK)
    px(img, 5, 8, PURPLE_DARK)
    px(img, 6, 8, PURPLE_MED)
    px(img, 7, 8, PURPLE_DARK)
    px(img, 8, 8, PURPLE_MED)
    px(img, 9, 8, PURPLE_DARK)
    px(img, 10, 8, PURPLE_DARK)
    px(img, 11, 8, PURPLE_MED)
    px(img, 12, 8, PURPLE_EDGE)

    # Row 9: lower torso wispy arms
    px(img, 2, 9, PURPLE_WISP)
    px(img, 3, 9, PURPLE_MED)
    px(img, 4, 9, PURPLE_DARK)
    px(img, 5, 9, PURPLE_MED)
    px(img, 6, 9, PURPLE_DARK)
    px(img, 7, 9, PURPLE_DARK)
    px(img, 8, 9, PURPLE_DARK)
    px(img, 9, 9, PURPLE_MED)
    px(img, 10, 9, PURPLE_DARK)
    px(img, 11, 9, PURPLE_MED)
    px(img, 12, 9, PURPLE_WISP)

    # Row 10: narrowing
    px(img, 3, 10, PURPLE_LIGHT)
    px(img, 4, 10, PURPLE_MED)
    px(img, 5, 10, PURPLE_DARK)
    px(img, 6, 10, PURPLE_DARK)
    px(img, 7, 10, PURPLE_MED)
    px(img, 8, 10, PURPLE_DARK)
    px(img, 9, 10, PURPLE_DARK)
    px(img, 10, 10, PURPLE_MED)
    px(img, 11, 10, PURPLE_LIGHT)

    # Row 11: wisping away
    px(img, 4, 11, PURPLE_LIGHT)
    px(img, 5, 11, PURPLE_MED)
    px(img, 6, 11, PURPLE_DARK)
    px(img, 7, 11, PURPLE_MED)
    px(img, 8, 11, PURPLE_DARK)
    px(img, 9, 11, PURPLE_MED)
    px(img, 10, 11, PURPLE_LIGHT)

    # Row 12: smoke tendrils
    px(img, 4, 12, PURPLE_EDGE)
    px(img, 5, 12, PURPLE_LIGHT)
    px(img, 6, 12, PURPLE_MED)
    px(img, 7, 12, PURPLE_LIGHT)
    px(img, 8, 12, PURPLE_MED)
    px(img, 9, 12, PURPLE_LIGHT)
    px(img, 10, 12, PURPLE_EDGE)

    # Row 13: fading tendrils
    px(img, 5, 13, PURPLE_EDGE)
    px(img, 6, 13, PURPLE_WISP)
    px(img, 8, 13, PURPLE_WISP)
    px(img, 9, 13, PURPLE_EDGE)

    # Row 14: last wisps
    px(img, 5, 14, PURPLE_WISP)
    px(img, 9, 14, PURPLE_WISP)

    # Row 15: barely there
    px(img, 6, 15, PURPLE_EDGE)
    px(img, 8, 15, PURPLE_EDGE)

    save(img, os.path.join(ENEMY_DIR, "enemy_fear.png"))


def generate_enemy_sadness():
    """Sadness: Blue teardrop entity, drooping form, single dim eye, dripping."""
    img = make_image()

    BLUE_DARK = (27, 59, 122, 255)
    BLUE_MED = (40, 80, 150, 230)
    BLUE_LIGHT = (60, 100, 170, 200)
    BLUE_EDGE = (50, 70, 140, 140)
    BLUE_DRIP = (30, 65, 130, 160)
    EYE_DIM = (160, 170, 200, 200)

    # Row 0: teardrop tip
    px(img, 7, 0, BLUE_EDGE)

    # Row 1: narrow top
    px(img, 7, 1, BLUE_LIGHT)
    px(img, 8, 1, BLUE_EDGE)

    # Row 2: widening teardrop
    px(img, 6, 2, BLUE_EDGE)
    px(img, 7, 2, BLUE_MED)
    px(img, 8, 2, BLUE_MED)
    px(img, 9, 2, BLUE_EDGE)

    # Row 3: wider
    px(img, 5, 3, BLUE_EDGE)
    px(img, 6, 3, BLUE_MED)
    px(img, 7, 3, BLUE_DARK)
    px(img, 8, 3, BLUE_DARK)
    px(img, 9, 3, BLUE_MED)
    px(img, 10, 3, BLUE_EDGE)

    # Row 4: eye row - single dim eye slightly left of center
    px(img, 4, 4, BLUE_EDGE)
    px(img, 5, 4, BLUE_MED)
    px(img, 6, 4, BLUE_DARK)
    px(img, 7, 4, EYE_DIM)  # the single dim eye
    px(img, 8, 4, BLUE_DARK)
    px(img, 9, 4, BLUE_DARK)
    px(img, 10, 4, BLUE_MED)
    px(img, 11, 4, BLUE_EDGE)

    # Row 5: below eye, drooping expression
    px(img, 4, 5, BLUE_MED)
    px(img, 5, 5, BLUE_DARK)
    px(img, 6, 5, BLUE_DARK)
    px(img, 7, 5, BLUE_DARK)
    px(img, 8, 5, BLUE_DARK)
    px(img, 9, 5, BLUE_DARK)
    px(img, 10, 5, BLUE_DARK)
    px(img, 11, 5, BLUE_MED)

    # Row 6: widest part of teardrop
    px(img, 3, 6, BLUE_EDGE)
    px(img, 4, 6, BLUE_MED)
    px(img, 5, 6, BLUE_DARK)
    px(img, 6, 6, BLUE_DARK)
    px(img, 7, 6, BLUE_MED)
    px(img, 8, 6, BLUE_DARK)
    px(img, 9, 6, BLUE_DARK)
    px(img, 10, 6, BLUE_DARK)
    px(img, 11, 6, BLUE_MED)
    px(img, 12, 6, BLUE_EDGE)

    # Row 7: widest
    px(img, 3, 7, BLUE_MED)
    px(img, 4, 7, BLUE_DARK)
    px(img, 5, 7, BLUE_DARK)
    px(img, 6, 7, BLUE_MED)
    px(img, 7, 7, BLUE_DARK)
    px(img, 8, 7, BLUE_DARK)
    px(img, 9, 7, BLUE_MED)
    px(img, 10, 7, BLUE_DARK)
    px(img, 11, 7, BLUE_DARK)
    px(img, 12, 7, BLUE_MED)

    # Row 8: still wide
    px(img, 3, 8, BLUE_MED)
    px(img, 4, 8, BLUE_DARK)
    px(img, 5, 8, BLUE_DARK)
    px(img, 6, 8, BLUE_DARK)
    px(img, 7, 8, BLUE_DARK)
    px(img, 8, 8, BLUE_MED)
    px(img, 9, 8, BLUE_DARK)
    px(img, 10, 8, BLUE_DARK)
    px(img, 11, 8, BLUE_DARK)
    px(img, 12, 8, BLUE_MED)

    # Row 9: beginning to narrow / drip
    px(img, 3, 9, BLUE_EDGE)
    px(img, 4, 9, BLUE_MED)
    px(img, 5, 9, BLUE_DARK)
    px(img, 6, 9, BLUE_DARK)
    px(img, 7, 9, BLUE_DARK)
    px(img, 8, 9, BLUE_DARK)
    px(img, 9, 9, BLUE_DARK)
    px(img, 10, 9, BLUE_DARK)
    px(img, 11, 9, BLUE_MED)
    px(img, 12, 9, BLUE_EDGE)

    # Row 10: narrowing with drip tendrils
    px(img, 4, 10, BLUE_LIGHT)
    px(img, 5, 10, BLUE_MED)
    px(img, 6, 10, BLUE_DARK)
    px(img, 7, 10, BLUE_DARK)
    px(img, 8, 10, BLUE_DARK)
    px(img, 9, 10, BLUE_DARK)
    px(img, 10, 10, BLUE_MED)
    px(img, 11, 10, BLUE_LIGHT)

    # Row 11: dripping bottom
    px(img, 5, 11, BLUE_LIGHT)
    px(img, 6, 11, BLUE_MED)
    px(img, 7, 11, BLUE_DARK)
    px(img, 8, 11, BLUE_DARK)
    px(img, 9, 11, BLUE_MED)
    px(img, 10, 11, BLUE_LIGHT)

    # Row 12: drips
    px(img, 5, 12, BLUE_DRIP)
    px(img, 6, 12, BLUE_LIGHT)
    px(img, 7, 12, BLUE_MED)
    px(img, 8, 12, BLUE_MED)
    px(img, 9, 12, BLUE_LIGHT)
    px(img, 10, 12, BLUE_DRIP)

    # Row 13: drip drops
    px(img, 5, 13, BLUE_EDGE)
    px(img, 7, 13, BLUE_LIGHT)
    px(img, 8, 13, BLUE_LIGHT)
    px(img, 10, 13, BLUE_EDGE)

    # Row 14: final drops
    px(img, 6, 14, BLUE_DRIP)
    px(img, 7, 14, BLUE_EDGE)
    px(img, 8, 14, BLUE_EDGE)
    px(img, 9, 14, BLUE_DRIP)

    # Row 15: very last drips
    px(img, 6, 15, BLUE_EDGE)
    px(img, 9, 15, BLUE_EDGE)

    save(img, os.path.join(ENEMY_DIR, "enemy_sadness.png"))


def generate_enemy_loneliness():
    """Loneliness: Gray shadow figure, barely visible, humanoid, hollow eyes, fading."""
    img = make_image()

    GRAY_DARK = (58, 58, 66, 255)
    GRAY_MED = (70, 70, 80, 200)
    GRAY_LIGHT = (90, 90, 100, 150)
    GRAY_FADE = (75, 75, 85, 100)
    GRAY_WISP = (65, 65, 75, 60)
    HOLLOW = (20, 20, 25, 255)

    # Row 0: faint top of head
    px(img, 7, 0, GRAY_WISP)
    px(img, 8, 0, GRAY_WISP)

    # Row 1: head top
    px(img, 6, 1, GRAY_WISP)
    px(img, 7, 1, GRAY_FADE)
    px(img, 8, 1, GRAY_FADE)
    px(img, 9, 1, GRAY_WISP)

    # Row 2: head
    px(img, 5, 2, GRAY_WISP)
    px(img, 6, 2, GRAY_MED)
    px(img, 7, 2, GRAY_DARK)
    px(img, 8, 2, GRAY_DARK)
    px(img, 9, 2, GRAY_MED)
    px(img, 10, 2, GRAY_WISP)

    # Row 3: head with hollow eyes
    px(img, 5, 3, GRAY_FADE)
    px(img, 6, 3, GRAY_DARK)
    px(img, 7, 3, GRAY_DARK)
    px(img, 8, 3, GRAY_DARK)
    px(img, 9, 3, GRAY_DARK)
    px(img, 10, 3, GRAY_FADE)

    # Row 4: eye sockets
    px(img, 5, 4, GRAY_MED)
    px(img, 6, 4, HOLLOW)
    px(img, 7, 4, GRAY_DARK)
    px(img, 8, 4, GRAY_DARK)
    px(img, 9, 4, HOLLOW)
    px(img, 10, 4, GRAY_MED)

    # Row 5: below eyes
    px(img, 5, 5, GRAY_FADE)
    px(img, 6, 5, GRAY_DARK)
    px(img, 7, 5, GRAY_MED)
    px(img, 8, 5, GRAY_MED)
    px(img, 9, 5, GRAY_DARK)
    px(img, 10, 5, GRAY_FADE)

    # Row 6: neck/shoulder transition
    px(img, 6, 6, GRAY_FADE)
    px(img, 7, 6, GRAY_DARK)
    px(img, 8, 6, GRAY_DARK)
    px(img, 9, 6, GRAY_FADE)

    # Row 7: shoulders
    px(img, 4, 7, GRAY_WISP)
    px(img, 5, 7, GRAY_FADE)
    px(img, 6, 7, GRAY_MED)
    px(img, 7, 7, GRAY_DARK)
    px(img, 8, 7, GRAY_DARK)
    px(img, 9, 7, GRAY_MED)
    px(img, 10, 7, GRAY_FADE)
    px(img, 11, 7, GRAY_WISP)

    # Row 8: torso
    px(img, 4, 8, GRAY_WISP)
    px(img, 5, 8, GRAY_FADE)
    px(img, 6, 8, GRAY_MED)
    px(img, 7, 8, GRAY_DARK)
    px(img, 8, 8, GRAY_DARK)
    px(img, 9, 8, GRAY_MED)
    px(img, 10, 8, GRAY_FADE)
    px(img, 11, 8, GRAY_WISP)

    # Row 9: lower torso
    px(img, 5, 9, GRAY_WISP)
    px(img, 6, 9, GRAY_FADE)
    px(img, 7, 9, GRAY_MED)
    px(img, 8, 9, GRAY_MED)
    px(img, 9, 9, GRAY_FADE)
    px(img, 10, 9, GRAY_WISP)

    # Row 10: hips / legs start
    px(img, 5, 10, GRAY_WISP)
    px(img, 6, 10, GRAY_FADE)
    px(img, 7, 10, GRAY_MED)
    px(img, 8, 10, GRAY_MED)
    px(img, 9, 10, GRAY_FADE)
    px(img, 10, 10, GRAY_WISP)

    # Row 11: legs fading
    px(img, 6, 11, GRAY_WISP)
    px(img, 7, 11, GRAY_FADE)
    px(img, 8, 11, GRAY_FADE)
    px(img, 9, 11, GRAY_WISP)

    # Row 12: legs nearly gone
    px(img, 6, 12, GRAY_WISP)
    px(img, 7, 12, GRAY_WISP)
    px(img, 8, 12, GRAY_WISP)
    px(img, 9, 12, GRAY_WISP)

    # Row 13-15: fading into nothing
    px(img, 7, 13, GRAY_WISP)
    px(img, 8, 13, GRAY_WISP)
    px(img, 7, 14, (65, 65, 75, 30))
    px(img, 8, 14, (65, 65, 75, 30))

    save(img, os.path.join(ENEMY_DIR, "enemy_loneliness.png"))


# =============================================================================
# NPC SPRITES
# =============================================================================

def generate_lewis():
    """Lewis: Bully leader. Red shirt, spiky dark hair, mean expression, bigger."""
    img = make_image()

    RED_SHIRT = (204, 51, 51, 255)
    RED_DARK = (170, 40, 40, 255)
    HAIR = DARK_BROWN_HAIR
    BROW_ANGRY = (40, 25, 15, 255)

    # Row 0: spiky hair top
    px(img, 5, 0, HAIR)
    px(img, 7, 0, HAIR)
    px(img, 9, 0, HAIR)
    px(img, 11, 0, HAIR)

    # Row 1: spiky hair
    px(img, 4, 1, HAIR)
    px(img, 5, 1, HAIR)
    px(img, 6, 1, HAIR)
    px(img, 7, 1, HAIR)
    px(img, 8, 1, HAIR)
    px(img, 9, 1, HAIR)
    px(img, 10, 1, HAIR)
    px(img, 11, 1, HAIR)

    # Row 2: hair lower
    px(img, 4, 2, HAIR)
    px(img, 5, 2, HAIR)
    px(img, 6, 2, HAIR)
    px(img, 7, 2, HAIR)
    px(img, 8, 2, HAIR)
    px(img, 9, 2, HAIR)
    px(img, 10, 2, HAIR)
    px(img, 11, 2, HAIR)

    # Row 3: forehead + hair sides
    px(img, 4, 3, HAIR)
    px(img, 5, 3, SKIN)
    px(img, 6, 3, SKIN)
    px(img, 7, 3, SKIN)
    px(img, 8, 3, SKIN)
    px(img, 9, 3, SKIN)
    px(img, 10, 3, SKIN)
    px(img, 11, 3, HAIR)

    # Row 4: angry eyebrows and eyes
    px(img, 4, 4, HAIR)
    px(img, 5, 4, BROW_ANGRY)  # left brow angled down-inward
    px(img, 6, 4, SKIN)
    px(img, 7, 4, SKIN)
    px(img, 8, 4, SKIN)
    px(img, 9, 4, SKIN)
    px(img, 10, 4, BROW_ANGRY)  # right brow angled
    px(img, 11, 4, HAIR)

    # Row 5: eyes
    px(img, 4, 5, HAIR)
    px(img, 5, 5, SKIN)
    px(img, 6, 5, EYE_BLACK)
    px(img, 7, 5, SKIN)
    px(img, 8, 5, SKIN)
    px(img, 9, 5, EYE_BLACK)
    px(img, 10, 5, SKIN)
    px(img, 11, 5, HAIR)

    # Row 6: mouth (mean smirk)
    px(img, 4, 6, SKIN_DARK)
    px(img, 5, 6, SKIN)
    px(img, 6, 6, SKIN)
    px(img, 7, 6, MOUTH)
    px(img, 8, 6, MOUTH)
    px(img, 9, 6, SKIN)
    px(img, 10, 6, SKIN)
    px(img, 11, 6, SKIN_DARK)

    # Row 7: neck / shirt collar
    px(img, 5, 7, SKIN)
    px(img, 6, 7, SKIN)
    px(img, 7, 7, SKIN)
    px(img, 8, 7, SKIN)
    px(img, 9, 7, SKIN)
    px(img, 10, 7, SKIN)

    # Row 8: shirt top (wider - he's bigger)
    px(img, 3, 8, RED_DARK)
    px(img, 4, 8, RED_SHIRT)
    px(img, 5, 8, RED_SHIRT)
    px(img, 6, 8, RED_SHIRT)
    px(img, 7, 8, RED_SHIRT)
    px(img, 8, 8, RED_SHIRT)
    px(img, 9, 8, RED_SHIRT)
    px(img, 10, 8, RED_SHIRT)
    px(img, 11, 8, RED_SHIRT)
    px(img, 12, 8, RED_DARK)

    # Row 9: shirt + arms
    px(img, 3, 9, RED_DARK)
    px(img, 4, 9, RED_SHIRT)
    px(img, 5, 9, RED_SHIRT)
    px(img, 6, 9, RED_SHIRT)
    px(img, 7, 9, RED_SHIRT)
    px(img, 8, 9, RED_SHIRT)
    px(img, 9, 9, RED_SHIRT)
    px(img, 10, 9, RED_SHIRT)
    px(img, 11, 9, RED_SHIRT)
    px(img, 12, 9, RED_DARK)

    # Row 10: shirt lower + skin arms
    px(img, 3, 10, SKIN)
    px(img, 4, 10, RED_SHIRT)
    px(img, 5, 10, RED_SHIRT)
    px(img, 6, 10, RED_SHIRT)
    px(img, 7, 10, RED_SHIRT)
    px(img, 8, 10, RED_SHIRT)
    px(img, 9, 10, RED_SHIRT)
    px(img, 10, 10, RED_SHIRT)
    px(img, 11, 10, RED_SHIRT)
    px(img, 12, 10, SKIN)

    # Row 11: belt / pants start
    px(img, 4, 11, PANTS_DARK)
    px(img, 5, 11, PANTS_DARK)
    px(img, 6, 11, PANTS_DARK)
    px(img, 7, 11, PANTS_DARK)
    px(img, 8, 11, PANTS_DARK)
    px(img, 9, 11, PANTS_DARK)
    px(img, 10, 11, PANTS_DARK)
    px(img, 11, 11, PANTS_DARK)

    # Row 12: pants / legs
    px(img, 4, 12, PANTS_DARK)
    px(img, 5, 12, PANTS_DARK)
    px(img, 6, 12, PANTS_DARK)
    px(img, 7, 12, T)
    px(img, 8, 12, T)
    px(img, 9, 12, PANTS_DARK)
    px(img, 10, 12, PANTS_DARK)
    px(img, 11, 12, PANTS_DARK)

    # Row 13: legs
    px(img, 4, 13, PANTS_DARK)
    px(img, 5, 13, PANTS_DARK)
    px(img, 6, 13, PANTS_DARK)
    px(img, 9, 13, PANTS_DARK)
    px(img, 10, 13, PANTS_DARK)
    px(img, 11, 13, PANTS_DARK)

    # Row 14: shoes
    px(img, 4, 14, SHOE_BLACK)
    px(img, 5, 14, SHOE_BLACK)
    px(img, 6, 14, SHOE_BLACK)
    px(img, 9, 14, SHOE_BLACK)
    px(img, 10, 14, SHOE_BLACK)
    px(img, 11, 14, SHOE_BLACK)

    # Row 15: shoe soles
    px(img, 3, 15, SHOE_BLACK)
    px(img, 4, 15, SHOE_BLACK)
    px(img, 5, 15, SHOE_BLACK)
    px(img, 6, 15, SHOE_BLACK)
    px(img, 9, 15, SHOE_BLACK)
    px(img, 10, 15, SHOE_BLACK)
    px(img, 11, 15, SHOE_BLACK)
    px(img, 12, 15, SHOE_BLACK)

    save(img, os.path.join(NPC_DIR, "lewis.png"))


def generate_joan():
    """Joan: Bully. Green shirt, cap, smirking."""
    img = make_image()

    GREEN = (51, 153, 51, 255)
    GREEN_DARK = (40, 120, 40, 255)
    CAP = (50, 50, 130, 255)
    CAP_BRIM = (40, 40, 110, 255)
    HAIR = DARK_BROWN_HAIR

    # Row 0: cap top
    px(img, 5, 0, CAP)
    px(img, 6, 0, CAP)
    px(img, 7, 0, CAP)
    px(img, 8, 0, CAP)
    px(img, 9, 0, CAP)
    px(img, 10, 0, CAP)

    # Row 1: cap
    px(img, 5, 1, CAP)
    px(img, 6, 1, CAP)
    px(img, 7, 1, CAP)
    px(img, 8, 1, CAP)
    px(img, 9, 1, CAP)
    px(img, 10, 1, CAP)

    # Row 2: cap brim extending forward
    px(img, 4, 2, CAP_BRIM)
    px(img, 5, 2, CAP_BRIM)
    px(img, 6, 2, CAP_BRIM)
    px(img, 7, 2, CAP_BRIM)
    px(img, 8, 2, CAP_BRIM)
    px(img, 9, 2, CAP_BRIM)
    px(img, 10, 2, CAP_BRIM)
    px(img, 11, 2, CAP_BRIM)

    # Row 3: forehead with some hair peaking from cap
    px(img, 5, 3, HAIR)
    px(img, 6, 3, SKIN)
    px(img, 7, 3, SKIN)
    px(img, 8, 3, SKIN)
    px(img, 9, 3, SKIN)
    px(img, 10, 3, HAIR)

    # Row 4: eyes
    px(img, 5, 4, SKIN)
    px(img, 6, 4, EYE_BLACK)
    px(img, 7, 4, SKIN)
    px(img, 8, 4, SKIN)
    px(img, 9, 4, EYE_BLACK)
    px(img, 10, 4, SKIN)

    # Row 5: smirk face
    px(img, 5, 5, SKIN)
    px(img, 6, 5, SKIN)
    px(img, 7, 5, SKIN)
    px(img, 8, 5, MOUTH)
    px(img, 9, 5, MOUTH)
    px(img, 10, 5, SKIN)

    # Row 6: chin
    px(img, 6, 6, SKIN)
    px(img, 7, 6, SKIN)
    px(img, 8, 6, SKIN)
    px(img, 9, 6, SKIN)

    # Row 7: neck
    px(img, 7, 7, SKIN)
    px(img, 8, 7, SKIN)

    # Row 8: shirt top
    px(img, 4, 8, GREEN_DARK)
    px(img, 5, 8, GREEN)
    px(img, 6, 8, GREEN)
    px(img, 7, 8, GREEN)
    px(img, 8, 8, GREEN)
    px(img, 9, 8, GREEN)
    px(img, 10, 8, GREEN)
    px(img, 11, 8, GREEN_DARK)

    # Row 9: shirt + arms
    px(img, 4, 9, SKIN)
    px(img, 5, 9, GREEN)
    px(img, 6, 9, GREEN)
    px(img, 7, 9, GREEN)
    px(img, 8, 9, GREEN)
    px(img, 9, 9, GREEN)
    px(img, 10, 9, GREEN)
    px(img, 11, 9, SKIN)

    # Row 10: lower shirt
    px(img, 4, 10, SKIN)
    px(img, 5, 10, GREEN)
    px(img, 6, 10, GREEN)
    px(img, 7, 10, GREEN)
    px(img, 8, 10, GREEN)
    px(img, 9, 10, GREEN)
    px(img, 10, 10, GREEN)
    px(img, 11, 10, SKIN)

    # Row 11: pants
    px(img, 5, 11, PANTS_BLUE)
    px(img, 6, 11, PANTS_BLUE)
    px(img, 7, 11, PANTS_BLUE)
    px(img, 8, 11, PANTS_BLUE)
    px(img, 9, 11, PANTS_BLUE)
    px(img, 10, 11, PANTS_BLUE)

    # Row 12: legs
    px(img, 5, 12, PANTS_BLUE)
    px(img, 6, 12, PANTS_BLUE)
    px(img, 9, 12, PANTS_BLUE)
    px(img, 10, 12, PANTS_BLUE)

    # Row 13: legs lower
    px(img, 5, 13, PANTS_BLUE)
    px(img, 6, 13, PANTS_BLUE)
    px(img, 9, 13, PANTS_BLUE)
    px(img, 10, 13, PANTS_BLUE)

    # Row 14: shoes
    px(img, 5, 14, SHOE_BLACK)
    px(img, 6, 14, SHOE_BLACK)
    px(img, 9, 14, SHOE_BLACK)
    px(img, 10, 14, SHOE_BLACK)

    # Row 15: shoe soles
    px(img, 4, 15, SHOE_BLACK)
    px(img, 5, 15, SHOE_BLACK)
    px(img, 6, 15, SHOE_BLACK)
    px(img, 9, 15, SHOE_BLACK)
    px(img, 10, 15, SHOE_BLACK)
    px(img, 11, 15, SHOE_BLACK)

    save(img, os.path.join(NPC_DIR, "joan.png"))


def generate_robert():
    """Robert: Bully. Orange shirt, stocky build."""
    img = make_image()

    ORANGE = (204, 119, 51, 255)
    ORANGE_DARK = (170, 95, 40, 255)
    HAIR = DARK_BROWN_HAIR

    # Row 0: hair (short, brown)
    px(img, 5, 0, HAIR)
    px(img, 6, 0, HAIR)
    px(img, 7, 0, HAIR)
    px(img, 8, 0, HAIR)
    px(img, 9, 0, HAIR)
    px(img, 10, 0, HAIR)

    # Row 1: hair
    px(img, 5, 1, HAIR)
    px(img, 6, 1, HAIR)
    px(img, 7, 1, HAIR)
    px(img, 8, 1, HAIR)
    px(img, 9, 1, HAIR)
    px(img, 10, 1, HAIR)

    # Row 2: hair + forehead
    px(img, 5, 2, HAIR)
    px(img, 6, 2, HAIR)
    px(img, 7, 2, SKIN)
    px(img, 8, 2, SKIN)
    px(img, 9, 2, HAIR)
    px(img, 10, 2, HAIR)

    # Row 3: face
    px(img, 5, 3, HAIR)
    px(img, 6, 3, SKIN)
    px(img, 7, 3, SKIN)
    px(img, 8, 3, SKIN)
    px(img, 9, 3, SKIN)
    px(img, 10, 3, HAIR)

    # Row 4: eyes
    px(img, 5, 4, SKIN)
    px(img, 6, 4, EYE_BLACK)
    px(img, 7, 4, SKIN)
    px(img, 8, 4, SKIN)
    px(img, 9, 4, EYE_BLACK)
    px(img, 10, 4, SKIN)

    # Row 5: mouth (neutral tough)
    px(img, 5, 5, SKIN)
    px(img, 6, 5, SKIN)
    px(img, 7, 5, MOUTH)
    px(img, 8, 5, MOUTH)
    px(img, 9, 5, SKIN)
    px(img, 10, 5, SKIN)

    # Row 6: chin (wide - stocky)
    px(img, 5, 6, SKIN)
    px(img, 6, 6, SKIN)
    px(img, 7, 6, SKIN)
    px(img, 8, 6, SKIN)
    px(img, 9, 6, SKIN)
    px(img, 10, 6, SKIN)

    # Row 7: neck (thick)
    px(img, 6, 7, SKIN)
    px(img, 7, 7, SKIN)
    px(img, 8, 7, SKIN)
    px(img, 9, 7, SKIN)

    # Row 8: shirt top (stocky = wider)
    px(img, 3, 8, ORANGE_DARK)
    px(img, 4, 8, ORANGE)
    px(img, 5, 8, ORANGE)
    px(img, 6, 8, ORANGE)
    px(img, 7, 8, ORANGE)
    px(img, 8, 8, ORANGE)
    px(img, 9, 8, ORANGE)
    px(img, 10, 8, ORANGE)
    px(img, 11, 8, ORANGE)
    px(img, 12, 8, ORANGE_DARK)

    # Row 9: shirt + arms
    px(img, 3, 9, SKIN)
    px(img, 4, 9, ORANGE)
    px(img, 5, 9, ORANGE)
    px(img, 6, 9, ORANGE)
    px(img, 7, 9, ORANGE)
    px(img, 8, 9, ORANGE)
    px(img, 9, 9, ORANGE)
    px(img, 10, 9, ORANGE)
    px(img, 11, 9, ORANGE)
    px(img, 12, 9, SKIN)

    # Row 10: shirt lower
    px(img, 3, 10, SKIN)
    px(img, 4, 10, ORANGE)
    px(img, 5, 10, ORANGE)
    px(img, 6, 10, ORANGE)
    px(img, 7, 10, ORANGE)
    px(img, 8, 10, ORANGE)
    px(img, 9, 10, ORANGE)
    px(img, 10, 10, ORANGE)
    px(img, 11, 10, ORANGE)
    px(img, 12, 10, SKIN)

    # Row 11: pants (stocky)
    px(img, 4, 11, PANTS_BROWN)
    px(img, 5, 11, PANTS_BROWN)
    px(img, 6, 11, PANTS_BROWN)
    px(img, 7, 11, PANTS_BROWN)
    px(img, 8, 11, PANTS_BROWN)
    px(img, 9, 11, PANTS_BROWN)
    px(img, 10, 11, PANTS_BROWN)
    px(img, 11, 11, PANTS_BROWN)

    # Row 12: legs (stocky wide)
    px(img, 4, 12, PANTS_BROWN)
    px(img, 5, 12, PANTS_BROWN)
    px(img, 6, 12, PANTS_BROWN)
    px(img, 9, 12, PANTS_BROWN)
    px(img, 10, 12, PANTS_BROWN)
    px(img, 11, 12, PANTS_BROWN)

    # Row 13: legs
    px(img, 4, 13, PANTS_BROWN)
    px(img, 5, 13, PANTS_BROWN)
    px(img, 6, 13, PANTS_BROWN)
    px(img, 9, 13, PANTS_BROWN)
    px(img, 10, 13, PANTS_BROWN)
    px(img, 11, 13, PANTS_BROWN)

    # Row 14: shoes
    px(img, 4, 14, SHOE_BLACK)
    px(img, 5, 14, SHOE_BLACK)
    px(img, 6, 14, SHOE_BLACK)
    px(img, 9, 14, SHOE_BLACK)
    px(img, 10, 14, SHOE_BLACK)
    px(img, 11, 14, SHOE_BLACK)

    # Row 15: shoe soles
    px(img, 3, 15, SHOE_BLACK)
    px(img, 4, 15, SHOE_BLACK)
    px(img, 5, 15, SHOE_BLACK)
    px(img, 6, 15, SHOE_BLACK)
    px(img, 9, 15, SHOE_BLACK)
    px(img, 10, 15, SHOE_BLACK)
    px(img, 11, 15, SHOE_BLACK)
    px(img, 12, 15, SHOE_BLACK)

    save(img, os.path.join(NPC_DIR, "robert.png"))


def generate_mike():
    """Mike: Bully. Yellow shirt, tall and thin."""
    img = make_image()

    YELLOW = (204, 204, 51, 255)
    YELLOW_DARK = (170, 170, 40, 255)
    HAIR = DARK_BROWN_HAIR

    # Row 0: hair top (narrow - thin character)
    px(img, 6, 0, HAIR)
    px(img, 7, 0, HAIR)
    px(img, 8, 0, HAIR)
    px(img, 9, 0, HAIR)

    # Row 1: hair
    px(img, 6, 1, HAIR)
    px(img, 7, 1, HAIR)
    px(img, 8, 1, HAIR)
    px(img, 9, 1, HAIR)

    # Row 2: forehead
    px(img, 6, 2, HAIR)
    px(img, 7, 2, SKIN)
    px(img, 8, 2, SKIN)
    px(img, 9, 2, HAIR)

    # Row 3: eyes
    px(img, 6, 3, SKIN)
    px(img, 7, 3, EYE_BLACK)
    px(img, 8, 3, EYE_BLACK)
    px(img, 9, 3, SKIN)

    # Row 4: nose/mouth
    px(img, 6, 4, SKIN)
    px(img, 7, 4, SKIN)
    px(img, 8, 4, MOUTH)
    px(img, 9, 4, SKIN)

    # Row 5: chin
    px(img, 6, 5, SKIN)
    px(img, 7, 5, SKIN)
    px(img, 8, 5, SKIN)
    px(img, 9, 5, SKIN)

    # Row 6: neck (thin)
    px(img, 7, 6, SKIN)
    px(img, 8, 6, SKIN)

    # Row 7: shirt top (narrow)
    px(img, 5, 7, YELLOW_DARK)
    px(img, 6, 7, YELLOW)
    px(img, 7, 7, YELLOW)
    px(img, 8, 7, YELLOW)
    px(img, 9, 7, YELLOW)
    px(img, 10, 7, YELLOW_DARK)

    # Row 8: shirt + arms
    px(img, 5, 8, SKIN)
    px(img, 6, 8, YELLOW)
    px(img, 7, 8, YELLOW)
    px(img, 8, 8, YELLOW)
    px(img, 9, 8, YELLOW)
    px(img, 10, 8, SKIN)

    # Row 9: shirt
    px(img, 6, 9, YELLOW)
    px(img, 7, 9, YELLOW)
    px(img, 8, 9, YELLOW)
    px(img, 9, 9, YELLOW)

    # Row 10: pants start (thin)
    px(img, 6, 10, PANTS_BLUE)
    px(img, 7, 10, PANTS_BLUE)
    px(img, 8, 10, PANTS_BLUE)
    px(img, 9, 10, PANTS_BLUE)

    # Row 11: legs
    px(img, 6, 11, PANTS_BLUE)
    px(img, 7, 11, PANTS_BLUE)
    px(img, 8, 11, PANTS_BLUE)
    px(img, 9, 11, PANTS_BLUE)

    # Row 12: legs separated
    px(img, 6, 12, PANTS_BLUE)
    px(img, 7, 12, T)
    px(img, 8, 12, T)
    px(img, 9, 12, PANTS_BLUE)

    # Row 13: legs
    px(img, 6, 13, PANTS_BLUE)
    px(img, 9, 13, PANTS_BLUE)

    # Row 14: shoes
    px(img, 6, 14, SHOE_BLACK)
    px(img, 9, 14, SHOE_BLACK)

    # Row 15: shoe soles
    px(img, 5, 15, SHOE_BLACK)
    px(img, 6, 15, SHOE_BLACK)
    px(img, 9, 15, SHOE_BLACK)
    px(img, 10, 15, SHOE_BLACK)

    save(img, os.path.join(NPC_DIR, "mike.png"))


def generate_lucy():
    """Lucy: Friendly classmate. Pink top, brown hair, kind eyes."""
    img = make_image()

    PINK = (221, 136, 170, 255)
    PINK_DARK = (190, 110, 145, 255)
    HAIR = BROWN_HAIR
    HAIR_DARK = (80, 50, 25, 255)
    EYE_KIND = (40, 80, 40, 255)  # soft green-brown kind eyes
    SKIRT = (120, 60, 90, 255)

    # Row 0: hair top
    px(img, 5, 0, HAIR)
    px(img, 6, 0, HAIR)
    px(img, 7, 0, HAIR)
    px(img, 8, 0, HAIR)
    px(img, 9, 0, HAIR)
    px(img, 10, 0, HAIR)

    # Row 1: hair
    px(img, 5, 1, HAIR)
    px(img, 6, 1, HAIR)
    px(img, 7, 1, HAIR)
    px(img, 8, 1, HAIR)
    px(img, 9, 1, HAIR)
    px(img, 10, 1, HAIR)

    # Row 2: hair with forehead showing
    px(img, 5, 2, HAIR)
    px(img, 6, 2, HAIR_DARK)
    px(img, 7, 2, SKIN)
    px(img, 8, 2, SKIN)
    px(img, 9, 2, HAIR_DARK)
    px(img, 10, 2, HAIR)

    # Row 3: face - hair sides, forehead
    px(img, 5, 3, HAIR)
    px(img, 6, 3, SKIN)
    px(img, 7, 3, SKIN)
    px(img, 8, 3, SKIN)
    px(img, 9, 3, SKIN)
    px(img, 10, 3, HAIR)

    # Row 4: eyes (kind - slightly larger/rounder impression)
    px(img, 5, 4, HAIR)
    px(img, 6, 4, EYE_KIND)
    px(img, 7, 4, SKIN)
    px(img, 8, 4, SKIN)
    px(img, 9, 4, EYE_KIND)
    px(img, 10, 4, HAIR)

    # Row 5: smile
    px(img, 5, 5, HAIR_DARK)
    px(img, 6, 5, SKIN)
    px(img, 7, 5, MOUTH)
    px(img, 8, 5, MOUTH)
    px(img, 9, 5, SKIN)
    px(img, 10, 5, HAIR_DARK)

    # Row 6: chin, hair falls beside face
    px(img, 5, 6, HAIR)
    px(img, 6, 6, SKIN)
    px(img, 7, 6, SKIN)
    px(img, 8, 6, SKIN)
    px(img, 9, 6, SKIN)
    px(img, 10, 6, HAIR)

    # Row 7: neck + hair on sides (longer hair)
    px(img, 5, 7, HAIR)
    px(img, 7, 7, SKIN)
    px(img, 8, 7, SKIN)
    px(img, 10, 7, HAIR)

    # Row 8: top / shoulders
    px(img, 4, 8, PINK_DARK)
    px(img, 5, 8, PINK)
    px(img, 6, 8, PINK)
    px(img, 7, 8, PINK)
    px(img, 8, 8, PINK)
    px(img, 9, 8, PINK)
    px(img, 10, 8, PINK)
    px(img, 11, 8, PINK_DARK)

    # Row 9: top + arms
    px(img, 4, 9, SKIN)
    px(img, 5, 9, PINK)
    px(img, 6, 9, PINK)
    px(img, 7, 9, PINK)
    px(img, 8, 9, PINK)
    px(img, 9, 9, PINK)
    px(img, 10, 9, PINK)
    px(img, 11, 9, SKIN)

    # Row 10: lower top
    px(img, 5, 10, PINK)
    px(img, 6, 10, PINK)
    px(img, 7, 10, PINK)
    px(img, 8, 10, PINK)
    px(img, 9, 10, PINK)
    px(img, 10, 10, PINK)

    # Row 11: skirt
    px(img, 4, 11, SKIRT)
    px(img, 5, 11, SKIRT)
    px(img, 6, 11, SKIRT)
    px(img, 7, 11, SKIRT)
    px(img, 8, 11, SKIRT)
    px(img, 9, 11, SKIRT)
    px(img, 10, 11, SKIRT)
    px(img, 11, 11, SKIRT)

    # Row 12: skirt lower
    px(img, 5, 12, SKIRT)
    px(img, 6, 12, SKIRT)
    px(img, 7, 12, SKIRT)
    px(img, 8, 12, SKIRT)
    px(img, 9, 12, SKIRT)
    px(img, 10, 12, SKIRT)

    # Row 13: legs (skin)
    px(img, 6, 13, SKIN)
    px(img, 7, 13, SKIN)
    px(img, 8, 13, SKIN)
    px(img, 9, 13, SKIN)

    # Row 14: shoes
    px(img, 5, 14, SHOE_BROWN)
    px(img, 6, 14, SHOE_BROWN)
    px(img, 9, 14, SHOE_BROWN)
    px(img, 10, 14, SHOE_BROWN)

    # Row 15: shoe soles
    px(img, 5, 15, SHOE_BROWN)
    px(img, 6, 15, SHOE_BROWN)
    px(img, 9, 15, SHOE_BROWN)
    px(img, 10, 15, SHOE_BROWN)

    save(img, os.path.join(NPC_DIR, "lucy.png"))


def generate_teacher():
    """Teacher (Don Peter): White shirt, glasses, gray hair, tie."""
    img = make_image()

    SHIRT_WHITE = (240, 240, 245, 255)
    SHIRT_SHADE = (215, 215, 225, 255)
    GLASSES = (150, 190, 230, 255)  # light blue
    GLASSES_FRAME = (60, 60, 70, 255)
    TIE = TIE_RED
    TIE_DARK = (140, 30, 30, 255)

    # Row 0: gray hair top
    px(img, 5, 0, GRAY_HAIR)
    px(img, 6, 0, GRAY_HAIR)
    px(img, 7, 0, GRAY_HAIR)
    px(img, 8, 0, GRAY_HAIR)
    px(img, 9, 0, GRAY_HAIR)
    px(img, 10, 0, GRAY_HAIR)

    # Row 1: hair
    px(img, 5, 1, GRAY_HAIR)
    px(img, 6, 1, GRAY_HAIR)
    px(img, 7, 1, GRAY_HAIR)
    px(img, 8, 1, GRAY_HAIR)
    px(img, 9, 1, GRAY_HAIR)
    px(img, 10, 1, GRAY_HAIR)

    # Row 2: forehead
    px(img, 5, 2, GRAY_HAIR)
    px(img, 6, 2, SKIN)
    px(img, 7, 2, SKIN)
    px(img, 8, 2, SKIN)
    px(img, 9, 2, SKIN)
    px(img, 10, 2, GRAY_HAIR)

    # Row 3: forehead + glasses frames above eyes
    px(img, 5, 3, GRAY_HAIR)
    px(img, 6, 3, SKIN)
    px(img, 7, 3, SKIN)
    px(img, 8, 3, SKIN)
    px(img, 9, 3, SKIN)
    px(img, 10, 3, GRAY_HAIR)

    # Row 4: glasses + eyes (light blue pixels for glasses lenses)
    px(img, 5, 4, SKIN)
    px(img, 6, 4, GLASSES)  # left lens (light blue)
    px(img, 7, 4, GLASSES_FRAME)  # bridge
    px(img, 8, 4, GLASSES_FRAME)  # bridge
    px(img, 9, 4, GLASSES)  # right lens (light blue)
    px(img, 10, 4, SKIN)

    # Row 5: below glasses, mouth
    px(img, 5, 5, SKIN)
    px(img, 6, 5, SKIN)
    px(img, 7, 5, SKIN)
    px(img, 8, 5, SKIN)
    px(img, 9, 5, SKIN)
    px(img, 10, 5, SKIN)

    # Row 6: mouth area
    px(img, 6, 6, SKIN)
    px(img, 7, 6, MOUTH)
    px(img, 8, 6, MOUTH)
    px(img, 9, 6, SKIN)

    # Row 7: neck + collar
    px(img, 6, 7, SKIN)
    px(img, 7, 7, SKIN)
    px(img, 8, 7, SKIN)
    px(img, 9, 7, SKIN)

    # Row 8: shirt top with tie
    px(img, 4, 8, SHIRT_SHADE)
    px(img, 5, 8, SHIRT_WHITE)
    px(img, 6, 8, SHIRT_WHITE)
    px(img, 7, 8, TIE)
    px(img, 8, 8, TIE)
    px(img, 9, 8, SHIRT_WHITE)
    px(img, 10, 8, SHIRT_WHITE)
    px(img, 11, 8, SHIRT_SHADE)

    # Row 9: shirt + tie + arms
    px(img, 4, 9, SKIN)
    px(img, 5, 9, SHIRT_WHITE)
    px(img, 6, 9, SHIRT_WHITE)
    px(img, 7, 9, TIE_DARK)
    px(img, 8, 9, TIE_DARK)
    px(img, 9, 9, SHIRT_WHITE)
    px(img, 10, 9, SHIRT_WHITE)
    px(img, 11, 9, SKIN)

    # Row 10: shirt lower with tie
    px(img, 5, 10, SHIRT_WHITE)
    px(img, 6, 10, SHIRT_WHITE)
    px(img, 7, 10, TIE)
    px(img, 8, 10, SHIRT_WHITE)
    px(img, 9, 10, SHIRT_WHITE)
    px(img, 10, 10, SHIRT_WHITE)

    # Row 11: pants
    px(img, 5, 11, PANTS_GRAY)
    px(img, 6, 11, PANTS_GRAY)
    px(img, 7, 11, PANTS_GRAY)
    px(img, 8, 11, PANTS_GRAY)
    px(img, 9, 11, PANTS_GRAY)
    px(img, 10, 11, PANTS_GRAY)

    # Row 12: legs
    px(img, 5, 12, PANTS_GRAY)
    px(img, 6, 12, PANTS_GRAY)
    px(img, 9, 12, PANTS_GRAY)
    px(img, 10, 12, PANTS_GRAY)

    # Row 13: legs
    px(img, 5, 13, PANTS_GRAY)
    px(img, 6, 13, PANTS_GRAY)
    px(img, 9, 13, PANTS_GRAY)
    px(img, 10, 13, PANTS_GRAY)

    # Row 14: shoes
    px(img, 5, 14, SHOE_BLACK)
    px(img, 6, 14, SHOE_BLACK)
    px(img, 9, 14, SHOE_BLACK)
    px(img, 10, 14, SHOE_BLACK)

    # Row 15: shoe soles
    px(img, 4, 15, SHOE_BLACK)
    px(img, 5, 15, SHOE_BLACK)
    px(img, 6, 15, SHOE_BLACK)
    px(img, 9, 15, SHOE_BLACK)
    px(img, 10, 15, SHOE_BLACK)
    px(img, 11, 15, SHOE_BLACK)

    save(img, os.path.join(NPC_DIR, "teacher.png"))


def generate_grandma():
    """Grandma (Abuela): White/gray hair, warm shawl, kind face, slightly hunched."""
    img = make_image()

    SHAWL = (170, 119, 68, 255)
    SHAWL_DARK = (140, 95, 55, 255)
    DRESS = (130, 90, 60, 255)
    DRESS_DARK = (110, 75, 50, 255)

    # Row 0: white/gray hair bun top
    px(img, 6, 0, WHITE_HAIR)
    px(img, 7, 0, WHITE_HAIR)
    px(img, 8, 0, WHITE_HAIR)

    # Row 1: hair
    px(img, 5, 1, WHITE_HAIR)
    px(img, 6, 1, WHITE_HAIR)
    px(img, 7, 1, GRAY_HAIR)
    px(img, 8, 1, WHITE_HAIR)
    px(img, 9, 1, WHITE_HAIR)

    # Row 2: hair + forehead
    px(img, 5, 2, WHITE_HAIR)
    px(img, 6, 2, GRAY_HAIR)
    px(img, 7, 2, SKIN)
    px(img, 8, 2, SKIN)
    px(img, 9, 2, GRAY_HAIR)
    px(img, 10, 2, WHITE_HAIR)

    # Row 3: face
    px(img, 5, 3, WHITE_HAIR)
    px(img, 6, 3, SKIN)
    px(img, 7, 3, SKIN)
    px(img, 8, 3, SKIN)
    px(img, 9, 3, SKIN)
    px(img, 10, 3, WHITE_HAIR)

    # Row 4: kind eyes (small, warm)
    px(img, 5, 4, SKIN_DARK)
    px(img, 6, 4, EYE_BLACK)
    px(img, 7, 4, SKIN)
    px(img, 8, 4, SKIN)
    px(img, 9, 4, EYE_BLACK)
    px(img, 10, 4, SKIN_DARK)

    # Row 5: smile (warm, kind)
    px(img, 6, 5, SKIN)
    px(img, 7, 5, MOUTH)
    px(img, 8, 5, MOUTH)
    px(img, 9, 5, SKIN)

    # Row 6: chin
    px(img, 6, 6, SKIN)
    px(img, 7, 6, SKIN)
    px(img, 8, 6, SKIN)
    px(img, 9, 6, SKIN)

    # Row 7: shawl top (hunched - shifted slightly)
    px(img, 4, 7, SHAWL_DARK)
    px(img, 5, 7, SHAWL)
    px(img, 6, 7, SHAWL)
    px(img, 7, 7, SHAWL)
    px(img, 8, 7, SHAWL)
    px(img, 9, 7, SHAWL)
    px(img, 10, 7, SHAWL)
    px(img, 11, 7, SHAWL_DARK)

    # Row 8: shawl
    px(img, 4, 8, SHAWL_DARK)
    px(img, 5, 8, SHAWL)
    px(img, 6, 8, SHAWL)
    px(img, 7, 8, SHAWL_DARK)
    px(img, 8, 8, SHAWL_DARK)
    px(img, 9, 8, SHAWL)
    px(img, 10, 8, SHAWL)
    px(img, 11, 8, SHAWL_DARK)

    # Row 9: shawl lower / dress
    px(img, 4, 9, SHAWL)
    px(img, 5, 9, SHAWL)
    px(img, 6, 9, DRESS)
    px(img, 7, 9, DRESS)
    px(img, 8, 9, DRESS)
    px(img, 9, 9, DRESS)
    px(img, 10, 9, SHAWL)
    px(img, 11, 9, SHAWL)

    # Row 10: dress
    px(img, 5, 10, DRESS)
    px(img, 6, 10, DRESS)
    px(img, 7, 10, DRESS)
    px(img, 8, 10, DRESS)
    px(img, 9, 10, DRESS)
    px(img, 10, 10, DRESS)

    # Row 11: dress lower
    px(img, 5, 11, DRESS)
    px(img, 6, 11, DRESS)
    px(img, 7, 11, DRESS_DARK)
    px(img, 8, 11, DRESS_DARK)
    px(img, 9, 11, DRESS)
    px(img, 10, 11, DRESS)

    # Row 12: dress hem
    px(img, 4, 12, DRESS_DARK)
    px(img, 5, 12, DRESS)
    px(img, 6, 12, DRESS)
    px(img, 7, 12, DRESS)
    px(img, 8, 12, DRESS)
    px(img, 9, 12, DRESS)
    px(img, 10, 12, DRESS)
    px(img, 11, 12, DRESS_DARK)

    # Row 13: legs/feet area (shorter due to hunched)
    px(img, 6, 13, SKIN)
    px(img, 7, 13, SKIN)
    px(img, 8, 13, SKIN)
    px(img, 9, 13, SKIN)

    # Row 14: shoes
    px(img, 5, 14, SHOE_BROWN)
    px(img, 6, 14, SHOE_BROWN)
    px(img, 9, 14, SHOE_BROWN)
    px(img, 10, 14, SHOE_BROWN)

    # Row 15: shoe soles
    px(img, 5, 15, SHOE_BROWN)
    px(img, 6, 15, SHOE_BROWN)
    px(img, 9, 15, SHOE_BROWN)
    px(img, 10, 15, SHOE_BROWN)

    save(img, os.path.join(NPC_DIR, "grandma.png"))


def generate_student_generic():
    """Generic student: White shirt, neutral expression, brown hair."""
    img = make_image()

    SHIRT = (240, 240, 245, 255)
    SHIRT_SHADE = (215, 215, 225, 255)
    HAIR = BROWN_HAIR

    # Row 0: hair top
    px(img, 6, 0, HAIR)
    px(img, 7, 0, HAIR)
    px(img, 8, 0, HAIR)
    px(img, 9, 0, HAIR)

    # Row 1: hair
    px(img, 5, 1, HAIR)
    px(img, 6, 1, HAIR)
    px(img, 7, 1, HAIR)
    px(img, 8, 1, HAIR)
    px(img, 9, 1, HAIR)
    px(img, 10, 1, HAIR)

    # Row 2: hair + forehead
    px(img, 5, 2, HAIR)
    px(img, 6, 2, HAIR)
    px(img, 7, 2, SKIN)
    px(img, 8, 2, SKIN)
    px(img, 9, 2, HAIR)
    px(img, 10, 2, HAIR)

    # Row 3: face
    px(img, 5, 3, HAIR)
    px(img, 6, 3, SKIN)
    px(img, 7, 3, SKIN)
    px(img, 8, 3, SKIN)
    px(img, 9, 3, SKIN)
    px(img, 10, 3, HAIR)

    # Row 4: eyes (neutral)
    px(img, 5, 4, SKIN)
    px(img, 6, 4, EYE_BLACK)
    px(img, 7, 4, SKIN)
    px(img, 8, 4, SKIN)
    px(img, 9, 4, EYE_BLACK)
    px(img, 10, 4, SKIN)

    # Row 5: neutral mouth
    px(img, 6, 5, SKIN)
    px(img, 7, 5, MOUTH)
    px(img, 8, 5, MOUTH)
    px(img, 9, 5, SKIN)

    # Row 6: chin
    px(img, 6, 6, SKIN)
    px(img, 7, 6, SKIN)
    px(img, 8, 6, SKIN)
    px(img, 9, 6, SKIN)

    # Row 7: neck
    px(img, 7, 7, SKIN)
    px(img, 8, 7, SKIN)

    # Row 8: shirt shoulders
    px(img, 4, 8, SHIRT_SHADE)
    px(img, 5, 8, SHIRT)
    px(img, 6, 8, SHIRT)
    px(img, 7, 8, SHIRT)
    px(img, 8, 8, SHIRT)
    px(img, 9, 8, SHIRT)
    px(img, 10, 8, SHIRT)
    px(img, 11, 8, SHIRT_SHADE)

    # Row 9: shirt + arms
    px(img, 4, 9, SKIN)
    px(img, 5, 9, SHIRT)
    px(img, 6, 9, SHIRT)
    px(img, 7, 9, SHIRT)
    px(img, 8, 9, SHIRT)
    px(img, 9, 9, SHIRT)
    px(img, 10, 9, SHIRT)
    px(img, 11, 9, SKIN)

    # Row 10: shirt lower
    px(img, 5, 10, SHIRT)
    px(img, 6, 10, SHIRT)
    px(img, 7, 10, SHIRT)
    px(img, 8, 10, SHIRT)
    px(img, 9, 10, SHIRT)
    px(img, 10, 10, SHIRT)

    # Row 11: pants
    px(img, 5, 11, PANTS_BLUE)
    px(img, 6, 11, PANTS_BLUE)
    px(img, 7, 11, PANTS_BLUE)
    px(img, 8, 11, PANTS_BLUE)
    px(img, 9, 11, PANTS_BLUE)
    px(img, 10, 11, PANTS_BLUE)

    # Row 12: legs
    px(img, 6, 12, PANTS_BLUE)
    px(img, 7, 12, PANTS_BLUE)
    px(img, 8, 12, PANTS_BLUE)
    px(img, 9, 12, PANTS_BLUE)

    # Row 13: legs
    px(img, 6, 13, PANTS_BLUE)
    px(img, 7, 13, PANTS_BLUE)
    px(img, 8, 13, PANTS_BLUE)
    px(img, 9, 13, PANTS_BLUE)

    # Row 14: shoes
    px(img, 5, 14, SHOE_BLACK)
    px(img, 6, 14, SHOE_BLACK)
    px(img, 9, 14, SHOE_BLACK)
    px(img, 10, 14, SHOE_BLACK)

    # Row 15: shoe soles
    px(img, 5, 15, SHOE_BLACK)
    px(img, 6, 15, SHOE_BLACK)
    px(img, 9, 15, SHOE_BLACK)
    px(img, 10, 15, SHOE_BLACK)

    save(img, os.path.join(NPC_DIR, "student_generic.png"))


# =============================================================================
# MAIN
# =============================================================================

def main():
    os.makedirs(ENEMY_DIR, exist_ok=True)
    os.makedirs(NPC_DIR, exist_ok=True)

    print("=== Generating Enemy Sprites ===")
    generate_enemy_fear()
    generate_enemy_sadness()
    generate_enemy_loneliness()

    print("\n=== Generating NPC Sprites ===")
    generate_lewis()
    generate_joan()
    generate_robert()
    generate_mike()
    generate_lucy()
    generate_teacher()
    generate_grandma()
    generate_student_generic()

    print("\n=== All sprites generated successfully! ===")

    # Verification
    print("\n=== Verification ===")
    enemies = ["enemy_fear.png", "enemy_sadness.png", "enemy_loneliness.png"]
    npcs = ["lewis.png", "joan.png", "robert.png", "mike.png",
            "lucy.png", "teacher.png", "grandma.png", "student_generic.png"]

    all_ok = True
    for f in enemies:
        path = os.path.join(ENEMY_DIR, f)
        if os.path.exists(path):
            img = Image.open(path)
            print(f"  [OK] {f} - {img.size[0]}x{img.size[1]} - mode: {img.mode}")
        else:
            print(f"  [FAIL] {f} - NOT FOUND")
            all_ok = False

    for f in npcs:
        path = os.path.join(NPC_DIR, f)
        if os.path.exists(path):
            img = Image.open(path)
            print(f"  [OK] {f} - {img.size[0]}x{img.size[1]} - mode: {img.mode}")
        else:
            print(f"  [FAIL] {f} - NOT FOUND")
            all_ok = False

    if all_ok:
        print("\nAll 11 sprites verified successfully!")
    else:
        print("\nSome sprites failed to generate!")


if __name__ == "__main__":
    main()
