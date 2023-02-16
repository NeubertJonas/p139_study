import os
import subprocess
from ffmpeg import FFmpeg, Progress

# Important: Make sure the sampling rate is the same for both files
# If not, use ffmpeg to convert the audio file to the same sampling rate as the video file
# ffmpeg -i input.wav -ar 48k output.wav


def main():
    # extract()
    sync()


def extract():
    ffmpeg = (
        FFmpeg()
        .option("y")
        .input("video.mp4")
        .output("output.wav", ar="48k")
    )
    ffmpeg.execute()


def sync():
    result = subprocess.check_output("Praat.exe", "--run", "crosscorrelate.praat", "audio.wav", "output.wav")
    print(result)

# Best code so far:

result = subprocess.check_output(['Praat.exe', '--run', 'crosscorrelate.praat', 'audio.wav', 'output.wav', '0', '30'], shell=True) 
result = float(result.split()[0].replace("\x00",""))

# And then: for negative offset (external audio is ahead)
# ffmpeg -itsoffset 00:00:03 -i video.mp4 -i audio.wav -map 0:v -map 1 output.mp4

# for positive offset (external audio is behind)
# ffmpeg -i video.mp4 -itsoffset 00:00:03 -i audio.wav -map 0:v -map 1 output.mp4
# See here: https://trac.ffmpeg.org/wiki/Map
# And here: http://howto-pages.org/ffmpeg/#delay

result = subprocess.check_output(['Praat.exe', '--run', 'crosscorrelate.praat', 'audio.wav', 'output.mp3'], shell=True, text=True)
result = subprocess.run(['Praat.exe', '--run', 'crosscorrelate.praat', 'audio.wav', 'output.wav'], check=True, capture_output=True).stdout
print(result)


""" def export():
    xx """

if __name__ == "__main__":
    sync()

    replace()