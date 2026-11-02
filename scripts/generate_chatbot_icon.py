#!/usr/bin/env python3
"""
Genereert het TT Clinics AI Robot & Tafeltennisbal icoon in SVG en hoge resolutie PNG.
"""
import os
import subprocess

BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
IMAGES_DIR = os.path.join(BASE_DIR, "images")
SVG_PATH = os.path.join(IMAGES_DIR, "chatbot-icon.svg")
PNG_PATH = os.path.join(IMAGES_DIR, "chatbot-icon.png")
CHROME_BIN = "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"

SVG_CONTENT = '''<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 100 100" width="100%" height="100%">
  <defs>
    <linearGradient id="botHead" x1="0%" y1="0%" x2="100%" y2="100%">
      <stop offset="0%" stop-color="#FFFFFF"/>
      <stop offset="60%" stop-color="#F1F5F9"/>
      <stop offset="100%" stop-color="#CBD5E1"/>
    </linearGradient>

    <linearGradient id="botVisor" x1="0%" y1="0%" x2="0%" y2="100%">
      <stop offset="0%" stop-color="#0B0F19"/>
      <stop offset="100%" stop-color="#1E293B"/>
    </linearGradient>

    <linearGradient id="ttBallGrad" x1="25%" y1="20%" x2="85%" y2="85%">
      <stop offset="0%" stop-color="#FF9E4A"/>
      <stop offset="35%" stop-color="#FF6B00"/>
      <stop offset="100%" stop-color="#D94800"/>
    </linearGradient>

    <linearGradient id="batRubber" x1="0%" y1="0%" x2="100%" y2="100%">
      <stop offset="0%" stop-color="#FF6B00"/>
      <stop offset="100%" stop-color="#C23B00"/>
    </linearGradient>

    <linearGradient id="batWood" x1="0%" y1="0%" x2="100%" y2="0%">
      <stop offset="0%" stop-color="#F59E0B"/>
      <stop offset="100%" stop-color="#D97706"/>
    </linearGradient>

    <linearGradient id="swooshGrad" x1="0%" y1="0%" x2="100%" y2="0%">
      <stop offset="0%" stop-color="#FF6B00" stop-opacity="0"/>
      <stop offset="60%" stop-color="#FF6B00" stop-opacity="0.8"/>
      <stop offset="100%" stop-color="#FF9E4A"/>
    </linearGradient>

    <filter id="glowCyan" x="-30%" y="-30%" width="160%" height="160%">
      <feGaussianBlur stdDeviation="2.5" result="blur" />
      <feMerge>
        <feMergeNode in="blur"/>
        <feMergeNode in="SourceGraphic"/>
      </feMerge>
    </filter>

    <filter id="shadowMain" x="-15%" y="-15%" width="130%" height="135%">
      <feDropShadow dx="0" dy="5" stdDeviation="4" flood-color="#0F172A" flood-opacity="0.22" />
    </filter>
  </defs>

  <g filter="url(#shadowMain)">
    <!-- TT Motion Swooshes rond de bal -->
    <path d="M26 18 C30 9, 44 4, 58 7" fill="none" stroke="url(#swooshGrad)" stroke-width="3" stroke-linecap="round"/>
    <path d="M22 25 C26 17, 36 12, 48 13" fill="none" stroke="url(#swooshGrad)" stroke-width="2" stroke-linecap="round" opacity="0.7"/>

    <!-- Antenne steel -->
    <line x1="50" y1="32" x2="50" y2="19" stroke="#475569" stroke-width="4.5" stroke-linecap="round"/>
    <circle cx="50" cy="30" r="3.5" fill="#64748B"/>

    <!-- Tafeltennisbal bovenop (Antenne tip) -->
    <circle cx="50" cy="14" r="11" fill="url(#ttBallGrad)"/>
    <!-- Glanslicht op bal -->
    <ellipse cx="46.5" cy="10.5" rx="3.5" ry="2.2" transform="rotate(-25 46.5 10.5)" fill="#FFFFFF" opacity="0.85"/>
    <!-- Tafeltennis naad -->
    <path d="M42 16 C46 20, 54 19, 58 13" fill="none" stroke="#FFFFFF" stroke-width="1.2" stroke-linecap="round" opacity="0.5"/>

    <!-- Oorschelpen: Gevormd als echte TT-Batjes aan zijkant van het hoofd -->
    <g transform="translate(13, 50) rotate(-18)">
      <rect x="-4" y="-12" width="8" height="24" rx="4" fill="url(#batRubber)" stroke="#9A2E00" stroke-width="1"/>
      <rect x="-2" y="11" width="4" height="9" rx="1.5" fill="url(#batWood)"/>
      <line x1="-3" y1="0" x2="3" y2="0" stroke="#FFFFFF" stroke-width="1" opacity="0.4"/>
    </g>

    <g transform="translate(87, 50) rotate(18)">
      <rect x="-4" y="-12" width="8" height="24" rx="4" fill="url(#batRubber)" stroke="#9A2E00" stroke-width="1"/>
      <rect x="-2" y="11" width="4" height="9" rx="1.5" fill="url(#batWood)"/>
      <line x1="-3" y1="0" x2="3" y2="0" stroke="#FFFFFF" stroke-width="1" opacity="0.4"/>
    </g>

    <!-- Robot Kop (Afgerond modern chassis) -->
    <rect x="22" y="29" width="56" height="50" rx="16" fill="url(#botHead)" stroke="#94A3B8" stroke-width="2.5"/>

    <!-- Sportieve TT Hoofdband (Oranje streep met witte bies) -->
    <path d="M22 41 L78 41" stroke="#FF6B00" stroke-width="4.5" stroke-linecap="round"/>
    <path d="M24 38 L76 38" stroke="#FFFFFF" stroke-width="1.2" opacity="0.8"/>

    <!-- Donker Digitaal Vizier (Het gezichtsscherm) -->
    <rect x="28" y="46" width="44" height="25" rx="9" fill="url(#botVisor)"/>
    
    <!-- Vizier subtiele reflectieglans -->
    <path d="M31 49 L69 49 C65 52, 58 54, 50 54 L34 54 C32 54, 31 51, 31 49 Z" fill="#FFFFFF" opacity="0.15"/>

    <!-- Vriendelijke Oplichtende LED Ogen (Cyaan / Aqua glow) -->
    <path d="M35 58 C35 54, 43 54, 43 58" fill="none" stroke="#00E5FF" stroke-width="3.2" stroke-linecap="round" filter="url(#glowCyan)"/>
    <circle cx="39" cy="58" r="1.2" fill="#FFFFFF"/>

    <path d="M57 58 C57 54, 65 54, 65 58" fill="none" stroke="#00E5FF" stroke-width="3.2" stroke-linecap="round" filter="url(#glowCyan)"/>
    <circle cx="61" cy="58" r="1.2" fill="#FFFFFF"/>

    <!-- Kleine digitale lach -->
    <path d="M46 65 Q50 68 54 65" fill="none" stroke="#00E5FF" stroke-width="2" stroke-linecap="round" filter="url(#glowCyan)"/>

    <!-- Nek / Kraag -->
    <path d="M42 79 L58 79 L55 86 L45 86 Z" fill="#475569"/>
    
    <!-- TT Logo V-vorm / borstaccent -->
    <path d="M44 87 L50 93 L56 87" fill="none" stroke="#FF6B00" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"/>
  </g>
</svg>'''

def main():
    os.makedirs(IMAGES_DIR, exist_ok=True)
    with open(SVG_PATH, "w", encoding="utf-8") as f:
        f.write(SVG_CONTENT)
    print(f"Generated SVG: {SVG_PATH}")

    if os.path.exists(CHROME_BIN):
        cmd = [
            CHROME_BIN,
            "--headless",
            "--disable-gpu",
            "--default-background-color=00000000",
            "--window-size=256,256",
            f"--screenshot={PNG_PATH}",
            f"file://{SVG_PATH}"
        ]
        res = subprocess.run(cmd, capture_output=True, text=True)
        if os.path.exists(PNG_PATH):
            print(f"Rendered PNG: {PNG_PATH}")

if __name__ == "__main__":
    main()
