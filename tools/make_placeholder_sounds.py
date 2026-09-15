"""Deterministic, synthesized placeholders. Python standard library only.

These are temporary audible cues for the owner to replace, not selected assets.
Output: 22050 Hz mono PCM16 WAV; no downloads, packages or conversion chain.
"""
from pathlib import Path
import math
import random
import struct
import wave

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / 'assets' / 'sound' / 'placeholders'
RATE = 22050
SPECS = {
    'shutter': .16, 'hover_hum': 2.0, 'cupcap_call': .62,
    'slatejaw_call': .95, 'spoolmite_call': .48, 'glarebell_call': 1.0,
    'veilfin_call': 1.1, 'construct_chime': .5,
    'pebble_impact': .18, 'food_impact': .16,
}


def sample(name, t, duration, rng):
    tau = math.tau
    env = math.sin(math.pi * min(1, t / duration)) ** .7
    if name == 'hover_hum':
        return .12 * (math.sin(tau*110*t) + .24*math.sin(tau*220*t))
    if name == 'shutter':
        return rng.uniform(-1, 1)*math.exp(-t*75)*.65 + math.sin(tau*1350*t)*math.exp(-t*35)*.24
    if name == 'cupcap_call':
        pulse = math.exp(-((t-.12)/.07)**2) + .7*math.exp(-((t-.36)/.08)**2)
        return .35*pulse*math.sin(tau*(330*t-90*t*t))
    if name == 'slatejaw_call':
        return env*(math.sin(tau*(65*t+48*t*t))*.25 + rng.uniform(-1, 1)*.14)*(0.8+.2*math.sin(tau*24*t))
    if name == 'spoolmite_call':
        return .25*env*max(0, math.sin(tau*13*t))*math.sin(tau*(900*t+380*t*t))
    if name == 'glarebell_call':
        return min(1,t*160)*math.exp(-t*4)*(.27*math.sin(tau*740*t)+.13*math.sin(tau*1488*t))
    if name == 'veilfin_call':
        return .19*env*math.sin(tau*(470*t+35*t*t)+.6*math.sin(tau*3*t))
    if name == 'construct_chime':
        return min(1,t*150)*math.exp(-t*7)*(.24*math.sin(tau*620*t)+.17*math.sin(tau*930*t))
    if name == 'pebble_impact':
        return math.exp(-t*45)*(.4*rng.uniform(-1,1)+.2*math.sin(tau*1800*t))
    return math.exp(-t*35)*(.22*rng.uniform(-1,1)+.12*math.sin(tau*150*t))


OUT.mkdir(parents=True, exist_ok=True)
for number, (name, duration) in enumerate(SPECS.items()):
    rng = random.Random(927 + number)
    samples = [int(max(-.98, min(.98, sample(name, i/RATE, duration, rng)))*32767)
               for i in range(round(RATE*duration))]
    with wave.open(str(OUT / (name+'.wav')), 'wb') as out:
        out.setnchannels(1)
        out.setsampwidth(2)
        out.setframerate(RATE)
        out.writeframes(struct.pack('<'+'h'*len(samples), *samples))
    print(f'placeholder {name}: {duration:.2f}s')
