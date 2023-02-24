# Working with Audio & Video Files
Python tools to (a) transcribe audio files into text via OpenAi's Whisper tool and (b) sync audio from an external microphone with a video recording with the help of Praat. All the code can be found the _transcribe_ and _sync_ folders, respectively.
This README contains instructions on how to setup the Python environment in Microsoft's Visual Studio Code on Windows. Naturally, the code also works with other software and on other platforms. You just have to adapt the instructions slightly yourself.

# Prerequisites Overview
* Python 3.10.x
* Whisper
* FFmpeg
* Praat*

\* Put _Praat.exe_ in the folder _sync_.

# Getting Python Ready
## Installation
The ne of the packages for automatic transcription 
Python 3.10
## Virtual Environment

Optional: autopep8

## Side Note
I am expecting that some of those steps might need to be adjusted to work on university commputers, because of strict security settings. Something to try out later.

## Other Prerequisites
Both tools rely on FFmpeg, which is a free command-line audio and video encoder. On Windows, the easiest way to install FFmpeg is via the package manager Chocolatey (https://chocolatey.org).

1. Install Chocolatey by opening an elevated PowerShell terminal (run as administrator) and executing this code. (For more info, see https://chocolatey.org/install: )

``` powershell
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
```

2. Close Powershell and open a new elevated terminal
3. Install FFmpeg with this command:

``` powershell
choco install ffmpeg
```

4. Test if installation was succesful with

``` powershell
ffmpeg -version
```

The script was tested with version 5.1.2, but should work with newer versions as well.

# Transcribing Audio

# Syncing Audio and Video Recordings
When recording participants via iPad or webcam, the integrated microphone might offer subpar audio quality. In those cases audio can be seperatly recorded by an external microphone. Afterwards, the external recording should replace the other audio track. As the recording will not start at the exact same time, syncing the audio recordings is required.

## Recording Requirements
The first 30 seconds of both recordings are analysed in order to determine the audio offset (in ms). Thus, recordings have to be started roughly simultaneous. For the best results one should loudly clap after recordings were started (ideally, the hands are visible on video in case manual synchronization is necessary). The loud sound of the clap is a clear audio marker on both files which aids synchronization and represents best practice in video recording.

It does not matter whether video or audio recording is started first; The script can handle both cases.

## Additional Prerequisites
The script relies on the software _Praat_ (Dutch for "talk"), a linguistic tool for speech analysis developed by Paul Boersma and David Weenink of the University of Amsterdam (https://www.fon.hum.uva.nl/praat/). Please download the most recent version of Praat from the website or GitHub (https://github.com/praat/praat/releases/latest). Afterwards, unzip the file and place _Praat.exe_ in the sync folder. No further installation is necessary. 

The script was last tested with version 6.3.08, released 10 February 2023, but should work with newer versions as well.

## Preperation
Copy the audio and video files you which to sync to the _media_ folder. No specific filenames are required, though using a standardized naming scheme is recommended. Maybe something like this: _CFO\_P04\_D2_ (Chain Free Association Task, participant 02, day 2).

## Running the Code
Run _sync.py_ in the terminal. The script will check if all prerequisites are met, ask for the filenames, and then output the new video file as _output.mp4_ in the media folder.

``` powershell
# Make sure the virtual environment is activated and the terminal is running in the "sync" folder
# Otherwise, use the "cd" command to navigate to this folder
python sync.py
```