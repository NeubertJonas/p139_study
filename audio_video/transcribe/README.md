# How to setup OpenAI's Whisper on VSC

Required Python version: 3.9.9 (recommended); 3.9.13 (works as well); newer versions are not supported\
Make sure to select 3.9.13 in the bottom right.

*Optional: install extensions: CodeRunner, Python, Pylance*

## In PowerShell or Terminal
Housekeeping: Just upgrade pip via administrator terminal.


First some housekeeping on a fresh installation of python. Make sure pip and setuptool are up-to-date.
And then install the wheel package (required for installing some of the packages)
``` powershell
pip list --outdated
python -m pip install --upgrade pip
pip install setuptools --upgrade
pip install wheel
```
## FFmpeg

Install FFmpeg. Easiest way to do this is via the chocolatey package manager. 

## Virtual Environment

Setup virtual environment, update essential packages

``` powershell
py -m pip install --upgrade pip setuptools wheel
py -m pip install -r requirements.txt
# If you have a compatible nVidia GPU:
py -m pip install -r requirements_nvidia.txt
```

Create virtual environment in the workspace (folder) by going to the command palette (Ctrl+Shift+P)\
Setup with Python 3.9.13\
run "Python -V" to confirm correct version in the terminal
Visual Studio Code will offer you to use a requirements file to automatically install packages.
Pick "requirements_nvidia.txt" if you have a compatible nVidia GPU, which allows for much faster
transcription via nVidia's CUDA cores. Have a look here to check if your GPU is compatible:
TODO: Add link.
Otherwise, use "requirements.txt"

The most recent version of Whisper will be installed. This also includes PyTorch and a few other packages.

The included settings.json in the .vscode folder tells VSC to automatically run the virtual environment in the terminal. Open a new terminal and you should see (.venv) at the beginning of each command. Run "pip list" to see the list of installed packages.

## Install PyTorch

Pick Cuda 11.7; Pip; Python Cuda is important for utilising the nVidia graphics card (RTX 3070)\
See here: <https://pytorch.org/get-started/locally/> Current version: 1.13.1\
Whisper works with 1.10.1 and above\
Run this in terminal:

``` powershell
pip3 install torch torchvision torchaudio --extra-index-url https://download.pytorch.org/whl/cu117
```

Check via "pip list" if the cuda version for torch was properly installed. Should be something like: torch: 1.13.1+cu117

Could take a while, since the files are rather large Dependencies will be installed automatically

## Install other prerequisites:

``` powershell
pip install wheel
```

## Download Whisper (+ dependencies) with this code:

``` powershell
pip install git+https://github.com/openai/whisper.git 
```

To update run this:

``` powershell
pip install --upgrade --no-deps --force-reinstall git+https://github.com/openai/whisper.git
```

Last version installed: openai-whisper: 20230117

## Python code

More here: <https://github.com/openai/whisper>

``` python
import whisper

model = whisper.load_model("small")
result = model.transcribe("C:/Users/jonaz/Programming/python/whisper/audio/test.mp3")
print(result["text"])
```

Terminal (make sure to be in the right folder with "cd")

``` powershell
whisper test.mp3 --model medium.en
```

Whisper only works with audio files (.mp3, .wav, etc.), so audio extraction is required when working with video files. This can be easily achieved with software such as ffmpeg

``` powershell
ffmpeg input.mp4 output.mp3
```

# Location of downloaded language models:

    C:\Users\jonaz\.cache\whisper
    
# *TODO*
- Add example files (audio, video, text output)
- Explain which PyTorch to pick
