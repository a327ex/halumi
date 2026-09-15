# Sound selection needed

All ten non-voice cues currently use **synthesized placeholder WAVs**. They were
created locally by `tools/make_placeholder_sounds.py` using only Python's
standard library; no sourced samples, downloads or packages. Mono PCM16,
22050 Hz. The owner should choose the final sounds.

| ID | Needed sound |
|---|---|
| `shutter` | A brief dry crystalline click as light fixes onto a leaf; no modern camera motor. |
| `hover_hum` | Very quiet, seamless sustained levitation tone, soft enough to leave creature calls readable. |
| `cupcap_call` | A small hollow two-part gulp or coo, friendly and resonant like a wet cup. |
| `slatejaw_call` | A low rising scrape/rattle that makes the opening-jaw warning unmistakable. |
| `spoolmite_call` | A tiny quick snuffling chitter, distinct from the shutter. |
| `glarebell_call` | A brittle organic bell pulse that carries through the chamber. |
| `veilfin_call` | An unfamiliar faint breath/whistle; quiet, without a dramatic discovery sting. |
| `construct_chime` | A restrained two-note archive chime, only when Q requests an answer. |
| `pebble_impact` | One small stone tapping dressed stone, for the noise lure's landing. |
| `food_impact` | A soft dry pellet patter, clearly gentler than the pebble. |

Routing lives in `SOUND_DEFS` in `soundscape.lua`; set a definition's `path` and
`duration` when replacing it. Current paths are
`assets/sound/placeholders/<id>.wav`. Keep duration accurate: owned one-shot
handles are explicitly stopped after it, including in silent agent instances.
The hover is one reusable looping handle. Calls attenuate with distance and
require line of sight through the stone. There is no music.

The five existing construct voice clips and the owner's SAPI/ffmpeg chain are
unchanged. No new voice lines are required for this pass.

Engine limitation observed: APR serializes sound starts, but not later handle
loop/volume/pitch changes. The live game uses a proper continuous hover loop;
its sustained/moving mix is not faithfully reproduced by the current replay
codec. This pass does not change the engine.
