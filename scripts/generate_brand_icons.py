#!/usr/bin/env python3
"""
Genereert officiële TT Clinics huisstijl-iconen (PNG met transparantie)
op basis van de website-iconen (Trofee, Hartslag, Locatiepin, Schild, Brein, Swoosh).
"""

import sys
sys.path.insert(0, '/Users/matthias/Library/Python/3.9/lib/python/site-packages')
import os
import math
from PIL import Image, ImageDraw

OUTPUT_DIR = os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))), "images")
os.makedirs(OUTPUT_DIR, exist_ok=True)

SIZE = 512  # Render op 512x512 voor super-scherpe weergave
ORANGE = (255, 107, 0, 255)
ORANGE_DARK = (217, 90, 0, 255)
ORANGE_LIGHT = (255, 154, 77, 255)
WHITE = (255, 255, 255, 255)
WHITE_TRANS = (255, 255, 255, 120)
TRANSPARENT = (0, 0, 0, 0)

def create_badge_base():
    """Maakt de oranje cirkel-badge met zachte glans."""
    img = Image.new("RGBA", (SIZE, SIZE), TRANSPARENT)
    draw = ImageDraw.Draw(img)
    
    # Oranje cirkel
    pad = 32
    draw.ellipse([pad, pad, SIZE - pad, SIZE - pad], fill=ORANGE)
    
    # Specular highlight (bovenkant glans)
    glaze_box = [pad + 60, pad + 20, SIZE - pad - 60, pad + 110]
    draw.ellipse(glaze_box, fill=WHITE_TRANS)
    
    return img

def make_trophy_icon():
    img = create_badge_base()
    draw = ImageDraw.Draw(img)
    
    # Cup lichaam
    c_x, c_y = SIZE // 2, SIZE // 2 - 10
    
    # Beker lichaam (polygoon)
    cup_top_w = 95
    cup_bot_w = 45
    cup_h = 95
    cup_points = [
        (c_x - cup_top_w, c_y - cup_h // 2),
        (c_x + cup_top_w, c_y - cup_h // 2),
        (c_x + cup_bot_w, c_y + cup_h // 2),
        (c_x - cup_bot_w, c_y + cup_h // 2),
    ]
    draw.polygon(cup_points, fill=WHITE)
    
    # Handvat links
    draw.arc([c_x - cup_top_w - 45, c_y - cup_h // 2 + 10, c_x - cup_top_w + 35, c_y + 35], start=90, end=270, fill=WHITE, width=16)
    # Handvat rechts
    draw.arc([c_x + cup_top_w - 35, c_y - cup_h // 2 + 10, c_x + cup_top_w + 45, c_y + 35], start=270, end=90, fill=WHITE, width=16)
    
    # Steel / Voetstuk
    stem_w = 20
    stem_h = 45
    draw.rectangle([c_x - stem_w, c_y + cup_h // 2, c_x + stem_w, c_y + cup_h // 2 + stem_h], fill=WHITE)
    
    # Basis voet
    base_w = 75
    base_h = 24
    draw.rectangle([c_x - base_w, c_y + cup_h // 2 + stem_h, c_x + base_w, c_y + cup_h // 2 + stem_h + base_h], fill=WHITE)
    
    # Sterretje in de beker
    star_box = [c_x - 18, c_y - 20, c_x + 18, c_y + 16]
    draw.ellipse(star_box, fill=ORANGE)
    
    img = img.resize((256, 256), Image.Resampling.LANCZOS)
    path = os.path.join(OUTPUT_DIR, "icon-trophy.png")
    img.save(path)
    print("Gegenereerd:", path)

def make_heartbeat_icon():
    img = create_badge_base()
    draw = ImageDraw.Draw(img)
    
    c_x, c_y = SIZE // 2, SIZE // 2 + 10
    
    # ECG Pulse Wave Line
    points = [
        (c_x - 160, c_y),
        (c_x - 70, c_y),
        (c_x - 35, c_y - 90),
        (c_x + 10, c_y + 105),
        (c_x + 45, c_y - 45),
        (c_x + 75, c_y + 20),
        (c_x + 95, c_y),
        (c_x + 160, c_y),
    ]
    draw.line(points, fill=WHITE, width=22, joint="curve")
    
    img = img.resize((256, 256), Image.Resampling.LANCZOS)
    path = os.path.join(OUTPUT_DIR, "icon-heartbeat.png")
    img.save(path)
    print("Gegenereerd:", path)

def make_location_icon():
    img = create_badge_base()
    draw = ImageDraw.Draw(img)
    
    c_x, c_y = SIZE // 2, SIZE // 2 - 15
    r = 85
    
    # Bovenste cirkel van de pin
    draw.ellipse([c_x - r, c_y - r, c_x + r, c_y + r], fill=WHITE)
    
    # Driehoek punt naar beneden
    pin_point = [
        (c_x - r + 10, c_y + 25),
        (c_x + r - 10, c_y + 25),
        (c_x, c_y + r + 85)
    ]
    draw.polygon(pin_point, fill=WHITE)
    
    # Binnenste cirkel (gat)
    in_r = 38
    draw.ellipse([c_x - in_r, c_y - in_r, c_x + in_r, c_y + in_r], fill=ORANGE)
    
    img = img.resize((256, 256), Image.Resampling.LANCZOS)
    path = os.path.join(OUTPUT_DIR, "icon-location.png")
    img.save(path)
    print("Gegenereerd:", path)

def make_shield_icon():
    img = create_badge_base()
    draw = ImageDraw.Draw(img)
    
    c_x, c_y = SIZE // 2, SIZE // 2 - 5
    
    # Schild vorm
    w, h = 95, 120
    shield_pts = [
        (c_x - w, c_y - h + 30),
        (c_x, c_y - h),
        (c_x + w, c_y - h + 30),
        (c_x + w, c_y + 20),
        (c_x, c_y + h),
        (c_x - w, c_y + 20),
    ]
    draw.polygon(shield_pts, fill=WHITE)
    
    # Vinkje in schild
    check_pts = [
        (c_x - 45, c_y - 5),
        (c_x - 10, c_y + 35),
        (c_x + 50, c_y - 35),
    ]
    draw.line(check_pts, fill=ORANGE, width=18, joint="curve")
    
    img = img.resize((256, 256), Image.Resampling.LANCZOS)
    path = os.path.join(OUTPUT_DIR, "icon-shield.png")
    img.save(path)
    print("Gegenereerd:", path)

def make_chart_icon():
    img = create_badge_base()
    draw = ImageDraw.Draw(img)
    
    c_x, c_y = SIZE // 2, SIZE // 2 + 10
    
    # 3 Staven omhoog
    bar_w = 42
    gap = 22
    
    # Staaf 1
    draw.rectangle([c_x - bar_w * 1.5 - gap, c_y + 10, c_x - bar_w * 0.5 - gap, c_y + 90], fill=WHITE)
    # Staaf 2
    draw.rectangle([c_x - bar_w * 0.5, c_y - 40, c_x + bar_w * 0.5, c_y + 90], fill=WHITE)
    # Staaf 3
    draw.rectangle([c_x + bar_w * 0.5 + gap, c_y - 100, c_x + bar_w * 1.5 + gap, c_y + 90], fill=WHITE)
    
    # Pijl omhoog schuin
    arrow_pts = [
        (c_x - bar_w * 1.5 - gap, c_y - 10),
        (c_x + bar_w * 1.5 + gap + 25, c_y - 125)
    ]
    draw.line(arrow_pts, fill=ORANGE_LIGHT, width=12)
    
    img = img.resize((256, 256), Image.Resampling.LANCZOS)
    path = os.path.join(OUTPUT_DIR, "icon-chart.png")
    img.save(path)
    print("Gegenereerd:", path)

if __name__ == "__main__":
    make_trophy_icon()
    make_heartbeat_icon()
    make_location_icon()
    make_shield_icon()
    make_chart_icon()
    print("Alle huisstijl-iconen succesvol gegenereerd!")
