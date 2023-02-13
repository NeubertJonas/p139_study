# How to setup OpenAI's Whisper on VSC
*Last update: 22.01.2022*

Required Python version: 3.9.9 (recommended); 3.9.13 (works as well); newer versions are not supported  
Make sure to select 3.9.13 in the bottom right.

*Optional: install extensions: CodeRunner, Python, Pylance*

## Virtual Environment
 Create virtual environment in the workspace (folder) by going to the command palette (Ctrl+Shift+P)\
 Setup with Python 3.9.13  
 run "Python -V" to confirm correct version in the terminal

## Install PyTorch
 Pick Cuda 11.7; Pip; Python
 Cuda is important for utilising the nVidia graphics card (RTX 3070)  
 See here: https://pytorch.org/get-started/locally/
 Current version: 1.13.1  
 Whisper works with 1.10.1 and above  
 Run this in terminal:

```powershell
pip3 install torch torchvision torchaudio --extra-index-url https://download.pytorch.org/whl/cu117
```

Check via "pip list" if the cuda version for torch was properly installed. 
Should be something like: torch: 1.13.1+cu117

Could take a while, since the files are rather large
Dependencies will be installed automatically

## Install other prerequisites:

```powershell
pip install wheel
```


## Download Whisper (+ dependencies) with this code:

```powershell
pip install git+https://github.com/openai/whisper.git 
```

To update run this:

```powershell
pip install --upgrade --no-deps --force-reinstall git+https://github.com/openai/whisper.git
```

Last version installed: openai-whisper: 20230117

## Python code
More here: https://github.com/openai/whisper

```python
import whisper

model = whisper.load_model("small")
result = model.transcribe("C:/Users/jonaz/Programming/python/whisper/audio/test.mp3")
print(result["text"])
```

Terminal (make sure to be in the right folder with "cd")

```powershell
whisper test.mp3 --model medium.en
```

Whisper only works with audio files (.mp3, .wav, etc.), so audio extraction is required when working with video files.
This can be easily achieved with software such as ffmpeg

```powershell
ffmpeg input.mp4 output.mp3
```

# Location of downloaded language models:

```
C:\Users\jonaz\.cache\whisper
```
