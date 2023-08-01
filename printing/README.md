# Label Print Questionnaires

For every acute testing day, a collection of paper questionnaires needs to be printed, sorted, and labelled. Previously, this entailed finding the correct Word or PDF files for all tasks, checking how many copies were needed, and then printing all of them. Afterwards, the 74 pages had to be manually sorted and labelled with subject IDs, study day, date, and iteration of task. Rather tedious work, which this Python script can luckily eliminate. The script will produce a single PDF containing all 74 labelled pages in the correct order. 

The file should then be printed single-sided prior to the testing day together with two CRFs and the blood labels.

## Requirements

- Python (tested with 3.11.4, but newer versions likely work as well)
  - [pypdf](https://pypi.org/project/pypdf/)
  - [reportlab](https://docs.reportlab.com)
- Prepared PDF files with standardized headers
  - print_per_participant_v4.pdf
  - print_per_testing_day_v2.pdf

## Installing

### Python

First, make sure you have Python installed on your system and added to your PATH environment. Easiest way to do this is via package managers. Instructions have been outlined [here](../README.md).
If you wish to make changes to the code, you can either fire up a regular text editor or work with an integrated development environment (IDE) such as Visual Studio Code. However, if you are just planning to execute the code to prepare PDFs for printing, then this is not necessary.

### Downloading Files 

Next, download the Python files from the repository. All you need is [add_labels.py](add_labels.py) and [requirements.txt](requirements.txt). If you open those files on GitHub, then you can find the download option in the menu with the three dots at the top-right.
![github-download](https://github.com/NeubertJonas/p139_study/assets/62346722/ea34f9b5-66b0-409b-adb8-caa3eaf457ff)

Place those two files in a new, empty folder on your computer. Copy the two prepared PDF files (listed above) from the rdm drive (04_Materials/Paper Questionnaires) to the folder, as well.

### Prepare the Virtual Environment

You only need to run the following steps once to setup everything.

Open a terminal/command line: In Windows, right-click within the folder and - while holding the Shift key - click "Open in Terminal". This opens an elevated terminal (i.e., running as administrator). This is only required the first time, because we need to change a security policy to allow execution of scripts. The path in the terminal should now be the newly created folder in which you placed all the files.

For Mac instructions on how to open a terminal, see [here](https://support.apple.com/en-gb/guide/terminal/trmlb20c7888/mac#:~:text=Open%20new%20Terminal%20windows%20or%20tabs%20from%20the%20Finder&text=Control-click%20the%20folder%20in,New%20Terminal%20Tab%20at%20Folder). _NB: The following instructions have not been tested on Mac OS, so you might encounter different errors or might have to adapt the commands slightly to the Mac-equivalent of PowerShell / Terminal._

Please execute the following commands individually by copying them and then pressing Enter.

Changing the security policy to allow scripts. Otherwise you will likely encounter an UnauthorizedAccess error.
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned
```

Check currently installed Python version (should be =>3.11.4):
```powershell
python -V
```

Setup new virtual environment. This also upgrade the `pip` and `setuptools` dependencies.
```powershell
python -m venv --upgrade-deps .venv
```

The virtual environment lives in the `.venv` folder and contains specific file paths. This means that copy-pasting the folder to a different location will break things. Instead re-create the virtual environment in a location if you need to move the folder.

Activate the virtual environment:
```powershell
.venv\Scripts\activate
```

Your terminal should now display a green `(.venv)` at the start of the line, indicating you are in the virtual environment. 
Install required packages:
```powershell
pip install -r requirements.txt
```

Check list of installed packages (should contain Pillow, pypdf, and reportlab):
```powershell
pip list
```

Congrats, now you're all set to execute the code and create some beautiful PDF files.

## Running the Script

The code is controlled via command-line interface (CLI), so there is no need for another software. Everything just takes place in the terminal we used earlier.

1. Open the terminal (no need for an elevated one anymore).
2. Activate the virtual environment

```powershell
.venv\Scripts\activate
```

3. Execute the script

```powershell
python add_labels.py
```

You will now be guided through the script by the terminal. You will be asked for subject IDs (just enter the final two digits, e.g., `01` and `02`), study day, and date. The code will take care of the rest and create the PDF in the folder. Just repeat for the next acute testing day.

Finally, it is a good habit to deactive the virtual environment you have been working in:

```powershell
deactivate
```

### Terminal Output:
![Terminal-printing](https://github.com/NeubertJonas/p139_study/assets/62346722/6a0be599-6a1c-41a4-b2f6-71fad0d051e9)



