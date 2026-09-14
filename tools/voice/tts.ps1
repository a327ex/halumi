# Renders one line with a Windows SAPI voice to a wav. Called by render.sh; do not call by hand.
param($voice, $pitch, $rate, $out, $text)
Add-Type -AssemblyName System.Speech
$s = New-Object System.Speech.Synthesis.SpeechSynthesizer
$s.SelectVoice($voice)
$s.SetOutputToWaveFile($out)
$esc = [System.Security.SecurityElement]::Escape($text)
$ssml = "<speak version='1.0' xmlns='http://www.w3.org/2001/10/synthesis' xml:lang='en-US'><prosody pitch='$pitch' rate='$rate'>$esc</prosody></speak>"
$s.SpeakSsml($ssml)
$s.Dispose()
