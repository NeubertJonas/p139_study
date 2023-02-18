# This script was adapted from the Praat script published by The Bielefeld Dialogue Systems Group (Prof. David Schlangen)
# The original script, written by Spyros Kousidis, can be found here:
# http://www.dsg-bielefeld.de/dsg_wp/sync-your-videos-using-reference-audio/
# http://www.dsg-bielefeld.de/dsg_wp/wp-content/uploads/2014/10/video_syncing_fun.pdf

form Cross Correlate two Sounds
    sentence Input_sound_1
    sentence Input_sound_2
    real start_time 0
    real end_time 30
endform

Open long sound file... 'Input_sound_1$'
Extract part: 0, 30, "no"
Extract one channel... 1
sound1 = selected("Sound")
Open long sound file... 'input_sound_2$'
Extract part: 0, 30, "no"
Extract one channel... 1
sound2 = selected("Sound")

select sound1
plus sound2
Cross-correlate: "peak 0.99", "zero"
offset = Get time of maximum: 0, 0, "Sinc70"

writeInfoLine: 'offset'