#!/usr/bin/env python3
"""
Renders official TT Clinics high-res brand lockups (Racket Logo + 'TT CLINICS' typography)
to crisp transparent PNG files using headless Google Chrome.
"""
import os
import subprocess

BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
IMAGES_DIR = os.path.join(BASE_DIR, "images")
CHROME_BIN = "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"

LOGO_PNG_PATH = os.path.join(IMAGES_DIR, "logo-transparent.png")

LOCKUPS = {
    "logo-lockup-header": {
        "width": 640,
        "height": 160,
        "html": f"""<!DOCTYPE html>
<html>
<head>
<meta charset="utf-8">
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=Montserrat:ital,wght@1,800;1,900&display=swap" rel="stylesheet">
<style>
  * {{ margin: 0; padding: 0; box-sizing: border-box; }}
  body {{
    background: transparent;
    display: flex;
    align-items: center;
    justify-content: flex-start;
    padding-left: 10px;
    width: 640px;
    height: 160px;
    font-family: 'Montserrat', sans-serif;
  }}
  .wrap {{
    display: flex;
    align-items: center;
    gap: 20px;
  }}
  img {{
    height: 120px;
    width: auto;
    filter: drop-shadow(0 4px 10px rgba(0,0,0,0.12));
  }}
  .text-col {{
    display: flex;
    flex-direction: column;
    justify-content: center;
  }}
  .brand {{
    font-size: 52px;
    font-weight: 900;
    font-style: italic;
    line-height: 0.95;
    letter-spacing: -1.5px;
    color: #0F172A;
  }}
  .brand .tt {{
    color: #FF6B00;
  }}
  .tagline {{
    font-size: 15px;
    font-weight: 800;
    text-transform: uppercase;
    letter-spacing: 3px;
    color: #64748B;
    margin-top: 6px;
  }}
</style>
</head>
<body>
  <div class="wrap">
    <img src="file://{LOGO_PNG_PATH}" alt="TT Logo">
    <div class="text-col">
      <div class="brand"><span class="tt">TT</span> CLINICS</div>
      <div class="tagline">Bedrijfsvitaliteit</div>
    </div>
  </div>
</body>
</html>"""
    },
    "logo-lockup-cover": {
        "width": 800,
        "height": 220,
        "html": f"""<!DOCTYPE html>
<html>
<head>
<meta charset="utf-8">
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=Montserrat:ital,wght@1,800;1,900&display=swap" rel="stylesheet">
<style>
  * {{ margin: 0; padding: 0; box-sizing: border-box; }}
  body {{
    background: transparent;
    display: flex;
    align-items: center;
    justify-content: flex-start;
    padding-left: 10px;
    width: 800px;
    height: 220px;
    font-family: 'Montserrat', sans-serif;
  }}
  .wrap {{
    display: flex;
    align-items: center;
    gap: 26px;
  }}
  img {{
    height: 180px;
    width: auto;
    filter: drop-shadow(0 8px 20px rgba(0,0,0,0.15));
  }}
  .text-col {{
    display: flex;
    flex-direction: column;
    justify-content: center;
  }}
  .brand {{
    font-size: 74px;
    font-weight: 900;
    font-style: italic;
    line-height: 0.95;
    letter-spacing: -2px;
    color: #0F172A;
  }}
  .brand .tt {{
    color: #FF6B00;
  }}
  .tagline {{
    font-size: 18px;
    font-weight: 800;
    text-transform: uppercase;
    letter-spacing: 4px;
    color: #475569;
    margin-top: 10px;
  }}
</style>
</head>
<body>
  <div class="wrap">
    <img src="file://{LOGO_PNG_PATH}" alt="TT Logo">
    <div class="text-col">
      <div class="brand"><span class="tt">TT</span> CLINICS</div>
      <div class="tagline">Het Sportieve Bedrijfsuitje</div>
    </div>
  </div>
</body>
</html>"""
    }
}

for name, cfg in LOCKUPS.items():
    html_file = f"/tmp/{name}.html"
    png_file = os.path.join(IMAGES_DIR, f"{name}.png")
    
    with open(html_file, "w") as f:
        f.write(cfg["html"])
        
    cmd = [
        CHROME_BIN,
        "--headless",
        "--disable-gpu",
        "--hide-scrollbars",
        "--default-background-color=00000000",
        f"--window-size={cfg['width']},{cfg['height']}",
        f"--screenshot={png_file}",
        html_file
    ]
    subprocess.run(cmd, check=True, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    
    # Crop to exact bounding box with subtle padding
    try:
        from PIL import Image
        im = Image.open(png_file)
        bbox = im.getbbox()
        if bbox:
            pad = 4
            crop_box = (
                max(0, bbox[0] - pad),
                max(0, bbox[1] - pad),
                min(im.width, bbox[2] + pad),
                min(im.height, bbox[3] + pad)
            )
            im_cropped = im.crop(crop_box)
            im_cropped.save(png_file)
            print(f"Generated & cropped {png_file} to {im_cropped.size}")
    except Exception as e:
        print(f"Generated {png_file} via Chrome headless (crop error: {e})")

print("All brand logo lockups successfully generated and cropped!")
