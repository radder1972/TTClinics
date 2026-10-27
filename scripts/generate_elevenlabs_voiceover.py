#!/usr/bin/env python3
"""
Genereert studio-kwaliteit Nederlandse voice-over MP3's via de ElevenLabs API
voor de TT Clinics ontstaansfilm met Edward Westhoff en Bettine Vriesekoop.

Gebruik:
  export ELEVENLABS_API_KEY="jouw_api_key_hier"
  python3 scripts/generate_elevenlabs_voiceover.py

Of geef de key direct mee:
  python3 scripts/generate_elevenlabs_voiceover.py --api-key "jouw_api_key_hier"
"""

import os
import sys
import json
import urllib.request
import argparse

# 4 scènes met zorgvuldig afgestemde pauzes en intonatie
SCENES = [
    {
        "filename": "audio/story-1-woensdag.mp3",
        "title": "Scène 1: De Woensdagochtend",
        "text": (
            "Het begon allemaal op een vroege woensdagochtend in een bescheiden gymzaal. "
            "Edward Westhoff zette in alle vroegte de tafels en ballen klaar. "
            "Wat begon als een gezellige training, liet al snel zien wat tafeltennis écht teweegbrengt: "
            "ongekende energie, plezier en focus."
        )
    },
    {
        "filename": "audio/story-2-bettine.mp3",
        "title": "Scène 2: De Ontmoeting met Bettine",
        "text": (
            "Toen tweevoudig Europees kampioene Bettine Vriesekoop aansloot, sloeg de vonk definitief over. "
            "Als topsportlegende wist Bettine als geen ander hoe je mensen in beweging krijgt. "
            "Samen stonden ze aan de tafel en zagen ze de enorme kans om deze topsportvitaliteit naar het bedrijfsleven te brengen."
        )
    },
    {
        "filename": "audio/story-3-concept.mp3",
        "title": "Scène 3: De Formule",
        "text": (
            "Aan de rand van de tafeltennis-tafel ontwikkelden ze samen de unieke clinic-formule: "
            "Schaken op topsnelheid. Geen saaie theorielessen, maar een energieke masterclass in effectballen, "
            "gekoppeld aan een zinderend King of the Court toernooi voor vitale teams."
        )
    },
    {
        "filename": "audio/story-4-lancering.mp3",
        "title": "Scène 4: De Officiële Lancering",
        "text": (
            "En zo werd TT Clinics geboren! Met de allereerste wisselbokaal en professionele batjes werd het officiële startsein gegeven. "
            "Vandaag de dag brengen Edward en zijn team dezelfde energie en teamspirit naar bedrijven door heel Nederland!"
        )
    }
]

# Populaire warme, documentaire ElevenLabs stemmen met eleven_multilingual_v2
DEFAULT_VOICE_ID = "JBFqnCBsd6RMkjVDRZzb"  # George (warm, diep, filmisch)
# Alternatieven:
# "pNInz6obpgDQGcFmaJgB" (Adam)
# "onwK4e9ZLuTAKqWW03F9" (Daniel)
# "N2lVS1w4EtoT3dr4eOWO" (Callum)

def generate_voiceover(api_key: str, voice_id: str = DEFAULT_VOICE_ID):
    os.makedirs("audio", exist_ok=True)
    
    url = f"https://api.elevenlabs.io/v1/text-to-speech/{voice_id}"
    headers = {
        "xi-api-key": api_key.strip(),
        "Content-Type": "application/json",
        "Accept": "audio/mpeg"
    }

    print(f"🎬 Start ElevenLabs generatie met stem ID: {voice_id} ...\n")

    for i, sc in enumerate(SCENES, 1):
        print(f"[{i}/{len(SCENES)}] Genereren van {sc['title']} ...")
        payload = {
            "text": sc["text"],
            "model_id": "eleven_multilingual_v2",
            "voice_settings": {
                "stability": 0.55,
                "similarity_boost": 0.82,
                "style": 0.25,
                "use_speaker_boost": True
            }
        }

        req = urllib.request.Request(
            url,
            data=json.dumps(payload).encode("utf-8"),
            headers=headers,
            method="POST"
        )

        try:
            with urllib.request.urlopen(req) as resp:
                audio_bytes = resp.read()
                out_path = sc["filename"]
                with open(out_path, "wb") as f:
                    f.write(audio_bytes)
                print(f"  ✓ Opgeslagen als {out_path} ({len(audio_bytes) // 1024} KB)")
        except urllib.error.HTTPError as e:
            err_msg = e.read().decode("utf-8", errors="ignore")
            print(f"  ✗ Fout bij genereren van scène {i}: HTTP {e.code} - {err_msg}", file=sys.stderr)
            return False
        except Exception as e:
            print(f"  ✗ Onverwachte fout: {e}", file=sys.stderr)
            return False

    print("\n🎉 Alle 4 de voice-over MP3 bestanden zijn succesvol gegenereerd in de map 'audio/'!")
    return True

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="ElevenLabs Voice-over Generator")
    parser.add_argument("--api-key", default=os.environ.get("ELEVENLABS_API_KEY", ""), help="ElevenLabs API Key")
    parser.add_argument("--voice-id", default=DEFAULT_VOICE_ID, help="ElevenLabs Voice ID")
    args = parser.parse_args()

    api_key = args.api_key or os.environ.get("ELEVEN_API_KEY", "")
    if not api_key:
        print("Geen API key gevonden. Geef deze mee via:")
        print("  export ELEVENLABS_API_KEY=\"...\"")
        print("  of: python3 scripts/generate_elevenlabs_voiceover.py --api-key \"...\"")
        sys.exit(1)

    success = generate_voiceover(api_key, args.voice_id)
    sys.exit(0 if success else 1)
