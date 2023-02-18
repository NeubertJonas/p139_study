"""Python module to sync audio and video files."""
import os
from os import path
import subprocess
import requests


def main():
    """""Main function"""
    if check_praat() and check_ffmpeg():
        print("All requirements met")
    else:
        print("Requirements not met")
        print("Please install the required software and try again")
        exit()

    sync()


def check_praat():
    """""Check for Praat.exe"""
    if path.exists("Praat.exe"):
        print("Praat.exe found")
        return True
    else:
        print("ERROR: Praat.exe not found")
        print("Download the latest version from https://github.com/praat/praat/releases")
        print("Extract the zip file and place Praat.exe in the same folder as this script")
        return False
        # TODO: Automate these steps


def check_ffmpeg():
    """""Check if ffmpeg is installed"""
    try:
        subprocess.run("ffmpeg", check=False,
                       stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
        print("FFmpeg installed")
        return True
    except OSError:
        print("ERROR: FFmpeg not installed")
        print("Would you like to receive instructions on how to install? (on Windows)")
        instructions = input(
            "Press 'y' to continue or any other key to exit: ")
        if instructions == "y":
            print(
                "\nThe easiest way is to utilize Chocolatey, a package manager for Windows.")
            print("1. Open an elavated PowerShell prompt (run as administrator)")
            print("2. Run the following command to install Chocolatey:")
            print(
                "Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))")
            print("For more info, see here: https://chocolatey.org/install")
            print("3. Close PowerShell and open a new elavated PowerShell prompt.")
            print("4. Run the following command:")
            print("choco install ffmpeg\n")
        return False


def sync():
    """""Sync audio and video files"""

    print("Have you copied the audio and video file to the media folder?")
    print("Please enter the name of the video file (including extension)")
    video = "media/" + input("Video file: ")
    print("Please enter the name of the audio file (including extension)")
    audio = "media/" + input("Audio file: ")

    # Compare audio streams
    subprocess.run(
        f"ffmpeg -i {video} -ar 48k media/temp_audio.wav", shell=True, check=True)
    offset = compare(audio)
    os.remove("media/temp_audio.wav")

    if offset[0] == "-":
        offset = offset[1:]
        subprocess.run(
            f"ffmpeg -itsoffset 00:00:{offset[0:5]} -i {video} -i {audio} -crf 18 -map 0:v -map 1 media/output.mp4", shell=True, check=True)
        # Audio starts first and video second (i.e., video is delayed)
    else:
        offset = float(offset[0:7])
        offset = int(offset * 1000)
        print(offset)
        subprocess.run(
            f"ffmpeg -i {video} -i {audio} -af adelay=\"{offset}|{offset}\" -crf 18 -map 0:v -map 1 media/output.mp4", shell=True, check=True)
        # Video starts first and audio second (i.e., audio is delayed)


def compare(audio):
    """Run Praat script to determine offset"""

    # Important: Make sure the sampling rate is the same for both files
    # If not, use ffmpeg to convert the audio file to the same sampling rate as the video file
    # Webcam (EEG lab): 48kHz
    # iPad: 44.1kHz
    # ffmpeg -i input.wav -ar 48k output.wav
    # TODO: Compare sampling rates of audio files and convert if necessary
    # Not sure how to determine sampling rate without relying on more packages
    # So instead I'll just convert to 48khz every time and hope for the best (see line 70)
    # Converting every time when extracting from video
    # Because Roland is always recording at 48k

    result = subprocess.run(f"Praat.exe --run crosscorrelate.praat {audio} media/temp_audio.wav 0 30",
                            capture_output=True, check=True, encoding="utf-8")

    result = result.stdout
    result = result.replace("\x00", "")
    return (result)


# TODO: Figure out best setting for audio/video conversion via ffmpeg. (uUse -crf 18 for now)

# Old code:
""" 
subprocess.run(
    "ffmpeg -itsoffset 00:00:03.06 -i video.mp4 -i audio.wav -crf 18 -map 0:v -map 1 output.mp4")


def sync():
    result = subprocess.check_output(
        "Praat.exe", "--run", "crosscorrelate.praat", "audio.wav", "output.wav")
    print(result)

# Best code so far:


result = subprocess.check_output(
    ['Praat.exe', '--run', 'crosscorrelate.praat', 'audio.wav', 'output.wav', '0', '30'], shell=True)
result = float(result.split()[0].replace("\x00", ""))


# Better code:


# result = subprocess.check_output(['Praat.exe', '--run', 'crosscorrelate.praat', 'audio.wav', 'output.wav', '0', '30'], shell=True)


output = subprocess.run("Praat.exe --run crosscorrelate.praat audio.wav output.wav 0 30",
                        capture_output=True, encoding="utf-8")
print('###############')
print('Return code:', output.returncode)
# use decode function to convert to string
# print('Output:',output.stdout.decode("utf-8"))
print('Output:', output.stdout)


offset = output.stdout
offset = offset.replace("\x00", "")
print(offset)

# Determine if the offset is negative or positive
if offset[0] == "-":
    offset = offset[1:]
    print("Negative offset")
else:
    print("Positive offset")


print(offset)

float = float(offset)

print(float)

# print(offset.decode("utf-8"))
print(float(offset).encode("utf-8"))

offset = output.stdout.decode("utf-8")

offset = int(offset) + 1

output = codecs.getwriter('utf-8')(sys.stdout.buffer)

# offset = float(offset)
int(offset)
print(type(string))
print(offset)


# And then: for negative offset (external audio is ahead)
# ffmpeg -itsoffset 00:00:03.06 -i video.mp4 -i audio.wav -map 0:v -map 1 output.mp4

# for positive offset (external audio is behind)
# ffmpeg -i video.mp4 -itsoffset 00:00:03.06 -i audio.wav -map 0:v -map 1 output.mp4
# See here: https://trac.ffmpeg.org/wiki/Map
# And here: http://howto-pages.org/ffmpeg/#delay

result = subprocess.check_output(
    ['Praat.exe', '--run', 'crosscorrelate.praat', 'audio.wav', 'output.mp3'], shell=True, text=True)
result = subprocess.run(['Praat.exe', '--run', 'crosscorrelate.praat',
                        'audio.wav', 'output.wav'], check=True, capture_output=True).stdout
print(result)



    """
# Old code end.

if __name__ == "__main__":
    main()
