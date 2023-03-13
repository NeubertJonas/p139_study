# Working with Audio & Video Files

Python tools to (a) transcribe audio files into text via OpenAi's Whisper tool and (b) sync audio from an external microphone with a video recording with the help of Praat. All the code can be found in the _transcribe_ and _sync_ folders, respectively.
This README contains instructions on how to setup the Python environment in Microsoft's Visual Studio Code on Windows. Naturally, the code also works with other software and on other platforms. You just have to adapt the instructions slightly yourself.

## Prerequisites Overview

* Python 3.10.x
* Whisper package
* FFmpeg
* Praat*

\* Put _Praat.exe_ in the folder _sync_.

## Getting Python Ready

### Installing Everything

For the sake of simplicity, I recommend the use of the Chocolatey package manager (<https://chocolatey.org/>) on Windows (alternatives are available for other platforms). It allows for quick and easy installation of most prerequisites.
Please note that the most recent version of Python, which is 3.11.x, is not compatible with the Whisper package (or more precisily with PyTorch). If you already have Python installed, please check which version it is and install 3.10.x if necessary.

1. Install Chocolatey by opening an elevated PowerShell terminal (run as administrator) and executing this code. (For more info, see <https://chocolatey.org/install>: )

``` powershell
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
```

2. Close Powershell and open a new elevated terminal

3. Next, we're installing Python 3.10.x, FFmpeg, Git, and Visual Studio Code (VS Code). The latter is only a recommendation, other integrated development environments (IDEs) work as well. I'm also recommending to install GitHub and the GitHub extensions, so you can easily download the code from the repository and contribute to it.

``` powershell
choco install python310 ffmpeg vscode git vscode-pull-request-github
```

4. (Optional) There are a few useful extensions for Visual Studio Code, which make your life much easier when working with Python (or other languages). You can install them within VS Code itself.
I recommend the following extensions: Python, Pylance, Pylint, Code Runner, GitHub Copilot

### Downloading the Repository

1. Open VS Code and open the _Source Control_ panel on the left side of the window (or press Ctrl+Shift+G)
2. Click on the _Clone Repository_ button and paste the following URL: <https://github.com/NeubertJonas/hyperscanning.git>
3. Select an empty folder on your harddrive and then open the repository after the download is finished
4. All the Python code is located in the _audio\_video_ folder

### Virtual Environment

Next, we're setting up a virtual environment for the Python code. This is a folder which contains all the Python packages required for the code to run. It is independent from the system-wide Python installation and allows for easy installation and removal of packages. It also prevents conflicts between different projects.

1. Open the command palette (Ctrl+Shift+P) and type _Python: Create Environment_ and press Enter
2. Pick Venv (coda should work as well, but I haven't tested it)
3. Select Python 3.10.x as the interpreter
4. Do not select any requirements files (we'll install the packages later)

### Installing Packages

1. Open a new terminal in VS Code (Terminal > New Terminal)
2. It should automatically start the virtual environment. If not, type _.venv\Scripts\activate_ and press Enter
3. Finally, we'll update and install all required packages by running the following code in the terminal:

``` powershell
cd audio_video
py -m pip install --upgrade pip setuptools wheel
# Default packages (no GPU required)
py -m pip install -r requirements.txt
# # Do you have a CUDA-compatible GPU? (https://developer.nvidia.com/cuda-gpus)
# If yes, run the following line instead:
py -m pip install -r requirements_nvidia.txt
# If you wish to update the Whisper package later, run this:
pip install --upgrade --no-deps --force-reinstall git+https://github.com/openai/whisper.git
```

### Side Note

I am expecting that some of those steps might need to be adjusted to work on university commputers, because of their strict security settings. Something to try out later.

## Transcribing Audio

Whisper can be run as part of a Python script or via the terminal/command line (more info here: <https://github.com/openai/whisper>). The latter is much easier to use, so I recommend to use the command line interface for now.
(In the future a script might be useful for batch processing of multiple audio files.)

The basic command is:

``` powershell
whisper audiofile.mp3
# Define the language model
whisper audiofile.mp3 --model medium.en
# Make sure the terminal is in the correct folder by using the **cd** command
cd audio_video/transcribe/examples
# You can also analyse multiple files at once (in this case the included example files) and limit the output to a specific format
whisper abstract.mp3 emotional.mp3 --model medium.en --output_format txt
```

Whisper will then automatically detect the language and output the transcription in a few different text formats (in the same folder as the terminal).

There are more commands to customize the output (see link above), feel free to explore those. The first time you run the code, it will download the selected language model (~1.5 GB) and cache it here: %UserProfile%\.cache\whisper
This might take a while, but only needs to be done once.

### Audio Extraction

Whisper only works with audio files (.mp3, .wav, etc.), so audio extraction is required when working with video files. This can be easily achieved with software such as ffmpeg

``` powershell
ffmpeg input.mp4 output.mp3
```

## Syncing Audio and Video Recordings

When recording participants via iPad or webcam, the integrated microphone might offer subpar audio quality. In those cases audio can be seperatly recorded by an external microphone. Afterwards, the external recording should replace the other audio track. As the recording will not start at the exact same time, syncing the audio recordings is required.

### Recording Requirements

The first 30 seconds of both recordings are analysed in order to determine the audio offset (in ms). Thus, recordings have to be started roughly simultaneous. For the best results one should loudly clap after recordings were started (ideally, the hands are visible on video in case manual synchronization is necessary). The loud sound of the clap is a clear audio marker on both files which aids synchronization and represents best practice in video recording.

It does not matter whether video or audio recording is started first; The script can handle both cases.

### Additional Prerequisites

The script relies on the software _Praat_ (Dutch for "talk"), a linguistic tool for speech analysis developed by Paul Boersma and David Weenink of the University of Amsterdam (<https://www.fon.hum.uva.nl/praat/>). Please download the most recent version of Praat from the website or GitHub (<https://github.com/praat/praat/releases/latest>). Afterwards, unzip the file and place _Praat.exe_ in the sync folder. No further installation is necessary.

The script was last tested with version 6.3.08, released 10 February 2023, but should work with newer versions as well.

### Preperation

Copy the audio and video files you which to sync to the _media_ folder. No specific filenames are required, though using a standardized naming scheme is recommended. Maybe something like this: _CFO\_P04\_D2_ (Chain Free Association Task, participant 02, day 2).

### Running the Code

Run _sync.py_ in the terminal. The script will check if all prerequisites are met, ask for the filenames, and then output the new video file as _output.mp4_ in the media folder.

``` powershell
# Make sure the virtual environment is activated and the terminal is running in the "sync" folder
# Otherwise, use the "cd" command to navigate to this folder
python sync.py
```
