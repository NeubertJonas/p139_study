# P139

This repository contains an assortment of code written for the ongoing study P139 at Maastricht University. Every folder covers a different aspect of the study. They are generally independent from each other and, if necessary, contain their own README file with more detailed instructions.

## Prerequisites

Code is mostly written in R or Python. For this, I have been using [RStudio](https://posit.co/download/rstudio-desktop/) and [Visual Studio Code](https://code.visualstudio.com), respectively, but you can also use any other software you feel comfortable with. The R code has been tested with version 4.3.1, but I generally recommend to download the latest version from [here](https://cloud.r-project.org). The Python code runs on 3.11.4 and is expected to work with upcoming minor releases (e.g., 3.11.5 and so fourth) while other major releases (e.g., 3.10 or 3.12) might not work. You can download the latest version of Python from [here](https://www.python.org/downloads/).

### Optional: Installing via Package Manager

If you are looking for an easy way to install R and Python, I recommend using [Chocolatey](https://chocolatey.org) for Windows or [Homebrew](https://brew.sh) for macOS. Both are package managers that allow you to install software from the command line. For example, to install R on Windows, you can simply run `choco install r.project` in the command line. For macOS, you can run `brew install r` to install R. The same applies to Python. For Windows, you can run `choco install python311` and for macOS, you can run `brew install python@3.11`. If you are using Linux, you can use your distribution's package manager to install R and Python.

Rstudio and Visual Studio Code are available via package managers as well. For Windows, you can run `choco install rstudio` and for macOS, you can run `brew install --cask rstudio`. For Visual Studio Code, you can run `choco install vscode` on Windows and `brew install --cask visual-studio-code` on macOS.

## Overview

Below you can find an overview of all folders and their contents.

| Folder  | Description | Language |
| ------------- | ------------- |
| audio_video | Transcribe audio recordings and sync external audio with video recordings. | Python |
| CFA  | Chain Free Association Task. Determine seed words and data preparation for semantic distance analysis. | R |
| DAT  | Divergent Association Task.  Create matching seed words for two conditions. | R |
| P96 | Rearrange data from study P96. Alternative Uses Task. | R |
| printing | Automatically label all paper questionnaires for easier printing. | Python |
| qualtrics | Prepare and analyse data from Qualtrics. Specifically, concerning relationship metrics. | R |

## Contribution

If you have any questions or suggestions, feel free to open an issue or pull request.

## Download

You can either clone this repository or download it as ZIP file via the green "Code" button on the top-right.

### Social Preview

The image used for the social preview was generated by [Midjourney](https://www.midjourney.com/) (version 5.2).

![Social Preview. A romantic couple facing each other with closed eyes. Psychedelic background.](https://repository-images.githubusercontent.com/601310740/1f903274-04f6-4f6f-ac3c-f9406bec22e3)
