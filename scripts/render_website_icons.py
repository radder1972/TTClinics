#!/usr/bin/env python3
"""
Renders the EXACT website icons (matching index.html SVG paths and gradient circles)
to high-resolution PNG files using headless Google Chrome.
"""
import os
import subprocess

BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
IMAGES_DIR = os.path.join(BASE_DIR, "images")
os.makedirs(IMAGES_DIR, exist_ok=True)

CHROME_BIN = "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"

# SVG icons exactly as in index.html
ICONS = {
    "icon-trophy": """
    <svg viewBox="0 0 24 24" fill="none" stroke="white" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round">
        <path d="M6 9H4.5a2.5 2.5 0 0 1 0-5H6"/>
        <path d="M18 9h1.5a2.5 2.5 0 0 0 0-5H18"/>
        <path d="M4 22h16"/>
        <path d="M10 14.66V17c0 .55-.45 1-1 1H7v4h10v-4h-2c-.55 0-1-.45-1-1v-2.34"/>
        <path d="M18 2H6v7a6 6 0 0 0 12 0V2z"/>
    </svg>
    """,
    "icon-heartbeat": """
    <svg viewBox="0 0 24 24" fill="none" stroke="white" stroke-width="2.4" stroke-linecap="round" stroke-linejoin="round">
        <path d="M22 12h-4l-3 9L9 3l-3 9H2"/>
    </svg>
    """,
    "icon-location": """
    <svg viewBox="0 0 24 24" fill="none" stroke="white" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round">
        <path d="M20 10c0 6-8 12-8 12s-8-6-8-12a8 8 0 0 1 16 0Z"/>
        <circle cx="12" cy="10" r="3"/>
    </svg>
    """,
    "icon-shield": """
    <svg viewBox="0 0 24 24" fill="none" stroke="white" stroke-width="2.2" stroke-linecap="round" stroke-linejoin="round">
        <path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z"/>
        <path d="m9 12 2 2 4-4"/>
    </svg>
    """,
    "icon-chart": """
    <svg viewBox="0 0 24 24" fill="none" stroke="white" stroke-width="2.4" stroke-linecap="round" stroke-linejoin="round">
        <path d="M3 3v18h18"/>
        <path d="m19 9-5 5-4-4-3 3"/>
    </svg>
    """
}

# Generate standalone HTML for each icon
for name, svg_content in ICONS.items():
    html_content = f"""<!DOCTYPE html>
<html>
<head>
<meta charset="utf-8">
<style>
  * {{ margin: 0; padding: 0; box-sizing: border-box; }}
  body {{
    background: transparent;
    display: flex;
    align-items: center;
    justify-content: center;
    width: 256px;
    height: 256px;
  }}
  .badge {{
    width: 216px;
    height: 216px;
    border-radius: 50%;
    background: linear-gradient(135deg, #FF6B00 0%, #FF8533 50%, #FFA04D 100%);
    box-shadow: 0 12px 28px rgba(255, 107, 0, 0.35);
    display: flex;
    align-items: center;
    justify-content: center;
  }}
  svg {{
    width: 116px;
    height: 116px;
    display: block;
    color: white;
  }}
</style>
</head>
<body>
  <div class="badge">
    {svg_content}
  </div>
</body>
</html>"""
    
    html_file = f"/tmp/{name}.html"
    png_file = os.path.join(IMAGES_DIR, f"{name}.png")
    
    with open(html_file, "w") as f:
        f.write(html_content)
        
    cmd = [
        CHROME_BIN,
        "--headless",
        "--disable-gpu",
        "--hide-scrollbars",
        "--default-background-color=00000000",
        "--window-size=256,256",
        f"--screenshot={png_file}",
        html_file
    ]
    subprocess.run(cmd, check=True, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    print(f"Generated {png_file} via Chrome headless")

print("All website icons successfully generated to PNG!")
