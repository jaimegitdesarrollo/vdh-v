#!/usr/bin/env python3
"""
SNES-style (16-bit era) pixel art sprite generator.
Generates enemies and NPCs in Final Fantasy VI / Zelda: ALttP style.
All sprites are 16x24 with transparent backgrounds, 1px outlines, 3+ shade coloring.
3/4 top-down perspective.
"""

from PIL import Image
import os

# ─── Palette constants ───
T = (0, 0, 0, 0)  # Transparent
OL = (24, 20, 37, 255)  # Outline color #181425

# Skin tones (SNES RPG standard)
SKIN     = (235, 200, 165, 255)
SKIN_HI  = (250, 225, 195, 255)
SKIN_SH  = (200, 160, 120, 255)
SKIN_DK  = (170, 130, 95, 255)

# White pixel for eyes highlight
WHITE = (255, 255, 255, 255)
BLACK_EYE = (30, 25, 40, 255)


# ─── Helper ───
def make_sprite(w, h, pixel_data):
    """Create an image from a 2D list of RGBA tuples."""
    img = Image.new("RGBA", (w, h), (0, 0, 0, 0))
    for y, row in enumerate(pixel_data):
        for x, color in enumerate(row):
            if color != T:
                img.putpixel((x, y), color)
    return img


def save_sprite(img, path):
    img.save(path)
    print(f"  Saved: {path} ({img.size[0]}x{img.size[1]})")


# ====================================================================
# ENEMY: FEAR — Purple spectral wraith, hooded, wispy tendrils
# ====================================================================
def generate_enemy_fear():
    W, H = 16, 24
    B  = (107, 31, 138, 255)   # base #6B1F8A
    Hi = (139, 63, 170, 255)   # highlight #8B3FAA
    Sh = (74, 15, 106, 255)    # shadow #4A0F6A
    Dk = (62, 8, 80, 255)      # deep shadow #3E0850
    EY = (255, 255, 180, 255)  # glowing eyes
    EG = (255, 255, 120, 255)  # eye glow center

    # Semi-transparent tendril shades
    T1 = (107, 31, 138, 180)
    T2 = (107, 31, 138, 120)
    T3 = (107, 31, 138, 60)
    T4 = (74, 15, 106, 40)
    T5 = (62, 8, 80, 25)

    O = OL
    _ = T

    data = [
        # Row 0: hood peak
        [_,_,_,_,_,_,O,O,O,O,_,_,_,_,_,_],
        # Row 1: hood widens
        [_,_,_,_,O,O,Dk,Sh,Sh,Dk,O,O,_,_,_,_],
        # Row 2: hood body
        [_,_,_,O,Dk,Sh,B,B,B,B,Sh,Dk,O,_,_,_],
        # Row 3: hood sides
        [_,_,O,Dk,Sh,B,Hi,Hi,Hi,Hi,B,Sh,Dk,O,_,_],
        # Row 4: glowing eyes under hood
        [_,_,O,Dk,B,EY,EG,Sh,Sh,EG,EY,B,Dk,O,_,_],
        # Row 5: below eyes, dark void face
        [_,_,O,Dk,Sh,B,Dk,Dk,Dk,Dk,B,Sh,Dk,O,_,_],
        # Row 6: hood bottom edge
        [_,O,Dk,Sh,B,B,Sh,Dk,Dk,Sh,B,B,Sh,Dk,O,_],
        # Row 7: cloak opening
        [_,O,Dk,Sh,B,Hi,B,Sh,Sh,B,Hi,B,Sh,Dk,O,_],
        # Row 8: wide cloak body
        [O,Dk,Sh,B,Hi,Hi,B,B,B,B,Hi,Hi,B,Sh,Dk,O],
        # Row 9: cloak midsection
        [O,Dk,Sh,B,Hi,B,B,Sh,Sh,B,B,Hi,B,Sh,Dk,O],
        # Row 10: cloak with folds
        [O,Dk,B,B,Hi,B,Sh,Dk,Dk,Sh,B,Hi,B,B,Dk,O],
        # Row 11: cloak narrowing
        [O,Sh,B,B,B,Sh,Dk,Dk,Dk,Dk,Sh,B,B,B,Sh,O],
        # Row 12
        [_,O,Sh,B,B,Sh,Dk,Sh,Sh,Dk,Sh,B,B,Sh,O,_],
        # Row 13: lower cloak
        [_,O,Dk,Sh,B,Sh,Dk,Sh,Sh,Dk,Sh,B,Sh,Dk,O,_],
        # Row 14
        [_,O,Dk,Sh,B,Sh,Dk,Dk,Dk,Dk,Sh,B,Sh,Dk,O,_],
        # Row 15: tendrils begin to separate
        [_,_,O,Dk,Sh,B,Sh,Dk,Dk,Sh,B,Sh,Dk,O,_,_],
        # Row 16: tendrils splitting
        [_,_,O,Dk,Sh,B,Sh,_,_,Sh,B,Sh,Dk,O,_,_],
        # Row 17: three tendrils visible
        [_,O,Dk,Sh,B,Sh,_,_,_,_,Sh,B,Sh,Dk,O,_],
        # Row 18: tendrils thinning
        [_,O,T1,Sh,B,_,_,O,O,_,_,B,Sh,T1,O,_],
        # Row 19: fading
        [O,T1,T1,B,_,_,_,T1,T1,_,_,_,B,T1,T1,O],
        # Row 20: more transparent
        [_,T2,T1,_,_,_,_,T2,T2,_,_,_,_,T1,T2,_],
        # Row 21: wisps
        [_,T3,T2,_,_,_,_,_,_,_,_,_,_,T2,T3,_],
        # Row 22: barely visible
        [_,_,T3,_,_,_,_,_,_,_,_,_,_,T3,_,_],
        # Row 23: tips
        [_,_,T4,_,_,_,_,_,_,_,_,_,_,T4,_,_],
    ]
    return make_sprite(W, H, data)


# ====================================================================
# ENEMY: SADNESS — Blue melancholic teardrop spirit
# ====================================================================
def generate_enemy_sadness():
    W, H = 16, 24
    B  = (27, 59, 122, 255)    # base #1B3B7A
    Hi = (43, 91, 170, 255)    # highlight #2B5BAA
    Sh = (15, 37, 80, 255)     # shadow #0F2550
    Dk = (10, 25, 55, 255)     # deep shadow
    EY = (85, 136, 170, 255)   # dim eye #5588AA
    # Drip semi-transparent
    DR = (27, 59, 122, 160)
    D2 = (27, 59, 122, 100)
    D3 = (27, 59, 122, 50)
    D4 = (15, 37, 80, 35)

    O = OL
    _ = T

    data = [
        # Row 0: teardrop tip
        [_,_,_,_,_,_,_,O,O,_,_,_,_,_,_,_],
        # Row 1
        [_,_,_,_,_,_,O,Dk,Dk,O,_,_,_,_,_,_],
        # Row 2: widening teardrop
        [_,_,_,_,_,O,Sh,B,B,Sh,O,_,_,_,_,_],
        # Row 3
        [_,_,_,_,O,Sh,B,Hi,Hi,B,Sh,O,_,_,_,_],
        # Row 4: head widens
        [_,_,_,O,Sh,B,Hi,Hi,Hi,Hi,B,Sh,O,_,_,_],
        # Row 5: single dim eye, hunched
        [_,_,O,Sh,B,Hi,EY,Sh,Sh,B,B,B,Sh,O,_,_],
        # Row 6: drooping, sad expression
        [_,_,O,Sh,B,B,Sh,Dk,Dk,Sh,B,B,Sh,O,_,_],
        # Row 7: hunched body
        [_,O,Dk,Sh,B,B,Sh,Dk,Dk,Sh,B,B,Sh,Dk,O,_],
        # Row 8: body widens, hunched forward
        [_,O,Dk,Sh,B,Hi,B,Sh,Sh,B,Hi,B,Sh,Dk,O,_],
        # Row 9: widest part
        [O,Dk,Sh,B,Hi,Hi,B,B,B,B,Hi,Hi,B,Sh,Dk,O],
        # Row 10
        [O,Dk,Sh,B,Hi,B,B,Sh,Sh,B,B,Hi,B,Sh,Dk,O],
        # Row 11: body curves inward (hunched)
        [O,Dk,Sh,B,B,B,Sh,Dk,Dk,Sh,B,B,B,Sh,Dk,O],
        # Row 12: narrowing
        [O,Dk,Sh,B,B,Sh,Dk,Dk,Dk,Dk,Sh,B,B,Sh,Dk,O],
        # Row 13
        [_,O,Dk,Sh,B,Sh,Dk,Sh,Sh,Dk,Sh,B,Sh,Dk,O,_],
        # Row 14: lower body
        [_,O,Dk,Sh,B,B,Sh,Sh,Sh,Sh,B,B,Sh,Dk,O,_],
        # Row 15: drips starting
        [_,_,O,Dk,Sh,B,Sh,Dk,Dk,Sh,B,Sh,Dk,O,_,_],
        # Row 16: drip separation
        [_,_,O,Dk,Sh,B,Sh,_,_,Sh,B,Sh,Dk,O,_,_],
        # Row 17: drips falling
        [_,_,_,O,DR,B,_,_,_,_,B,DR,O,_,_,_],
        # Row 18: drips thinning
        [_,_,O,DR,DR,_,_,O,O,_,_,DR,DR,O,_,_],
        # Row 19: fading drips
        [_,_,O,D2,_,_,_,DR,DR,_,_,_,D2,O,_,_],
        # Row 20
        [_,_,_,D2,_,_,_,D2,D2,_,_,_,D2,_,_,_],
        # Row 21: very faded
        [_,_,_,D3,_,_,_,_,_,_,_,_,D3,_,_,_],
        # Row 22
        [_,_,_,D4,_,_,_,_,_,_,_,_,D4,_,_,_],
        # Row 23: nearly gone
        [_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_],
    ]
    return make_sprite(W, H, data)


# ====================================================================
# ENEMY: LONELINESS — Gray fading shadow, hugging itself
# ====================================================================
def generate_enemy_loneliness():
    W, H = 16, 24
    B  = (58, 58, 66, 255)     # base #3A3A42
    Hi = (90, 90, 98, 255)     # highlight #5A5A62
    Sh = (42, 42, 48, 255)     # shadow #2A2A30
    Dk = (30, 30, 36, 255)     # deep shadow
    EY = (26, 26, 32, 255)     # hollow eyes #1A1A20

    # Edge fade (semi-transparent for vanishing effect)
    F1 = (58, 58, 66, 200)
    F2 = (58, 58, 66, 140)
    F3 = (58, 58, 66, 80)
    F4 = (42, 42, 48, 50)
    F5 = (42, 42, 48, 30)

    # Semi-transparent outline for ghostly edges
    O  = (24, 20, 37, 200)
    Od = (24, 20, 37, 140)
    Of = (24, 20, 37, 80)

    _ = T

    data = [
        # Row 0: head top
        [_,_,_,_,_,_,O,O,O,O,_,_,_,_,_,_],
        # Row 1: head
        [_,_,_,_,_,O,Dk,Sh,Sh,Dk,O,_,_,_,_,_],
        # Row 2
        [_,_,_,_,O,Sh,B,B,B,B,Sh,O,_,_,_,_],
        # Row 3: head with dim highlight
        [_,_,_,O,Sh,B,Hi,Hi,Hi,Hi,B,Sh,O,_,_,_],
        # Row 4: hollow eye sockets - deeply empty
        [_,_,_,O,Sh,EY,EY,B,B,EY,EY,Sh,O,_,_,_],
        # Row 5: below eyes
        [_,_,_,O,Sh,B,Sh,Dk,Dk,Sh,B,Sh,O,_,_,_],
        # Row 6: thin neck
        [_,_,_,_,O,Sh,B,Sh,Sh,B,Sh,O,_,_,_,_],
        # Row 7: shoulders start, arms wrapping
        [_,_,_,O,Sh,B,Sh,Dk,Dk,Sh,B,Sh,O,_,_,_],
        # Row 8: arms crossing over chest (hugging self)
        [_,_,O,Sh,B,Hi,B,Sh,Sh,B,Hi,B,Sh,O,_,_],
        # Row 9: hugging posture, fading edges
        [_,F2,O,Sh,B,B,Hi,B,B,Hi,B,B,Sh,O,F2,_],
        # Row 10: arms wrapped tight
        [_,F2,O,Sh,B,Hi,B,Sh,Sh,B,Hi,B,Sh,O,F2,_],
        # Row 11
        [_,F3,O,Dk,Sh,B,Sh,Dk,Dk,Sh,B,Sh,Dk,O,F3,_],
        # Row 12: torso
        [_,_,O,Dk,Sh,B,Sh,Dk,Dk,Sh,B,Sh,Dk,O,_,_],
        # Row 13: narrowing
        [_,_,Od,Dk,Sh,B,Sh,Sh,Sh,Sh,B,Sh,Dk,Od,_,_],
        # Row 14
        [_,_,Od,Dk,Sh,B,Sh,Dk,Dk,Sh,B,Sh,Dk,Od,_,_],
        # Row 15: legs, fading
        [_,_,_,Od,Sh,B,Sh,Dk,Dk,Sh,B,Sh,Od,_,_,_],
        # Row 16: legs separating
        [_,_,_,Od,F1,B,Sh,_,_,Sh,B,F1,Od,_,_,_],
        # Row 17
        [_,_,_,Od,F1,F1,_,_,_,_,F1,F1,Od,_,_,_],
        # Row 18: fading legs
        [_,_,_,Of,F2,F1,_,_,_,_,F1,F2,Of,_,_,_],
        # Row 19: dissolving
        [_,_,_,Of,F2,F2,_,_,_,_,F2,F2,Of,_,_,_],
        # Row 20: nearly gone
        [_,_,_,_,F3,F3,_,_,_,_,F3,F3,_,_,_,_],
        # Row 21
        [_,_,_,_,F4,F4,_,_,_,_,F4,F4,_,_,_,_],
        # Row 22: wisps
        [_,_,_,_,F5,_,_,_,_,_,_,F5,_,_,_,_],
        # Row 23: gone
        [_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_],
    ]
    return make_sprite(W, H, data)


# ====================================================================
# NPC: LEWIS — Bully leader, wide/big, spiky dark hair, red shirt
# ====================================================================
def generate_lewis():
    W, H = 16, 24
    O = OL
    _ = T

    # Dark spiky hair
    HR = (42, 26, 16, 255)    # #2A1A10
    HH = (65, 45, 30, 255)    # highlight
    HS = (30, 18, 10, 255)    # shadow

    S  = SKIN; SH = SKIN_HI; SS = SKIN_SH; SD = SKIN_DK
    EW = WHITE; EB = BLACK_EYE

    # Angry eyebrow color
    BW = (42, 26, 16, 255)

    # Red shirt
    RB = (204, 51, 51, 255)   # #CC3333
    RS = (170, 34, 34, 255)   # #AA2222
    RH = (221, 85, 85, 255)   # #DD5555

    # Dark pants
    PB = (50, 45, 60, 255)
    PS = (35, 30, 45, 255)
    PH = (70, 65, 80, 255)

    # Combat boots
    BT = (60, 40, 30, 255)
    BS = (40, 25, 18, 255)
    BH = (85, 60, 45, 255)

    data = [
        # Row 0: spiky hair peaks (wide ~14px)
        [_,O,HR,O,_,O,HR,O,O,HR,O,_,O,HR,O,_],
        # Row 1: spiky hair fills
        [_,O,HR,HR,O,HR,HR,HR,HR,HR,HR,O,HR,HR,O,_],
        # Row 2: hair body
        [_,O,HR,HH,HR,HR,HH,HR,HR,HH,HR,HR,HH,HR,O,_],
        # Row 3: hair + forehead border
        [_,O,HS,HR,HH,HR,HR,HR,HR,HR,HR,HH,HR,HS,O,_],
        # Row 4: angry eyebrows angled down toward center
        [_,O,HR,SS,BW,BW,SH,S,S,SH,BW,BW,SS,HR,O,_],
        # Row 5: eyes — fierce
        [_,O,HR,S,EW,EB,S,SS,SS,S,EB,EW,S,HR,O,_],
        # Row 6: nose, angry mouth
        [_,O,HS,SS,S,SH,SS,SD,SD,SS,SH,S,SS,HS,O,_],
        # Row 7: wide jaw/chin
        [_,_,O,SD,SS,S,S,SD,SD,S,S,SS,SD,O,_,_],
        # Row 8: thick neck, wide shoulders start
        [_,O,RS,O,SS,S,SS,S,S,SS,S,SS,O,RS,O,_],
        # Row 9: squared broad shoulders — 14px wide body
        [O,RS,RB,RB,RB,RB,RH,RH,RH,RH,RB,RB,RB,RB,RS,O],
        # Row 10: torso
        [O,RS,RB,RH,RB,RB,RH,RB,RB,RH,RB,RB,RH,RB,RS,O],
        # Row 11: mid torso
        [O,RS,RB,RH,RB,RB,RB,RS,RS,RB,RB,RB,RH,RB,RS,O],
        # Row 12: lower torso
        [O,RS,RB,RB,RB,RS,RS,RS,RS,RS,RS,RB,RB,RB,RS,O],
        # Row 13: shirt hem
        [O,RS,RB,RB,RS,RB,RS,RB,RB,RS,RB,RS,RB,RB,RS,O],
        # Row 14: belt line
        [_,O,RS,PS,PB,PB,PB,PS,PS,PB,PB,PB,PS,RS,O,_],
        # Row 15: pants
        [_,O,PS,PB,PH,PB,PB,PS,PS,PB,PB,PH,PB,PS,O,_],
        # Row 16
        [_,O,PS,PB,PH,PB,PS,PS,PS,PS,PB,PH,PB,PS,O,_],
        # Row 17: legs begin to separate
        [_,O,PS,PB,PB,PS,O,_,_,O,PS,PB,PB,PS,O,_],
        # Row 18: separated legs
        [_,O,PS,PB,PB,PS,O,_,_,O,PS,PB,PB,PS,O,_],
        # Row 19
        [_,O,PS,PB,PB,PS,O,_,_,O,PS,PB,PB,PS,O,_],
        # Row 20: above boots
        [_,O,PS,PB,PS,PS,O,_,_,O,PS,PS,PB,PS,O,_],
        # Row 21: combat boots
        [O,BS,BT,BT,BH,BT,O,_,_,O,BT,BH,BT,BT,BS,O],
        # Row 22: boot soles — extra wide
        [O,BS,BT,BT,BT,BT,BS,O,O,BS,BT,BT,BT,BT,BS,O],
        # Row 23: boot bottom outline
        [_,O,O,O,O,O,O,_,_,O,O,O,O,O,O,_],
    ]
    return make_sprite(W, H, data)


# ====================================================================
# NPC: JOAN — Bully, green shirt, blue cap with brim, smirk
# ====================================================================
def generate_joan():
    W, H = 16, 24
    O = OL
    _ = T

    HR = (70, 50, 35, 255)    # hair peeking under cap
    HS = (50, 35, 22, 255)

    S  = SKIN; SH = SKIN_HI; SS = SKIN_SH; SD = SKIN_DK
    EW = WHITE; EB = BLACK_EYE

    # Blue cap #2244AA
    CB = (34, 68, 170, 255)
    CS = (24, 48, 130, 255)
    CH = (55, 90, 190, 255)

    # Green shirt #339933
    GB = (51, 153, 51, 255)
    GS = (34, 119, 34, 255)
    GH = (68, 187, 68, 255)

    PB = (80, 80, 120, 255)
    PS = (60, 60, 95, 255)
    PH = (100, 100, 140, 255)

    BT = (70, 50, 40, 255)
    BS = (50, 35, 25, 255)

    data = [
        # Row 0: cap crown top
        [_,_,_,_,_,O,O,O,O,O,O,_,_,_,_,_],
        # Row 1: cap crown
        [_,_,_,_,O,CS,CB,CH,CH,CB,CS,O,_,_,_,_],
        # Row 2: cap body
        [_,_,_,O,CS,CB,CH,CB,CB,CH,CB,CS,O,_,_,_],
        # Row 3: brim extends forward, casting shadow
        [_,O,O,CS,CS,CS,CS,CS,CS,CS,CS,CS,CS,O,O,_],
        # Row 4: face in brim shadow + eyes (shadow = darker skin)
        [_,_,O,SD,SS,EW,EB,SD,SD,EB,EW,SS,SD,O,_,_],
        # Row 5: face, nose
        [_,_,O,HR,SS,S,SH,SS,SS,SH,S,SS,HR,O,_,_],
        # Row 6: smirk — asymmetric mouth (left up, right down)
        [_,_,O,HS,SS,S,SD,SS,S,S,S,SS,HS,O,_,_],
        # Row 7: chin
        [_,_,_,O,O,SS,S,S,S,S,SS,O,O,_,_,_],
        # Row 8: neck + collar
        [_,_,_,O,GS,O,SS,S,SS,O,GS,O,_,_,_,_],
        # Row 9: shirt shoulders (~12px)
        [_,_,O,GS,GB,GB,GB,GH,GH,GB,GB,GB,GS,O,_,_],
        # Row 10: torso
        [_,O,GS,GB,GH,GB,GB,GB,GB,GB,GB,GH,GB,GS,O,_],
        # Row 11
        [_,O,GS,GB,GH,GB,GB,GS,GS,GB,GB,GH,GB,GS,O,_],
        # Row 12
        [_,O,GS,GB,GB,GS,GS,GS,GS,GS,GS,GB,GB,GS,O,_],
        # Row 13: shirt bottom
        [_,O,GS,GB,GB,GS,GB,GS,GS,GB,GS,GB,GB,GS,O,_],
        # Row 14: belt
        [_,_,O,GS,PS,PB,PB,PB,PB,PB,PB,PS,GS,O,_,_],
        # Row 15: pants
        [_,_,O,PS,PB,PH,PB,PS,PS,PB,PH,PB,PS,O,_,_],
        # Row 16
        [_,_,O,PS,PB,PB,PB,PS,PS,PB,PB,PB,PS,O,_,_],
        # Row 17: legs separate
        [_,_,O,PS,PB,PB,PS,_,_,PS,PB,PB,PS,O,_,_],
        # Row 18
        [_,_,O,PS,PB,PS,O,_,_,O,PS,PB,PS,O,_,_],
        # Row 19
        [_,_,O,PS,PB,PS,O,_,_,O,PS,PB,PS,O,_,_],
        # Row 20
        [_,_,O,PS,PB,PS,O,_,_,O,PS,PB,PS,O,_,_],
        # Row 21: shoes
        [_,_,O,BS,BT,BT,O,_,_,O,BT,BT,BS,O,_,_],
        # Row 22: soles
        [_,_,O,BS,BT,BT,BS,O,O,BS,BT,BT,BS,O,_,_],
        # Row 23: bottom
        [_,_,_,O,O,O,O,_,_,O,O,O,O,_,_,_],
    ]
    return make_sprite(W, H, data)


# ====================================================================
# NPC: ROBERT — Bully, orange shirt, stocky/barrel-chested
# ====================================================================
def generate_robert():
    W, H = 16, 24
    O = OL
    _ = T

    HR = (90, 65, 40, 255)    # short brown hair
    HH = (115, 85, 55, 255)
    HS = (65, 45, 28, 255)

    S  = SKIN; SH = SKIN_HI; SS = SKIN_SH; SD = SKIN_DK
    EW = WHITE; EB = BLACK_EYE

    # Orange shirt #CC7733
    OB = (204, 119, 51, 255)
    OS = (170, 85, 34, 255)
    OH = (221, 170, 85, 255)

    PB = (70, 65, 55, 255)
    PS = (50, 45, 38, 255)
    PH = (90, 85, 75, 255)

    BT = (60, 45, 35, 255)
    BS = (42, 30, 22, 255)

    data = [
        # Row 0: short hair, wide head (~12px)
        [_,_,_,O,O,O,O,O,O,O,O,O,O,_,_,_],
        # Row 1: cropped hair
        [_,_,O,HR,HS,HR,HH,HR,HR,HH,HR,HS,HR,O,_,_],
        # Row 2: hair lower
        [_,_,O,HR,HR,HH,HR,HR,HR,HR,HH,HR,HR,O,_,_],
        # Row 3: forehead
        [_,_,O,HS,S,SH,SH,SH,SH,SH,SH,S,HS,O,_,_],
        # Row 4: eyes
        [_,_,O,SS,EW,EB,SH,S,S,SH,EB,EW,SS,O,_,_],
        # Row 5: nose
        [_,_,O,S,S,SH,S,SS,SS,S,SH,S,S,O,_,_],
        # Row 6: mouth — neutral/mean
        [_,_,O,SS,S,S,SD,SD,SD,SD,S,S,SS,O,_,_],
        # Row 7: wide chin, thick neck starts
        [_,_,O,SD,SS,S,S,SS,SS,S,S,SS,SD,O,_,_],
        # Row 8: VERY thick neck + wide shoulders
        [_,O,OS,O,SS,S,S,SS,SS,S,S,SS,O,OS,O,_],
        # Row 9: barrel-chested — full 14px wide
        [O,OS,OB,OB,OB,OH,OB,OB,OB,OB,OH,OB,OB,OB,OS,O],
        # Row 10: wide torso
        [O,OS,OB,OH,OB,OB,OH,OB,OB,OH,OB,OB,OH,OB,OS,O],
        # Row 11
        [O,OS,OB,OH,OB,OB,OB,OS,OS,OB,OB,OB,OH,OB,OS,O],
        # Row 12: barrel
        [O,OS,OB,OB,OB,OS,OS,OS,OS,OS,OS,OB,OB,OB,OS,O],
        # Row 13
        [O,OS,OB,OB,OS,OB,OS,OB,OB,OS,OB,OS,OB,OB,OS,O],
        # Row 14: belt
        [_,O,OS,PS,PB,PB,PB,PS,PS,PB,PB,PB,PS,OS,O,_],
        # Row 15: wide pants
        [_,O,PS,PB,PH,PB,PB,PS,PS,PB,PB,PH,PB,PS,O,_],
        # Row 16
        [_,O,PS,PB,PH,PB,PS,PS,PS,PS,PB,PH,PB,PS,O,_],
        # Row 17: legs separate
        [_,O,PS,PB,PB,PS,O,_,_,O,PS,PB,PB,PS,O,_],
        # Row 18
        [_,O,PS,PB,PB,PS,O,_,_,O,PS,PB,PB,PS,O,_],
        # Row 19
        [_,O,PS,PB,PB,PS,O,_,_,O,PS,PB,PB,PS,O,_],
        # Row 20: above shoes
        [_,O,PS,PB,PS,PS,O,_,_,O,PS,PS,PB,PS,O,_],
        # Row 21: shoes
        [O,BS,BT,BT,BT,BT,O,_,_,O,BT,BT,BT,BT,BS,O],
        # Row 22: soles
        [O,BS,BT,BT,BT,BT,BS,O,O,BS,BT,BT,BT,BT,BS,O],
        # Row 23
        [_,O,O,O,O,O,O,_,_,O,O,O,O,O,O,_],
    ]
    return make_sprite(W, H, data)


# ====================================================================
# NPC: MIKE — Bully, yellow shirt, tall thin lanky (~10px body)
# ====================================================================
def generate_mike():
    W, H = 16, 24
    O = OL
    _ = T

    HR = (80, 60, 40, 255)    # brown hair
    HH = (105, 80, 55, 255)
    HS = (55, 40, 25, 255)

    S  = SKIN; SH = SKIN_HI; SS = SKIN_SH; SD = SKIN_DK
    EW = WHITE; EB = BLACK_EYE

    # Yellow shirt #CCCC33
    YB = (204, 204, 51, 255)
    YS = (170, 170, 34, 255)
    YH = (221, 221, 85, 255)

    PB = (65, 65, 90, 255)
    PS = (45, 45, 65, 255)
    PH = (85, 85, 110, 255)

    BT = (55, 45, 35, 255)
    BS = (38, 30, 22, 255)

    data = [
        # Row 0: narrow head top (long face)
        [_,_,_,_,_,O,O,O,O,O,O,_,_,_,_,_],
        # Row 1: hair
        [_,_,_,_,O,HR,HH,HR,HR,HH,HR,O,_,_,_,_],
        # Row 2: tall forehead (long face)
        [_,_,_,_,O,HS,HR,HH,HH,HR,HS,O,_,_,_,_],
        # Row 3: forehead skin
        [_,_,_,_,O,HR,S,SH,SH,S,HR,O,_,_,_,_],
        # Row 4: eyes — long face, narrow
        [_,_,_,_,O,EW,EB,SH,SH,EB,EW,O,_,_,_,_],
        # Row 5: long nose
        [_,_,_,_,O,S,SH,SS,SS,SH,S,O,_,_,_,_],
        # Row 6: mouth
        [_,_,_,_,O,SS,S,SD,SD,S,SS,O,_,_,_,_],
        # Row 7: long chin
        [_,_,_,_,_,O,SS,S,S,SS,O,_,_,_,_,_],
        # Row 8: thin neck
        [_,_,_,_,O,YS,O,SS,SS,O,YS,O,_,_,_,_],
        # Row 9: narrow shoulders (~10px body)
        [_,_,_,O,YS,YB,YB,YH,YH,YB,YB,YS,O,_,_,_],
        # Row 10: thin torso
        [_,_,_,O,YS,YB,YH,YB,YB,YH,YB,YS,O,_,_,_],
        # Row 11
        [_,_,_,O,YS,YB,YH,YS,YS,YH,YB,YS,O,_,_,_],
        # Row 12
        [_,_,_,O,YS,YB,YB,YS,YS,YB,YB,YS,O,_,_,_],
        # Row 13: shirt bottom
        [_,_,_,O,YS,YB,YS,YB,YB,YS,YB,YS,O,_,_,_],
        # Row 14: belt — thin
        [_,_,_,_,O,YS,PS,PB,PB,PS,YS,O,_,_,_,_],
        # Row 15: thin pants, long legs
        [_,_,_,_,O,PS,PB,PH,PH,PB,PS,O,_,_,_,_],
        # Row 16
        [_,_,_,_,O,PS,PB,PB,PB,PB,PS,O,_,_,_,_],
        # Row 17: lanky legs
        [_,_,_,_,O,PS,PB,PS,PS,PB,PS,O,_,_,_,_],
        # Row 18: legs separate
        [_,_,_,_,O,PS,PB,_,_,PB,PS,O,_,_,_,_],
        # Row 19: long legs continue
        [_,_,_,_,O,PS,PB,_,_,PB,PS,O,_,_,_,_],
        # Row 20
        [_,_,_,_,O,PS,PS,_,_,PS,PS,O,_,_,_,_],
        # Row 21: shoes
        [_,_,_,O,BS,BT,BT,_,_,BT,BT,BS,O,_,_,_],
        # Row 22
        [_,_,_,O,BS,BT,BT,O,O,BT,BT,BS,O,_,_,_],
        # Row 23
        [_,_,_,_,O,O,O,_,_,O,O,O,_,_,_,_],
    ]
    return make_sprite(W, H, data)


# ====================================================================
# NPC: LUCY — Kind classmate, pink top, long brown hair, plaid skirt
# ====================================================================
def generate_lucy():
    W, H = 16, 24
    O = OL
    _ = T

    # Long brown hair #6B4226 with highlights
    HR = (107, 66, 38, 255)
    HH = (140, 95, 60, 255)
    HS = (80, 48, 28, 255)

    S  = SKIN; SH = SKIN_HI; SS = SKIN_SH; SD = SKIN_DK
    # Kind green-brown eyes
    EG = (90, 130, 80, 255)
    EW = WHITE

    # Pink top #DD88AA
    PK  = (221, 136, 170, 255)
    PKS = (187, 102, 136, 255)
    PKH = (255, 170, 204, 255)

    # Plaid skirt #8866AA
    SK  = (136, 102, 170, 255)
    SKS = (110, 80, 140, 255)
    SKH = (160, 125, 195, 255)
    SKP = (145, 110, 165, 255)  # plaid stripe accent

    BT = (90, 60, 45, 255)
    BS = (65, 42, 30, 255)

    data = [
        # Row 0: hair top
        [_,_,_,_,_,O,O,O,O,O,O,_,_,_,_,_],
        # Row 1: hair crown
        [_,_,_,_,O,HR,HH,HR,HR,HH,HR,O,_,_,_,_],
        # Row 2: hair sides begin draping
        [_,_,_,O,HR,HH,HR,HH,HH,HR,HH,HR,O,_,_,_],
        # Row 3: hair frames face
        [_,_,O,HR,HS,S,SH,SH,SH,SH,S,HS,HR,O,_,_],
        # Row 4: kind eyes (green-brown)
        [_,_,O,HR,S,EW,EG,SH,SH,EG,EW,S,HR,O,_,_],
        # Row 5: gentle expression
        [_,_,O,HR,SS,S,SH,S,S,SH,S,SS,HR,O,_,_],
        # Row 6: small warm smile
        [_,_,O,HR,SS,S,S,SS,SS,S,S,SS,HR,O,_,_],
        # Row 7: chin, hair drapes past
        [_,_,O,HR,O,SS,S,S,S,S,SS,O,HR,O,_,_],
        # Row 8: neck, hair on shoulders
        [_,_,O,HR,PKS,O,SS,S,SS,O,PKS,HR,O,_,_],
        # Row 9: pink top + long hair framing
        [_,O,HR,PKS,PK,PK,PKH,PKH,PKH,PKH,PK,PK,PKS,HR,O,_],
        # Row 10: shirt body
        [_,O,HR,PKS,PK,PKH,PK,PK,PK,PK,PKH,PK,PKS,HR,O,_],
        # Row 11: hair ends around here
        [_,O,HS,PKS,PK,PKH,PK,PKS,PKS,PK,PKH,PK,PKS,HS,O,_],
        # Row 12: below hair
        [_,_,O,PKS,PK,PK,PKS,PKS,PKS,PKS,PK,PK,PKS,O,_,_],
        # Row 13: shirt hem
        [_,_,O,PKS,PK,PKS,PK,PKS,PKS,PK,PKS,PK,PKS,O,_,_],
        # Row 14: plaid skirt top
        [_,_,O,SKS,SK,SKH,SK,SK,SK,SK,SKH,SK,SKS,O,_,_],
        # Row 15: plaid pattern
        [_,_,O,SKS,SK,SKP,SKH,SK,SK,SKH,SKP,SK,SKS,O,_,_],
        # Row 16: skirt widens slightly
        [_,O,SKS,SK,SKH,SK,SKP,SK,SK,SKP,SK,SKH,SK,SKS,O,_],
        # Row 17: skirt
        [_,O,SKS,SK,SK,SKP,SK,SKH,SKH,SK,SKP,SK,SK,SKS,O,_],
        # Row 18: skirt hem
        [_,_,O,SKS,SKS,SKS,SKS,SKS,SKS,SKS,SKS,SKS,SKS,O,_,_],
        # Row 19: legs below skirt
        [_,_,_,O,O,SS,S,O,O,S,SS,O,O,_,_,_],
        # Row 20: calves
        [_,_,_,_,O,SS,SS,_,_,SS,SS,O,_,_,_,_],
        # Row 21: shoes
        [_,_,_,O,BS,BT,BT,_,_,BT,BT,BS,O,_,_,_],
        # Row 22: soles
        [_,_,_,O,BS,BT,BT,O,O,BT,BT,BS,O,_,_,_],
        # Row 23: bottom
        [_,_,_,_,O,O,O,_,_,O,O,O,_,_,_,_],
    ]
    return make_sprite(W, H, data)


# ====================================================================
# NPC: TEACHER — Don Peter, white shirt, red tie, glasses, gray hair
# ====================================================================
def generate_teacher():
    W, H = 16, 24
    O = OL
    _ = T

    # Gray hair #808080
    HR = (128, 128, 128, 255)
    HH = (160, 160, 160, 255)
    HS = (95, 95, 95, 255)

    S  = SKIN; SH = SKIN_HI; SS = SKIN_SH; SD = SKIN_DK
    EB = BLACK_EYE

    # Glasses: light blue lenses #88BBDD, 2px each
    GL = (136, 187, 221, 255)
    GF = (120, 120, 130, 255)  # frame

    # White shirt #E8E8E8
    WB = (232, 232, 232, 255)
    WS = (200, 200, 200, 255)
    WH = (245, 245, 245, 255)

    # Red tie
    TB = (180, 40, 40, 255)
    TS = (140, 30, 30, 255)
    TH = (210, 65, 65, 255)

    # Gray pants
    PB = (110, 110, 115, 255)
    PS = (85, 85, 90, 255)
    PH = (135, 135, 140, 255)

    BT = (50, 40, 35, 255)
    BS = (35, 28, 22, 255)

    data = [
        # Row 0: hair top
        [_,_,_,_,_,O,O,O,O,O,O,_,_,_,_,_],
        # Row 1: gray hair
        [_,_,_,_,O,HR,HH,HR,HR,HH,HR,O,_,_,_,_],
        # Row 2: hair sides
        [_,_,_,O,HR,HS,HR,HH,HH,HR,HS,HR,O,_,_,_],
        # Row 3: forehead
        [_,_,_,O,HR,S,SH,SH,SH,SH,S,HR,O,_,_,_],
        # Row 4: glasses — 2px lens each eye, frame connects
        [_,_,_,O,GF,GL,GL,GF,GF,GL,GL,GF,O,_,_,_],
        # Row 5: eyes behind/below glasses
        [_,_,_,O,S,EB,SH,S,S,SH,EB,S,O,_,_,_],
        # Row 6: nose, formal expression
        [_,_,_,O,SS,S,SH,SS,SS,SH,S,SS,O,_,_,_],
        # Row 7: chin
        [_,_,_,_,O,SS,S,S,S,S,SS,O,_,_,_,_],
        # Row 8: collar + tie top
        [_,_,O,WS,WB,O,SS,S,SS,O,WB,WS,O,_,_,_],
        # Row 9: white shirt + red tie, formal shoulders
        [_,O,WS,WB,WB,WB,WB,TB,WB,WB,WB,WB,WB,WS,O,_],
        # Row 10: shirt with tie stripe
        [_,O,WS,WB,WH,WB,WB,TB,WB,WB,WH,WB,WB,WS,O,_],
        # Row 11: tie narrows
        [_,O,WS,WB,WH,WB,WS,TS,WS,WB,WH,WB,WB,WS,O,_],
        # Row 12: tie continues
        [_,O,WS,WB,WB,WS,WS,TB,WS,WS,WB,WB,WB,WS,O,_],
        # Row 13: tie point
        [_,O,WS,WB,WB,WS,WS,TH,WS,WS,WB,WB,WB,WS,O,_],
        # Row 14: belt / waist with tie end
        [_,_,O,WS,PS,PB,PB,TS,PB,PB,PB,PS,WS,O,_,_],
        # Row 15: gray pants
        [_,_,O,PS,PB,PH,PB,PS,PS,PB,PH,PB,PS,O,_,_],
        # Row 16
        [_,_,O,PS,PB,PB,PB,PS,PS,PB,PB,PB,PS,O,_,_],
        # Row 17: legs separate
        [_,_,O,PS,PB,PB,PS,_,_,PS,PB,PB,PS,O,_,_],
        # Row 18
        [_,_,O,PS,PB,PS,O,_,_,O,PS,PB,PS,O,_,_],
        # Row 19
        [_,_,O,PS,PB,PS,O,_,_,O,PS,PB,PS,O,_,_],
        # Row 20
        [_,_,O,PS,PS,PS,O,_,_,O,PS,PS,PS,O,_,_],
        # Row 21: shoes
        [_,_,O,BS,BT,BT,O,_,_,O,BT,BT,BS,O,_,_],
        # Row 22: soles
        [_,_,O,BS,BT,BT,BS,O,O,BS,BT,BT,BS,O,_,_],
        # Row 23
        [_,_,_,O,O,O,O,_,_,O,O,O,O,_,_,_],
    ]
    return make_sprite(W, H, data)


# ====================================================================
# NPC: GRANDMA — Abuela, white-gray bun, brown shawl, warm
# ====================================================================
def generate_grandma():
    W, H = 16, 24
    O = OL
    _ = T

    # White-gray hair #C0C0C0
    HR = (192, 192, 192, 255)
    HH = (215, 215, 215, 255)
    HS = (155, 155, 155, 255)

    S  = SKIN; SH = SKIN_HI; SS = SKIN_SH; SD = SKIN_DK
    EB = BLACK_EYE

    # Brown shawl #AA7744
    SB = (170, 119, 68, 255)
    SS2 = (136, 102, 51, 255)  # shawl shadow #886633
    SHH = (204, 153, 102, 255) # shawl highlight #CC9966

    # Brown dress
    DB = (140, 95, 60, 255)
    DS = (110, 72, 42, 255)
    DH = (170, 120, 80, 255)

    BT = (80, 55, 40, 255)
    BS = (55, 38, 25, 255)

    data = [
        # Row 0: bun on top of head
        [_,_,_,_,_,_,O,O,O,_,_,_,_,_,_,_],
        # Row 1: bun body
        [_,_,_,_,_,O,HR,HH,HR,O,_,_,_,_,_,_],
        # Row 2: bun connects to head
        [_,_,_,_,O,HR,HS,HR,HS,HR,O,_,_,_,_,_],
        # Row 3: hair frames face
        [_,_,_,O,HR,HH,HR,HR,HR,HR,HH,HR,O,_,_,_],
        # Row 4: small kind eyes
        [_,_,_,O,HR,S,EB,SH,SH,EB,S,HR,O,_,_,_],
        # Row 5: smile wrinkles
        [_,_,_,O,HR,SS,SH,S,S,SH,SS,HR,O,_,_,_],
        # Row 6: warm smile
        [_,_,_,O,HS,SS,S,SS,SS,S,SS,HS,O,_,_,_],
        # Row 7: chin — slightly hunched forward
        [_,_,_,_,O,SD,SS,S,S,SS,SD,O,_,_,_,_],
        # Row 8: shawl wraps — hunched posture shifts forward
        [_,_,O,SS2,SB,O,SS,SD,SD,O,SB,SS2,O,_,_,_],
        # Row 9: shawl drapes
        [_,O,SS2,SB,SHH,SB,SB,SB,SB,SB,SHH,SB,SS2,O,_,_],
        # Row 10: shawl with folds
        [_,O,SS2,SB,SHH,SB,SB,SS2,SS2,SB,SHH,SB,SS2,O,_,_],
        # Row 11: shawl lower
        [_,O,SS2,SB,SB,SS2,SS2,SS2,SS2,SS2,SB,SB,SS2,O,_,_],
        # Row 12: dress visible below shawl
        [_,_,O,SS2,DS,DB,DH,DB,DB,DH,DB,DS,SS2,O,_,_],
        # Row 13: dress body
        [_,_,O,DS,DB,DH,DB,DB,DB,DB,DH,DB,DS,O,_,_],
        # Row 14
        [_,_,O,DS,DB,DH,DB,DS,DS,DB,DH,DB,DS,O,_,_],
        # Row 15: dress
        [_,_,O,DS,DB,DB,DB,DS,DS,DB,DB,DB,DS,O,_,_],
        # Row 16: dress widens
        [_,O,DS,DB,DB,DH,DB,DS,DS,DB,DH,DB,DB,DS,O,_],
        # Row 17
        [_,O,DS,DB,DH,DB,DB,DB,DB,DB,DB,DH,DB,DS,O,_],
        # Row 18: dress hem
        [_,O,DS,DB,DB,DB,DS,DS,DS,DS,DB,DB,DB,DS,O,_],
        # Row 19: hem line
        [_,_,O,DS,DS,DS,DS,DS,DS,DS,DS,DS,DS,O,_,_],
        # Row 20: feet peek
        [_,_,_,O,O,SS,S,O,O,S,SS,O,O,_,_,_],
        # Row 21: shoes
        [_,_,_,O,BS,BT,BT,_,_,BT,BT,BS,O,_,_,_],
        # Row 22
        [_,_,_,O,BS,BT,BT,O,O,BT,BT,BS,O,_,_,_],
        # Row 23
        [_,_,_,_,O,O,O,_,_,O,O,O,_,_,_,_],
    ]
    return make_sprite(W, H, data)


# ====================================================================
# NPC: STUDENT_GENERIC — White shirt, brown hair, blue pants
# ====================================================================
def generate_student_generic():
    W, H = 16, 24
    O = OL
    _ = T

    HR = (100, 75, 50, 255)   # brown hair
    HH = (130, 100, 70, 255)
    HS = (70, 50, 32, 255)

    S  = SKIN; SH = SKIN_HI; SS = SKIN_SH; SD = SKIN_DK
    EW = WHITE; EB = BLACK_EYE

    # White shirt
    WB = (235, 235, 235, 255)
    WS = (205, 205, 205, 255)
    WH = (248, 248, 248, 255)

    # Blue pants
    PB = (60, 70, 140, 255)
    PS = (42, 50, 105, 255)
    PH = (80, 90, 165, 255)

    BT = (65, 50, 38, 255)
    BS = (45, 32, 22, 255)

    data = [
        # Row 0: hair top
        [_,_,_,_,_,O,O,O,O,O,O,_,_,_,_,_],
        # Row 1: brown hair
        [_,_,_,_,O,HR,HH,HR,HR,HH,HR,O,_,_,_,_],
        # Row 2: hair lower
        [_,_,_,O,HR,HS,HR,HH,HH,HR,HS,HR,O,_,_,_],
        # Row 3: forehead
        [_,_,_,O,HR,S,SH,SH,SH,SH,S,HR,O,_,_,_],
        # Row 4: eyes — neutral
        [_,_,_,O,SS,EW,EB,SH,SH,EB,EW,SS,O,_,_,_],
        # Row 5: nose
        [_,_,_,O,S,S,SH,SS,SS,SH,S,S,O,_,_,_],
        # Row 6: neutral mouth
        [_,_,_,O,SS,S,S,SD,SD,S,S,SS,O,_,_,_],
        # Row 7: chin
        [_,_,_,_,O,SS,S,S,S,S,SS,O,_,_,_,_],
        # Row 8: collar
        [_,_,_,O,WS,O,SS,S,SS,O,WS,O,_,_,_,_],
        # Row 9: white shirt shoulders
        [_,_,O,WS,WB,WB,WB,WH,WH,WB,WB,WB,WS,O,_,_],
        # Row 10: torso
        [_,O,WS,WB,WH,WB,WB,WB,WB,WB,WB,WH,WB,WS,O,_],
        # Row 11
        [_,O,WS,WB,WH,WB,WB,WS,WS,WB,WB,WH,WB,WS,O,_],
        # Row 12
        [_,O,WS,WB,WB,WS,WS,WS,WS,WS,WS,WB,WB,WS,O,_],
        # Row 13: shirt bottom
        [_,O,WS,WB,WB,WS,WB,WS,WS,WB,WS,WB,WB,WS,O,_],
        # Row 14: belt
        [_,_,O,WS,PS,PB,PB,PB,PB,PB,PB,PS,WS,O,_,_],
        # Row 15: blue pants
        [_,_,O,PS,PB,PH,PB,PS,PS,PB,PH,PB,PS,O,_,_],
        # Row 16
        [_,_,O,PS,PB,PB,PB,PS,PS,PB,PB,PB,PS,O,_,_],
        # Row 17: legs separate
        [_,_,O,PS,PB,PB,PS,_,_,PS,PB,PB,PS,O,_,_],
        # Row 18
        [_,_,O,PS,PB,PS,O,_,_,O,PS,PB,PS,O,_,_],
        # Row 19
        [_,_,O,PS,PB,PS,O,_,_,O,PS,PB,PS,O,_,_],
        # Row 20
        [_,_,O,PS,PS,PS,O,_,_,O,PS,PS,PS,O,_,_],
        # Row 21: shoes
        [_,_,O,BS,BT,BT,O,_,_,O,BT,BT,BS,O,_,_],
        # Row 22: soles
        [_,_,O,BS,BT,BT,BS,O,O,BS,BT,BT,BS,O,_,_],
        # Row 23
        [_,_,_,O,O,O,O,_,_,O,O,O,O,_,_,_],
    ]
    return make_sprite(W, H, data)


# ====================================================================
# MAIN
# ====================================================================
def main():
    enemy_dir = "/Users/macbook/Flat101/godtest/vdh-godot/assets/sprites/enemies/"
    npc_dir   = "/Users/macbook/Flat101/godtest/vdh-godot/assets/sprites/npcs/"

    os.makedirs(enemy_dir, exist_ok=True)
    os.makedirs(npc_dir, exist_ok=True)

    print("Generating SNES-style 16x24 pixel art sprites...")
    print("Style: FF6 / Zelda ALttP — 3/4 view, 1px outline, 3+ shade coloring")
    print()

    # === ENEMIES ===
    print("=== ENEMIES (Ghostly Emotion Entities) ===")
    img = generate_enemy_fear()
    save_sprite(img, os.path.join(enemy_dir, "enemy_fear.png"))

    img = generate_enemy_sadness()
    save_sprite(img, os.path.join(enemy_dir, "enemy_sadness.png"))

    img = generate_enemy_loneliness()
    save_sprite(img, os.path.join(enemy_dir, "enemy_loneliness.png"))

    # === NPCs ===
    print()
    print("=== NPCs (SNES RPG Characters) ===")
    img = generate_lewis()
    save_sprite(img, os.path.join(npc_dir, "lewis.png"))

    img = generate_joan()
    save_sprite(img, os.path.join(npc_dir, "joan.png"))

    img = generate_robert()
    save_sprite(img, os.path.join(npc_dir, "robert.png"))

    img = generate_mike()
    save_sprite(img, os.path.join(npc_dir, "mike.png"))

    img = generate_lucy()
    save_sprite(img, os.path.join(npc_dir, "lucy.png"))

    img = generate_teacher()
    save_sprite(img, os.path.join(npc_dir, "teacher.png"))

    img = generate_grandma()
    save_sprite(img, os.path.join(npc_dir, "grandma.png"))

    img = generate_student_generic()
    save_sprite(img, os.path.join(npc_dir, "student_generic.png"))

    print()
    print("=" * 50)
    print("All 11 sprites generated successfully!")
    print("  3 enemies in:", enemy_dir)
    print("  8 NPCs in:   ", npc_dir)


if __name__ == "__main__":
    main()
