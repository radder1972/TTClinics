#!/usr/bin/env python3
"""
scripts/build_video_edward_welkom.py

Bouwt de 9:16 (1080x1920) welkomstvideo "Welkom bij TT Clinics" met Edward Westhoff,
inclusief huisstijl-logo pill, exact gesynchroniseerde ondertiteling en de vaste
TT Clinics eindkaart (The Victory Weesp • 06 - 11618060 • ttclinics.nl).
Exact gemodelleerd naar Geert-Jan's welkomstvideo bij Staopstoelen.nl.
"""
import base64
import io
import shutil
import subprocess
import sys
from pathlib import Path
from PIL import Image

WS = Path("/Users/matthiasradder/AntiGravity Projecten/TT Clinics")
FFMPEG = "/Users/matthiasradder/.local/bin/ffmpeg"
CHROME = "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"

FONT = "<link href='https://fonts.googleapis.com/css2?family=Montserrat:ital,wght@0,700;0,800;0,900;1,900&family=Inter:wght@500;600;700&display=swap' rel='stylesheet'>"
BASE = "*{margin:0;padding:0;box-sizing:border-box} html,body{width:1080px;height:1920px;overflow:hidden;background:transparent}"

def duration(path: Path) -> float:
    r = subprocess.run([FFMPEG, "-i", str(path)], stderr=subprocess.PIPE, text=True)
    for line in r.stderr.splitlines():
        if "Duration:" in line:
            h, m, s = line.split("Duration:")[1].split(",")[0].strip().split(":")
            return int(h) * 3600 + int(m) * 60 + float(s)
    return 9.0

def run(cmd):
    subprocess.run(cmd, check=True, stdout=subprocess.DEVNULL, stderr=subprocess.PIPE)

def render_ov(html: str, out: Path):
    tmp = out.parent / f"_tmp_{out.stem}.html"
    tmp.write_text(html, encoding="utf-8")
    run([
        CHROME, "--headless=new", "--disable-gpu", "--hide-scrollbars",
        "--window-size=1080,1920", "--virtual-time-budget=4000",
        "--default-background-color=00000000", f"--screenshot={out}", tmp.as_uri()
    ])
    tmp.unlink(missing_ok=True)

def build_eindkaart(out_path: Path):
    logo_img = Image.open(WS / "images/logo-sticker.png").convert("RGBA")
    bbox = logo_img.getbbox()
    if bbox:
        logo_img = logo_img.crop(bbox)
    buf = io.BytesIO()
    logo_img.save(buf, format="PNG")
    logo_uri = "data:image/png;base64," + base64.b64encode(buf.getvalue()).decode("ascii")

    html = f"""<!DOCTYPE html>
<html>
<head>
<meta charset="utf-8">
{FONT}
<style>
  {BASE}
  body {{
    background: radial-gradient(circle at 50% 25%, #2a201a 0%, #16161a 50%, #090a0f 100%);
    color: #ffffff;
    font-family: 'Inter', sans-serif;
    display: flex;
    flex-direction: column;
    align-items: center;
    justify-content: space-between;
    padding: 130px 60px 110px 60px;
    position: relative;
  }}
  .swoosh-bg {{
    position: absolute;
    inset: 0;
    pointer-events: none;
    opacity: 0.18;
  }}
  .glow {{
    position: absolute;
    width: 600px;
    height: 600px;
    background: radial-gradient(circle, rgba(255,107,0,0.35) 0%, rgba(255,107,0,0) 70%);
    top: 140px;
    border-radius: 50%;
    filter: blur(50px);
    pointer-events: none;
  }}
  .header {{
    display: flex;
    flex-direction: column;
    align-items: center;
    text-align: center;
    position: relative;
    z-index: 10;
  }}
  .logo-box {{
    display: flex;
    align-items: center;
    gap: 22px;
    background: rgba(255,255,255,0.96);
    padding: 22px 48px;
    border-radius: 60px;
    box-shadow: 0 16px 40px rgba(0,0,0,0.4);
    margin-bottom: 34px;
  }}
  .logo-box img {{
    height: 80px;
  }}
  .logo-text {{
    font-family: 'Montserrat', sans-serif;
    font-weight: 900;
    font-style: italic;
    font-size: 46px;
    letter-spacing: -1.5px;
    color: #181818;
  }}
  .logo-text span {{
    color: #FF6B00;
  }}
  .tagline {{
    font-family: 'Montserrat', sans-serif;
    font-weight: 900;
    font-style: italic;
    font-size: 52px;
    line-height: 1.15;
    text-align: center;
    text-transform: uppercase;
    color: #ffffff;
    max-width: 900px;
    text-shadow: 0 4px 18px rgba(0,0,0,0.6);
  }}
  .tagline span {{
    color: #FF6B00;
  }}
  .subtag {{
    font-size: 26px;
    font-weight: 600;
    color: #cbd5e1;
    margin-top: 14px;
    letter-spacing: 0.5px;
  }}
  .bullets {{
    display: flex;
    flex-direction: column;
    gap: 20px;
    width: 100%;
    max-width: 880px;
    background: rgba(255,255,255,0.06);
    border: 1.5px solid rgba(255,255,255,0.14);
    border-radius: 28px;
    padding: 36px 44px;
    backdrop-blur: 16px;
    position: relative;
    z-index: 10;
  }}
  .bullet-item {{
    display: flex;
    align-items: center;
    gap: 20px;
    font-size: 27px;
    font-weight: 600;
    color: #f1f5f9;
  }}
  .bullet-dot {{
    width: 44px;
    height: 44px;
    border-radius: 50%;
    background: #FF6B00;
    color: #ffffff;
    display: flex;
    align-items: center;
    justify-content: center;
    font-size: 22px;
    font-weight: 900;
    flex-shrink: 0;
    box-shadow: 0 4px 14px rgba(255,107,0,0.5);
  }}
  .cta-card {{
    width: 100%;
    max-width: 880px;
    background: linear-gradient(135deg, rgba(255,107,0,0.22) 0%, rgba(255,107,0,0.08) 100%);
    border: 2px solid #FF6B00;
    border-radius: 32px;
    padding: 40px 44px;
    display: flex;
    flex-direction: column;
    align-items: center;
    text-align: center;
    gap: 16px;
    box-shadow: 0 20px 50px rgba(255,107,0,0.25);
    position: relative;
    z-index: 10;
  }}
  .cta-title {{
    font-family: 'Montserrat', sans-serif;
    font-weight: 900;
    font-size: 40px;
    color: #ffffff;
    text-transform: uppercase;
    letter-spacing: 0.5px;
  }}
  .cta-phone {{
    font-family: 'Montserrat', sans-serif;
    font-weight: 900;
    font-size: 46px;
    color: #FF6B00;
    background: rgba(0,0,0,0.55);
    padding: 12px 36px;
    border-radius: 40px;
    border: 1px solid rgba(255,107,0,0.4);
    box-shadow: 0 6px 20px rgba(0,0,0,0.4);
  }}
  .cta-web {{
    font-size: 26px;
    font-weight: 700;
    color: #e2e8f0;
  }}
  .cta-badge {{
    font-size: 20px;
    font-weight: 600;
    color: #94a3b8;
    text-transform: uppercase;
    letter-spacing: 1.5px;
  }}
</style>
</head>
<body>
  <div class="glow"></div>
  <svg class="swoosh-bg" viewBox="0 0 200 100" preserveAspectRatio="none">
    <path d="M0,82 L196,8 L176,30 Z" fill="#FF6B00"/>
    <path d="M22,98 L184,44 L170,56 Z" fill="#FF9A4D"/>
    <path d="M8,58 L150,6 L136,20 Z" fill="#ffffff"/>
  </svg>

  <div class="header">
    <div class="logo-box">
      <img src="{logo_uri}" alt="TT Clinics Logo">
      <div class="logo-text"><span>TT</span> CLINICS</div>
    </div>
    <div class="tagline">Schaken op <span>Topsnelheid</span></div>
    <div class="subtag">Hét meest dynamische bedrijfsuitje van Nederland</div>
  </div>

  <div class="bullets">
    <div class="bullet-item">
      <div class="bullet-dot">✓</div>
      <div>Professionele coaching door Edward Westhoff</div>
    </div>
    <div class="bullet-item">
      <div class="bullet-dot">✓</div>
      <div>Eigen toernooi met officiële TT Clinics wisselbokaal</div>
    </div>
    <div class="bullet-item">
      <div class="bullet-dot">✓</div>
      <div>Vaste arena bij The Victory Weesp óf op eigen kantoor</div>
    </div>
    <div class="bullet-item">
      <div class="bullet-dot">✓</div>
      <div>Gezellige naborrel & catering naar wens</div>
    </div>
  </div>

  <div class="cta-card">
    <div class="cta-title">Vraag Direct Vrijblijvend Aan</div>
    <div class="cta-phone">Bel Edward: 06 - 11618060</div>
    <div class="cta-web">Direct datum reserveren ➔ ttclinics.nl</div>
    <div class="cta-badge">Persoonlijk voorstel binnen 24 uur</div>
  </div>
</body>
</html>"""
    render_ov(html, out_path)
    print("✓ Outro slide gegenereerd:", out_path)

def build_overlays(work_dir: Path):
    logo_img = Image.open(WS / "images/logo-sticker.png").convert("RGBA")
    bbox = logo_img.getbbox()
    if bbox:
        logo_img = logo_img.crop(bbox)
    buf = io.BytesIO()
    logo_img.save(buf, format="PNG")
    logo_uri = "data:image/png;base64," + base64.b64encode(buf.getvalue()).decode("ascii")

    # Top pill persistent during Scene 1
    render_ov(f"""<html><head>{FONT}<style>{BASE}
      .top{{position:absolute;top:76px;left:0;right:0;display:flex;justify-content:center}}
      .pill{{background:rgba(255,255,255,0.95);padding:16px 36px;border-radius:60px;box-shadow:0 14px 36px rgba(0,0,0,0.35);display:flex;align-items:center;gap:16px}}
      .pill img{{height:54px}}
      .pill-text{{font-family:Montserrat;font-weight:900;font-style:italic;font-size:32px;letter-spacing:-1px;color:#181818}}
      .pill-text span{{color:#FF6B00}}
    </style></head><body>
      <div class="top"><div class="pill"><img src="{logo_uri}"><div class="pill-text"><span>TT</span> CLINICS</div></div></div>
    </body></html>""", work_dir / "ov_top.png")

    # Sub 1 (0.10 - 2.80s): Welkom bij TT Clinics!
    render_ov(f"""<html><head>{FONT}<style>{BASE}
      .bot{{position:absolute;bottom:210px;left:0;right:0;display:flex;flex-direction:column;align-items:center;gap:16px}}
      .name{{font-family:Montserrat;font-weight:800;font-size:32px;color:#fff;background:#FF6B00;padding:10px 28px;border-radius:40px;box-shadow:0 8px 24px rgba(255,107,0,0.45);letter-spacing:0.5px}}
      .cap{{font-family:Montserrat;font-weight:900;font-size:60px;color:#fff;text-align:center;line-height:1.15;
            background:rgba(24,28,32,0.82);padding:26px 46px;border-radius:26px;max-width:960px;box-shadow:0 14px 36px rgba(0,0,0,0.35);border:1px solid rgba(255,255,255,0.1)}}
      .accent{{color:#FF6B00}}
    </style></head><body>
      <div class="bot">
        <div class="name">Edward Westhoff • Clinic Master & Coach</div>
        <div class="cap">“Welkom bij <span class="accent">TT Clinics!</span>”</div>
      </div>
    </body></html>""", work_dir / "ov_sub1.png")

    # Sub 2 (2.80 - 5.70s): Schaken op topsnelheid met je hele team!
    render_ov(f"""<html><head>{FONT}<style>{BASE}
      .bot{{position:absolute;bottom:210px;left:0;right:0;display:flex;flex-direction:column;align-items:center}}
      .cap{{font-family:Montserrat;font-weight:900;font-size:52px;color:#fff;text-align:center;line-height:1.22;
            background:rgba(24,28,32,0.82);padding:26px 44px;border-radius:26px;max-width:960px;box-shadow:0 14px 36px rgba(0,0,0,0.35);border:1px solid rgba(255,255,255,0.1)}}
      .accent{{color:#FF6B00}}
    </style></head><body>
      <div class="bot">
        <div class="cap">Schaken op <span class="accent">topsnelheid</span><br>met je hele team!</div>
      </div>
    </body></html>""", work_dir / "ov_sub2.png")

    # Sub 3 (5.70 - 8.60s): In Weesp of op eigen kantoor!
    render_ov(f"""<html><head>{FONT}<style>{BASE}
      .bot{{position:absolute;bottom:210px;left:0;right:0;display:flex;flex-direction:column;align-items:center}}
      .cap{{font-family:Montserrat;font-weight:900;font-size:54px;color:#fff;text-align:center;line-height:1.22;
            background:rgba(24,28,32,0.82);padding:26px 44px;border-radius:26px;max-width:960px;box-shadow:0 14px 36px rgba(0,0,0,0.35);border:1px solid rgba(255,255,255,0.1)}}
      .accent{{color:#FF6B00}}
    </style></head><body>
      <div class="bot">
        <div class="cap">In Weesp óf op<br><span class="accent">eigen kantoor!</span></div>
      </div>
    </body></html>""", work_dir / "ov_sub3.png")

def build_master(clip_path: Path, work_dir: Path, out_path: Path):
    work_dir.mkdir(parents=True, exist_ok=True)
    build_overlays(work_dir)
    eindkaart = work_dir / "slide_eindkaart.png"
    build_eindkaart(eindkaart)

    music = WS / "audio/promo-bg-music.wav"
    clip_dur = min(duration(clip_path), 8.8)
    outro_dur = 4.5
    xf = 0.5

    # 1. Scene 1: Edward speaking + top logo pill + 3 timed subtitles
    s1_vid = work_dir / "_s1_speaking.mp4"
    run([
        FFMPEG, "-y",
        "-i", str(clip_path),
        "-loop", "1", "-t", f"{clip_dur:.2f}", "-i", str(work_dir / "ov_top.png"),
        "-loop", "1", "-t", f"{clip_dur:.2f}", "-i", str(work_dir / "ov_sub1.png"),
        "-loop", "1", "-t", f"{clip_dur:.2f}", "-i", str(work_dir / "ov_sub2.png"),
        "-loop", "1", "-t", f"{clip_dur:.2f}", "-i", str(work_dir / "ov_sub3.png"),
        "-filter_complex",
        f"[0:v]scale=1080:1920:force_original_aspect_ratio=increase,crop=1080:1920,fps=30,setsar=1[bg];"
        f"[1:v]format=rgba,fade=t=in:st=0.10:d=0.30:alpha=1,fade=t=out:st={clip_dur - 0.55:.2f}:d=0.35:alpha=1[top];"
        f"[2:v]format=rgba,fade=t=in:st=0.08:d=0.22:alpha=1,fade=t=out:st=2.70:d=0.20:alpha=1[s1];"
        f"[3:v]format=rgba,fade=t=in:st=2.80:d=0.22:alpha=1,fade=t=out:st=5.55:d=0.20:alpha=1[s2];"
        f"[4:v]format=rgba,fade=t=in:st=5.70:d=0.22:alpha=1,fade=t=out:st=8.30:d=0.30:alpha=1[s3];"
        f"[bg][top]overlay=0:0[t0];"
        f"[t0][s1]overlay=0:0:enable='between(t,0,2.80)'[t1];"
        f"[t1][s2]overlay=0:0:enable='between(t,2.80,5.70)'[t2];"
        f"[t2][s3]overlay=0:0:enable='between(t,5.70,8.60)',format=yuv420p[v]",
        "-map", "[v]", "-t", f"{clip_dur:.2f}",
        "-c:v", "libx264", "-preset", "medium", "-crf", "18", str(s1_vid)
    ])

    # 2. Scene 2: Outro Card with gentle Ken Burns zoompan
    s2_vid = work_dir / "_s2_outro.mp4"
    n_outro = int(outro_dur * 30)
    run([
        FFMPEG, "-y",
        "-loop", "1", "-i", str(eindkaart),
        "-vf", f"scale=1080:1920,zoompan=z='1+0.025*on/{n_outro}':x='iw/2-(iw/zoom/2)':y='ih/2-(ih/zoom/2)':d={n_outro}:s=1080x1920:fps=30,format=yuv420p",
        "-t", f"{outro_dur:.2f}", "-r", "30",
        "-c:v", "libx264", "-preset", "medium", "-crf", "18", str(s2_vid)
    ])

    # 3. Crossfade Scene 1 -> Scene 2
    stitched_vid = work_dir / "_stitched_master.mp4"
    offset = clip_dur - xf
    total_dur = clip_dur + outro_dur - xf
    run([
        FFMPEG, "-y",
        "-i", str(s1_vid), "-i", str(s2_vid),
        "-filter_complex", f"[0:v][1:v]xfade=transition=fade:duration={xf}:offset={offset:.2f},format=yuv420p[v]",
        "-map", "[v]", "-c:v", "libx264", "-preset", "medium", "-crf", "18", str(stitched_vid)
    ])

    # 4. Audio mix: Edward's voice + energetic music bed swelling into the outro card
    audio_fc = (
        f"[1:a]atrim=0:{clip_dur:.2f},asetpts=PTS-STARTPTS,loudnorm=I=-14:TP=-1.0:LRA=7,aresample=48000,pan=stereo|c0=c0|c1=c1,"
        f"afade=t=out:st={clip_dur - 0.50:.2f}:d=0.50,apad=whole_dur={total_dur:.2f}[speech];"
        f"[2:a]atrim=0:{total_dur:.2f},asetpts=PTS-STARTPTS,aresample=48000,"
        f"volume='if(lt(t,7.8),0.10,0.10+0.16*min(1,(t-7.8)/0.8))':eval=frame,"
        f"afade=t=in:st=0:d=0.6,afade=t=out:st={total_dur - 1.0:.2f}:d=1.0[bgm];"
        f"[speech][bgm]amix=inputs=2:duration=first:dropout_transition=0:normalize=0[aout]"
    )

    out_path.parent.mkdir(parents=True, exist_ok=True)
    run([
        FFMPEG, "-y",
        "-i", str(stitched_vid),
        "-i", str(clip_path),
        "-i", str(music),
        "-filter_complex", audio_fc,
        "-map", "0:v", "-map", "[aout]",
        "-t", f"{total_dur:.2f}",
        "-c:v", "copy", "-c:a", "aac", "-b:a", "192k", "-movflags", "+faststart",
        str(out_path)
    ])

    # Also save to Desktop/Google_Ads_PMax_Videos
    desktop_out = Path.home() / "Desktop/Google_Ads_PMax_Videos/Edward_Welkom_TTClinics_9x16.mp4"
    desktop_out.parent.mkdir(parents=True, exist_ok=True)
    shutil.copy2(out_path, desktop_out)

    print(f"🎉 Master klaar: {out_path} ({total_dur:.1f}s)")
    print(f"🎉 Bureaublad kopie: {desktop_out}")

if __name__ == "__main__":
    clip = Path(sys.argv[1]) if len(sys.argv) > 1 else Path("/Users/matthiasradder/.gemini/antigravity/brain/7d58a79c-8e87-46fc-a288-3987ca932119/scratch/welkom_video/edward_speaking.mp4")
    work = Path(sys.argv[2]) if len(sys.argv) > 2 else Path("/Users/matthiasradder/.gemini/antigravity/brain/7d58a79c-8e87-46fc-a288-3987ca932119/scratch/welkom_video/build")
    out = Path(sys.argv[3]) if len(sys.argv) > 3 else WS / "video/edward_welkom_ttclinics_9x16.mp4"
    build_master(clip, work, out)
