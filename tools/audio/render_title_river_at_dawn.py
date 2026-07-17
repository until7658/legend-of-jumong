"""Render the original title loop "River at Dawn" as a stereo WAV.

The piece is synthesized from simple waveforms so the project retains a
reproducible source.  It intentionally uses no sampled or third-party music.
"""

from __future__ import annotations

import math
import wave
from pathlib import Path

import numpy as np


SAMPLE_RATE = 44_100
DURATION = 84.0
FRAMES = int(SAMPLE_RATE * DURATION)
ROOT = Path(__file__).resolve().parents[2]
OUTPUT = ROOT / "assets" / "audio" / "music" / "title_river_at_dawn.wav"


def midi(note: int) -> float:
    return 440.0 * (2.0 ** ((note - 69) / 12.0))


def circular_envelope(center: float, half_width: float) -> np.ndarray:
    time = np.arange(FRAMES, dtype=np.float64) / SAMPLE_RATE
    distance = np.abs((time - center + DURATION / 2.0) % DURATION - DURATION / 2.0)
    phase = np.clip(distance / half_width, 0.0, 1.0)
    return np.where(distance < half_width, 0.5 + 0.5 * np.cos(np.pi * phase), 0.0)


def tone(frequency: float, phase: float = 0.0) -> np.ndarray:
    time = np.arange(FRAMES, dtype=np.float64) / SAMPLE_RATE
    return np.sin(2.0 * np.pi * frequency * time + phase)


def soft_voice(frequency: float, brightness: float = 0.22) -> np.ndarray:
    fundamental = tone(frequency)
    second = tone(frequency * 2.0, 0.31) * brightness
    third = tone(frequency * 3.0, 0.77) * brightness * 0.28
    return np.tanh((fundamental + second + third) * 0.82)


def delayed(signal: np.ndarray, seconds: float) -> np.ndarray:
    return np.roll(signal, int(seconds * SAMPLE_RATE))


def main() -> None:
    time = np.arange(FRAMES, dtype=np.float64) / SAMPLE_RATE
    left = np.zeros(FRAMES, dtype=np.float64)
    right = np.zeros(FRAMES, dtype=np.float64)

    # Low strings: an open D/A field whose slow breathing is periodic at the loop.
    breath = 0.72 + 0.18 * np.sin(2.0 * np.pi * time / DURATION - 0.8)
    drone = (
        0.62 * soft_voice(midi(38), 0.10)
        + 0.34 * soft_voice(midi(45), 0.08)
        + 0.16 * soft_voice(midi(50), 0.06)
    ) * breath
    left += drone * 0.28
    right += delayed(drone, 0.019) * 0.27

    # Seven twelve-second phrases. The five-note cell is reserved for later
    # expansion in the prologue rather than stated as a heroic full theme.
    phrase_notes = [62, 65, 67, 69, 67, 65, 62]
    answer_notes = [57, 60, 62, 65, 64, 60, 57]
    for phrase in range(7):
        base = phrase * 12.0
        for index, note in enumerate(phrase_notes):
            center = (base + 1.2 + index * 1.45) % DURATION
            envelope = circular_envelope(center, 1.22)
            voice = soft_voice(midi(note), 0.18) * envelope
            pan = 0.38 + 0.18 * math.sin(phrase * 1.7 + index * 0.9)
            level = 0.105 if phrase in (2, 3, 4) else 0.078
            left += voice * level * math.sqrt(1.0 - pan)
            right += delayed(voice, 0.011) * level * math.sqrt(pan)

        # A lower bowed answer leaves room for the title UI and environmental sound.
        for index, note in enumerate(answer_notes[::2]):
            center = (base + 4.0 + index * 2.15) % DURATION
            envelope = circular_envelope(center, 2.0)
            voice = soft_voice(midi(note - 12), 0.09) * envelope * 0.072
            left += voice * 0.78
            right += delayed(voice, 0.027) * 0.74

    # Sparse bell-like reflections suggest dawn on water without a triumphant accent.
    for index, note in enumerate([74, 77, 81, 79, 74, 72, 69]):
        center = index * 12.0 + 8.8
        envelope = circular_envelope(center, 1.7) ** 2
        shimmer = (tone(midi(note)) + 0.36 * tone(midi(note) * 2.01, 0.5)) * envelope
        left += shimmer * 0.026
        right += delayed(shimmer, 0.043) * 0.031

    # Quiet, deterministic breath texture; circular smoothing keeps the seam clean.
    rng = np.random.default_rng(20260717)
    noise = rng.normal(0.0, 1.0, FRAMES)
    kernel_size = 1400
    spectrum = np.fft.rfft(noise)
    frequencies = np.fft.rfftfreq(FRAMES, 1.0 / SAMPLE_RATE)
    spectrum *= np.exp(-((frequencies / 680.0) ** 2)) * (1.0 - np.exp(-((frequencies / 65.0) ** 2)))
    air = np.fft.irfft(spectrum, FRAMES)
    air /= max(np.max(np.abs(air)), 1e-9)
    air *= 0.018 * (0.7 + 0.3 * np.sin(2.0 * np.pi * time / 21.0))
    left += air
    right += np.roll(air, kernel_size) * 0.94

    # Circular ambience taps remain sample-aligned at the loop boundary.
    left += delayed(left, 0.173) * 0.11 + delayed(right, 0.347) * 0.065
    right += delayed(right, 0.211) * 0.105 + delayed(left, 0.401) * 0.06

    stereo = np.column_stack((left, right))
    stereo -= np.mean(stereo, axis=0, keepdims=True)

    # Meet at digital silence over a very short breath. This prevents a click
    # even when the imported WAV player loops on an exact sample boundary.
    seam_frames = int(0.08 * SAMPLE_RATE)
    seam_curve = np.sin(np.linspace(0.0, np.pi / 2.0, seam_frames)) ** 2
    stereo[:seam_frames] *= seam_curve[:, None]
    stereo[-seam_frames:] *= seam_curve[::-1, None]
    stereo[0] = 0.0
    stereo[-1] = 0.0
    peak = float(np.max(np.abs(stereo)))
    stereo *= (10.0 ** (-6.0 / 20.0)) / max(peak, 1e-9)
    pcm = np.asarray(np.clip(stereo, -1.0, 1.0) * 32767.0, dtype="<i2")

    OUTPUT.parent.mkdir(parents=True, exist_ok=True)
    with wave.open(str(OUTPUT), "wb") as wav:
        wav.setnchannels(2)
        wav.setsampwidth(2)
        wav.setframerate(SAMPLE_RATE)
        wav.writeframes(pcm.tobytes())

    seam = float(np.max(np.abs(stereo[0] - stereo[-1])))
    print(f"rendered={OUTPUT}")
    print(f"duration={DURATION:.1f}s frames={FRAMES} peak_dbfs=-6.00 seam_delta={seam:.6f}")


if __name__ == "__main__":
    main()
