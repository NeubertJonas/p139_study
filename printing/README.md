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

First, make sure you have Python installed on your system and added to your PATH environment. Easiest way to do this is via package managers. Instructions have been outlined [here](./README.md).
If you wish to make changes to the code, you can either fire up a regular text editor or work with an integrated development environment (IDE) such as Visual Studio Code. However, if you are just planning to execute the code to prepare PDFs for printing, then this is not necessary.

Next, download the Python files from the repository. For your convenience, I have prepared a zip file with the required files. You can find it under releases [here](https://github.com/NeubertJonas/p139_study/releases/). (Of course, you can also just clone or download the entire repository.)

Afterwards, unzip the file in a new folder. Copy the two prepared PDF files (listed above) from the rdm drive (04_Materials/Paper Questionnaires) to the folder, as well.

Open a terminal/command line: In Windows, right-click within the folder and "Open in Terminal". For Mac instructions, see [here](Instructions for Mac)(https://support.apple.com/en-gb/guide/terminal/trmlb20c7888/mac#:~:text=Open%20new%20Terminal%20windows%20or%20tabs%20from%20the%20Finder&text=Control-click%20the%20folder%20in,New%20Terminal%20Tab%20at%20Folder). The path in the terminal should now be the newly created folder in which you placed all the files.

_The following instructions have not been tested on Mac OS yet. Please check if instructions should be updated for Mac_

In the terminal, you can type `python -V` to check which version you have installed. We need a few more packages for Python for the code. You can either install them directly (meaning they will be available throughout your system) or create a virtual environment specifically for this project (I would recommend this to keep things seperate).

Setup new virtual environment
`python -m venv --upgrade-deps .venv`
Activate the virtual environment
`.venv\Scripts\activate`
Install required packages
`pip install -r requirements.txt`
Check list of installed packages (should contain Pillow, pypdf, and reportlab)
`pip list`

Congrats, now you're all set to execute the code and create some beautiful PDF files.

## Running the Script

The code is controlled via command-line interface (CLI), so there is no need for another software. Everything just takes place in the terminal we used earlier.
First, make sure your terminal is in the correct folder and the virtual environment is activated (see above).

Then, just run the following to execute the code: `python add_labels.py`
You will be asked for subject IDs, study day, and date. The code will take care of the rest and create the PDF in the folder. Just repeat for the next acute testing day.
