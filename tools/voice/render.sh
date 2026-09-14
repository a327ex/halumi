#!/usr/bin/env bash
# The construct's voice. Renders every line in lines.txt to assets/voice/<id>.ogg
# with the voice the owner picked on 2026-09-14 ("cute3a"): Windows SAPI David,
# SSML pitch +45%, then the ffmpeg chain below. Change lines.txt, run this, done.
# Only lines whose ogg is missing or older than lines.txt are re-rendered (or all with --all).
# Requires: powershell (Windows), ffmpeg on PATH. Run from anywhere.
set -euo pipefail
here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
root="$(cd "$here/../.." && pwd)"
out="$root/assets/voice"
tmp="$here/.tmp"
mkdir -p "$out" "$tmp"
lines="$here/lines.txt"
force="${1:-}"
n=0
while IFS='|' read -r id text; do
  [[ -z "$id" || "$id" == \#* ]] && continue
  ogg="$out/$id.ogg"
  if [[ "$force" != "--all" && -f "$ogg" && "$ogg" -nt "$lines" ]]; then continue; fi
  wav="$tmp/$id.wav"
  powershell -NoProfile -ExecutionPolicy Bypass -File "$(cygpath -w "$here/tts.ps1")" \
    "Microsoft David Desktop" "+45%" "medium" "$(cygpath -w "$wav")" "$text"
  ffmpeg -y -loglevel error -i "$wav" \
    -af "asetrate=22050*1.25,aresample=22050,tremolo=f=24:d=0.12,highpass=f=250,lowpass=f=6000,acrusher=bits=11:mode=log:aa=1,volume=1.4" \
    "$ogg"
  rm -f "$wav"
  n=$((n + 1))
  echo "rendered $id"
done < "$lines"
echo "voice: $n line(s) rendered into assets/voice/"
