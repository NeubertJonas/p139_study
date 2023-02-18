"""Python module to sync audio and video files."""
from os import path
import subprocess
import requests


def run_cmd(*args):
    p = subprocess.Popen(
        *args,
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT
    )
    out, error = p.communicate()
    return out, error


ps_command = "& {{Start-Process cmd.exe -argumentlist 'ipconfig' -Verb Runas}}"
command = ['powershell.exe', '-command', ps_command]
run_cmd(command)


def check_praat():
    """""Check for Praat.exe"""
    if path.exists("Praat.exe"):
        print("Praat.exe found")
        return True
    else:
        print("Praat.exe not found")
        print("Download the latest version from https://github.com/praat/praat/releases")
        print("Extract the zip file and place Praat.exe in the same folder as this script")
        return False
        # TODO: Automate these steps


def check_ffmpeg():
    """""Check if ffmpeg is installed"""
    try:
        subprocess.run("ffm2peg", check=False, stdout=subprocess.DEVNULL)
        print("FFmpeg installed")
        return True
    except OSError:
        print("FFmpeg not installed")
        print("You can either run 'install_ffmpeg.ps1' as admin to automatically install it via the Chocolatey package manager or follow the instructions below.")
        print("https://www.wikihow.com/Install-FFmpeg-on-Windows")
        print("(The essentials version is sufficient for this script)")
        return False


def main():
    """""Main function"""
    if check_praat() and check_ffmpeg():
        print("All requirements met")
    else:
        print("Requirements not met")
        print("Please install the required software")
        exit()
    extract()
    sync()
    output()


runCmd(ipconfig)

# Important: Make sure the sampling rate is the same for both files
# If not, use ffmpeg to convert the audio file to the same sampling rate as the video file
# ffmpeg -i input.wav -ar 48k output.wav


# Instead:
# TODO: Figure out best setting for audio/video conversion via ffmpeg
subprocess.run(
    "ffmpeg -itsoffset 00:00:03.06 -i video.mp4 -i audio.wav -crf 18 -map 0:v -map 1 output.mp4")


def extract():
    ffmpeg = (
        FFmpeg()
        .option("y")
        .input("video.mp4")
        .output("output.wav", ar="48k")
    )
    ffmpeg.execute()


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


""" def export():
    xx """

if __name__ == "__main__":
    sync()

    replace()
