#!/bin/bash
set -e

API_KEY="sk_43687adc37a44c3ea47fadbfce9109551932a81ada645fcb"
VOICE_ID="7qdUFMklKPaaAVMsBTBt" # Roos - Dutch female

generate_voice() {
    local text="$1"
    local mp3_file="$2"
    local m4a_file="$3"

    echo "🔊 Genereren via ElevenLabs (Roos): $mp3_file..."
    
    curl -s -X POST "https://api.elevenlabs.io/v1/text-to-speech/${VOICE_ID}" \
      -H "Accept: audio/mpeg" \
      -H "Content-Type: application/json" \
      -H "xi-api-key: ${API_KEY}" \
      -d "{
        \"text\": \"${text}\",
        \"model_id\": \"eleven_multilingual_v2\",
        \"voice_settings\": {
          \"stability\": 0.55,
          \"similarity_boost\": 0.85,
          \"style\": 0.20,
          \"use_speaker_boost\": true
        }
      }" -o "${mp3_file}"

    # Check of het bestand een geldige MP3 is
    if file "${mp3_file}" | grep -q "Audio"; then
        echo "  ✓ MP3 succesvol ontvangen ($(wc -c < "${mp3_file}") bytes)"
        afconvert -f m4af -d aac "${mp3_file}" "${m4a_file}"
        echo "  ✓ Geconverteerd naar M4A: ${m4a_file}"
    else
        echo "❌ Fout bij genereren van ${mp3_file}:"
        cat "${mp3_file}"
        exit 1
    fi
}

generate_voice "Op zoek naar hét meest energieke bedrijfsuitje van Nederland? Welkom bij TT Clinics!" \
  "audio/promo-1-hook.mp3" "audio/promo-1-hook.m4a"

generate_voice "Onder leiding van voormalig topspeler en clinic-master Edward Westhoff leer je de snelste effectballen, tricks en tactieken." \
  "audio/promo-2-edward.mp3" "audio/promo-2-edward.m4a"

generate_voice "Speel in onze professionele clubzaal bij The Victory in Weesp. Of gewoon compleet verzorgd bij jullie op kantoor!" \
  "audio/promo-3-zaal.mp3" "audio/promo-3-zaal.m4a"

generate_voice "Neem het tegen elkaar op in de Company Battle, compleet met officiële TT Clinics wisseltrofee en medailles!" \
  "audio/promo-4-battle.mp3" "audio/promo-4-battle.m4a"

generate_voice "Of ga helemaal los in het donker met onze spectaculaire Glow in the Dark clinics!" \
  "audio/promo-5-glow.mp3" "audio/promo-5-glow.m4a"

generate_voice "Sluit feestelijk af met een gezellige borrel aan de bar. Vraag nu jouw team clinic aan op ttclinics punt nl!" \
  "audio/promo-6-outro.mp3" "audio/promo-6-outro.m4a"

echo "🎉 Alle 6 voice-overs succesvol gegenereerd met Roos (ElevenLabs)!"
