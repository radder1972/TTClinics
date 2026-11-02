import numpy as np
import wave

sample_rate = 44100
bpm = 112.0
beat_dur = 60.0 / bpm # ~0.5357s
sixteenth = beat_dur / 4.0
total_dur = 42.0 # ruim voor 37.4s video
total_samples = int(sample_rate * total_dur)
t = np.linspace(0, total_dur, total_samples, endpoint=False)

left = np.zeros(total_samples)
right = np.zeros(total_samples)

def add_audio(buf, start_time, audio_data, gain=1.0):
    start_idx = int(start_time * sample_rate)
    end_idx = min(start_idx + len(audio_data), total_samples)
    if start_idx >= total_samples or start_idx < 0:
        return
    segment_len = end_idx - start_idx
    buf[start_idx:end_idx] += audio_data[:segment_len] * gain

# --- DRUMS ---
# Punchy Rock Kick Drum
k_dur = 0.30
t_k = np.linspace(0, k_dur, int(sample_rate * k_dur), endpoint=False)
f_k = 160.0 * np.exp(-t_k * 30.0) + 48.0
env_k = np.exp(-t_k * 14.0)
click_k = np.exp(-t_k * 150.0) * np.sin(2 * np.pi * 1400 * t_k)
kick = (np.sin(2 * np.pi * f_k * t_k) * env_k + click_k * 0.4) * 0.95

# Crisp Snare Drum with crack & reverb tail
s_dur = 0.35
t_s = np.linspace(0, s_dur, int(sample_rate * s_dur), endpoint=False)
tone_s = (np.sin(2 * np.pi * 190 * t_s) + 0.5 * np.sin(2 * np.pi * 280 * t_s)) * np.exp(-t_s * 28.0)
noise_s = np.random.uniform(-1, 1, len(t_s)) * np.exp(-t_s * 16.0)
snare = (tone_s * 0.5 + noise_s * 0.7) * 0.85

# Hi-hats
h_dur = 0.05
t_h = np.linspace(0, h_dur, int(sample_rate * h_dur), endpoint=False)
hh_closed = np.random.uniform(-1, 1, len(t_h)) * np.exp(-t_h * 100.0) * 0.28

ho_dur = 0.24
t_ho = np.linspace(0, ho_dur, int(sample_rate * ho_dur), endpoint=False)
hh_open = np.random.uniform(-1, 1, len(t_ho)) * np.exp(-t_ho * 16.0) * 0.25

# Crash Cymbal for big scene hits
c_dur = 1.4
t_c = np.linspace(0, c_dur, int(sample_rate * c_dur), endpoint=False)
crash = np.random.uniform(-1, 1, len(t_c)) * np.exp(-t_c * 4.5) * 0.45

# --- GUITAR & SYNTH SOUNDS ---
def make_power_stab(freqs, duration=0.38, sustain=False):
    t_st = np.linspace(0, duration, int(sample_rate * duration), endpoint=False)
    wave_st = np.zeros_like(t_st)
    for f in freqs:
        # Multi-oscillator saw & square with slight chorus detune
        saw1 = 2.0 * (t_st * f - np.floor(t_st * f + 0.5))
        saw2 = 2.0 * (t_st * (f * 1.005) - np.floor(t_st * (f * 1.005) + 0.5))
        saw3 = 2.0 * (t_st * (f * 0.995) - np.floor(t_st * (f * 0.995) + 0.5))
        sub = np.sin(2 * np.pi * (f * 0.5) * t_st)
        wave_st += (saw1 * 0.35 + saw2 * 0.25 + saw3 * 0.25 + sub * 0.25)
    
    # Heavy rock distortion / overdrive
    wave_st = np.tanh(wave_st * 2.8)
    
    # Envelope
    if sustain:
        env = np.exp(-t_st * 2.8)
    else:
        env = np.exp(-t_st * 8.5)
    return wave_st * env * 0.45

# Chords: C minor rock voicing
chord_C = [130.81, 196.00, 261.63, 392.00, 523.25]
chord_Bb = [116.54, 174.61, 233.08, 349.23, 466.16]
chord_Ab = [103.83, 155.56, 207.65, 311.13, 415.30]
chord_G = [98.00, 146.83, 196.00, 293.66, 392.00]

stab_C_hit = make_power_stab(chord_C, 0.35, sustain=False)
stab_C_long = make_power_stab(chord_C, 1.2, sustain=True)
stab_Bb = make_power_stab(chord_Bb, 0.38, sustain=False)
stab_Ab = make_power_stab(chord_Ab, 0.42, sustain=False)
stab_G = make_power_stab(chord_G, 0.55, sustain=True)

# Muted palm-mute bass/guitar chug (relentless 8th notes)
def make_chug(freq=65.41, dur=0.20):
    t_ch = np.linspace(0, dur, int(sample_rate * dur), endpoint=False)
    # Square/Saw pluck + heavy low-end saturation
    w = (np.sin(2 * np.pi * freq * t_ch) + 
         0.6 * np.sin(2 * np.pi * freq * 2 * t_ch) + 
         0.3 * np.sin(2 * np.pi * freq * 3 * t_ch))
    w = np.tanh(w * 2.5)
    env = np.exp(-t_ch * 19.0)
    return w * env * 0.48

chug_C = make_chug(65.41) # C2 bass note

# Soaring Sports Synth Lead (Arpeggiated excitement)
def make_lead_note(f, dur=0.18):
    t_l = np.linspace(0, dur, int(sample_rate * dur), endpoint=False)
    w = np.sin(2 * np.pi * f * t_l) + 0.4 * np.sin(2 * np.pi * f * 2 * t_l)
    return w * np.exp(-t_l * 12.0) * 0.16

lead_notes = [523.25, 587.33, 622.25, 698.46, 783.99] # C, D, Eb, F, G

# --- SEQUENCER ---
# 4 bars per riff cycle
total_bars = int(total_dur / (4 * beat_dur)) + 2

for bar in range(total_bars):
    bar_start = bar * (4 * beat_dur)
    pattern_bar = bar % 4
    
    # Crash on beat 1 of every 4 bars
    if pattern_bar == 0:
        add_audio(left, bar_start, crash, 0.7)
        add_audio(right, bar_start, crash, 0.7)
        
    for beat in range(4):
        b_time = bar_start + beat * beat_dur
        if b_time >= total_dur: break
        
        # 4-on-the-floor driving kick drum
        add_audio(left, b_time, kick, 0.95)
        add_audio(right, b_time, kick, 0.95)
        
        # Snare on 2 and 4
        if beat in [1, 3]:
            add_audio(left, b_time, snare, 0.9)
            add_audio(right, b_time, snare, 0.9)
            
        # 16th note hi-hat groove
        for s_idx in range(4):
            hh_time = b_time + s_idx * sixteenth
            if s_idx == 2: # upbeat open hat for forward drive
                add_audio(left, hh_time, hh_open, 0.3)
                add_audio(right, hh_time, hh_open, 0.3)
            else:
                add_audio(left, hh_time, hh_closed, 0.32)
                add_audio(right, hh_time, hh_closed, 0.32)
                
            # Driving 16th note synth pulse
            note = lead_notes[(bar * 16 + beat * 4 + s_idx) % len(lead_notes)]
            lead_s = make_lead_note(note)
            add_audio(right, hh_time, lead_s * 0.45)
            
        # Relentless 8th note chugs on C
        add_audio(left, b_time, chug_C, 0.75)
        add_audio(right, b_time, chug_C, 0.75)
        add_audio(left, b_time + beat_dur * 0.5, chug_C, 0.65)
        add_audio(right, b_time + beat_dur * 0.5, chug_C, 0.65)

    # EYE OF THE TIGER ICONIC SYNCOPATED HITS:
    if pattern_bar == 0:
        # Bar 1: Big Opening Hit on Beat 1! Ringing out over chugs
        add_audio(left, bar_start, stab_C_long, 1.1)
        add_audio(right, bar_start, stab_C_long, 1.1)
    elif pattern_bar == 1:
        # Bar 2: Hits on Beat 3& and Beat 4!
        t_hit1 = bar_start + 2.5 * beat_dur
        t_hit2 = bar_start + 3.0 * beat_dur
        add_audio(left, t_hit1, stab_C_hit, 1.2)
        add_audio(right, t_hit1, stab_C_hit, 1.2)
        add_audio(left, t_hit2, stab_C_hit, 1.3)
        add_audio(right, t_hit2, stab_C_hit, 1.3)
    elif pattern_bar == 2:
        # Bar 3: The famous cascading riff: 1& (C), 2 (Bb), 2& (Ab), 3 (G)
        t_h1 = bar_start + 0.5 * beat_dur # C
        t_h2 = bar_start + 1.5 * beat_dur # Bb
        t_h3 = bar_start + 2.0 * beat_dur # Ab
        t_h4 = bar_start + 3.0 * beat_dur # G
        add_audio(left, t_h1, stab_C_hit, 1.2)
        add_audio(right, t_h1, stab_C_hit, 1.2)
        add_audio(left, t_h2, stab_Bb, 1.15)
        add_audio(right, t_h2, stab_Bb, 1.15)
        add_audio(left, t_h3, stab_Ab, 1.15)
        add_audio(right, t_h3, stab_Ab, 1.15)
        add_audio(left, t_h4, stab_G, 1.25)
        add_audio(right, t_h4, stab_G, 1.25)
    elif pattern_bar == 3:
        # Bar 4: Power resolution back to C!
        add_audio(left, bar_start, stab_C_long, 1.05)
        add_audio(right, bar_start, stab_C_long, 1.05)

# Normalization & Master Limiter
max_peak = max(np.max(np.abs(left)), np.max(np.abs(right)))
if max_peak > 0:
    left = np.tanh(left / max_peak * 1.3) * 0.92
    right = np.tanh(right / max_peak * 1.3) * 0.92

out_wav = "audio/promo-bg-music.wav"
with wave.open(out_wav, "wb") as wav_file:
    wav_file.setnchannels(2)
    wav_file.setsampwidth(2)
    wav_file.setframerate(sample_rate)
    interleaved = np.empty((len(left) * 2,), dtype=np.int16)
    interleaved[0::2] = (left * 32767).astype(np.int16)
    interleaved[1::2] = (right * 32767).astype(np.int16)
    wav_file.writeframes(interleaved.tobytes())

print(f"✓ 'Eye of the Tiger' stijl opzwepende muziek vernieuwd: {out_wav}")
