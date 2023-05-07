"""This script adds the participant ID, day, and date to the header of print questionnaires.

The resulting PDF contains all pages, which need to be printed as preparation
for the acute testing day, with the exception of labels for blood samples.

"""

# When running the script for the first time, 
# run "pip install -r requirements.txt" in the terminal.

# Import packages

import os
import sys
from pathlib import Path
from typing import Union, Literal, List

from reportlab.pdfgen import canvas
from reportlab.lib.units import mm
from reportlab.lib.pagesizes import A4, landscape

from pypdf import PdfWriter, PdfReader, PdfMerger

# pylint: disable=C0103

# Define variables

id_1 = input("Enter the first participant ID: P139")
id_1 = "P139"+id_1
id_2 = input("Enter the second participant ID: P139")
id_2 = "P139"+id_2

day = ""
while day != "1" and day != "2":
    day = input("First or second acute testing day? [1/2]: ")

    if day != "1" and day != "2":
        print("Invalid input. Please enter 1 or 2.")

    if day == "1":
        day = "A1"
        break
    elif day == "2":
        day = "A3"
        break

date = input("Enter the date (e.g., 19.04.1943): ")
output = "print_"+id_1+"+"+id_2+"_"+day+".pdf"

# Define page ranges
# Enter page numbers for IOS and handout
# The rest uses the default portrait header

ios = [2, 7, 17, 19, 26, 30, 33]
handout = [34]
portrait = list(range(0, 35))
portrait = [x for x in portrait if x not in ios and x not in handout]


# Define temporary file names

portrait_tmp = "portrait_tmp.pdf"
ios_tmp = "ios_tmp.pdf"
handout_tmp = "handout_tmp.pdf"

# Check if all required files exist

per_participant = "print_per_participant_TD_v4.pdf"
per_day = "print_per_testing_day_v2.pdf"


try:
    open(per_participant)
except FileNotFoundError:
    print("Error! Cannot find "+per_participant)
    print("Add this file to the script directory and try again.")
    sys.exit(1)

try:
    open(per_day)
except FileNotFoundError:
    print("Error! Cannot find "+per_day)
    print("Add this file to the script directory and try again.")
 #   sys.exit(1)


# Functions

## Create header PDFs

def header_portrait(id):
    """Create a PDF with the header for portrait pages."""
    pdf = canvas.Canvas(portrait_tmp, pagesize=A4)
    pdf.setFont("Courier-Bold", 12)
    pdf.drawString(46*mm, 279.5*mm, id)
    pdf.drawString(98*mm, 279.5*mm, day)
    pdf.setFont("Courier-Bold", 10)
    pdf.drawString(137.5*mm, 279.5*mm, date)
    pdf.save()


def header_ios(id):
    """Create a PDF with the header for landscape pages, namely the IOS."""
    pdf = canvas.Canvas(ios_tmp, pagesize=landscape(A4))
    pdf.setFont("Courier-Bold", 12)
    pdf.drawString(87*mm, 196.5*mm, id)
    pdf.drawString(141*mm, 196.5*mm, day)
    pdf.setFont("Courier-Bold", 10)
    pdf.drawString(180*mm, 196.5*mm, date)
    pdf.save()


def id_handout(id):
    """Create a PDF with the participant ID for the handout."""
    pdf = canvas.Canvas(handout_tmp, pagesize=A4)
    pdf.setFont("Courier-Bold", 26)
    pdf.drawString(90.5*mm, 245.3*mm, id[-2:])
    pdf.save()



# TODO: Combine header_pdf and content_pdf

def header(
    content_pdf: Path,
    header_pdf: Path,
    result_pdf: Path,
    page_indices: Union[Literal["ALL"], List[int]] = "ALL",
):
    header_page = PdfReader(header_pdf).pages[0]
    writer = PdfWriter()
    reader = PdfReader(content_pdf)

    if page_indices == "ALL":
        page_indices = list(range(0, len(reader.pages)))

    for index in page_indices:
        content_page = reader.pages[index]
        content_page.merge_page(header_page)
        writer.add_page(content_page)

    with open(result_pdf, "wb") as fp:
        writer.write(fp)






def combine_pages(id):
    """ Combine the output from header_ios(), header_portrait(), and id_handout() into one PDF.
    """

    header_portrait(id)
    header_ios(id)
    id_handout(id)

    header(per_participant, portrait_tmp, portrait_tmp, portrait)
    header(per_participant, ios_tmp, ios_tmp, ios)
    header(per_participant, handout_tmp, handout_tmp, handout)

    portrait_pdf = PdfReader(portrait_tmp)
    ios_pdf = PdfReader(ios_tmp)
    handout_pdf = PdfReader(handout_tmp)

    merger = PdfMerger()
    merger.append(portrait_pdf)

    p = 0
    for i in ios:
        merger.merge(i, ios_pdf, pages=(p, p+1))
        p = p + 1

    merger.append(handout_pdf)

    # return merger

    # merger.write(output+id+".pdf")
    output_tmp = "tmp_"+id+".pdf"
    merger.write(output_tmp)
    merger.close()

    os.remove(portrait_tmp)
    os.remove(ios_tmp)
    os.remove(handout_tmp)

    return output_tmp


def combine_participants():
    """ Combine the output from combine_pages() into one PDF.
    """

    first = combine_pages(id_1)
    second = combine_pages(id_2)

    both = PdfMerger()
    both.append(first)
    both.append(second)

    both.write(output)

    both.close()

    os.remove(first)
    os.remove(second)


# header(per_participant, portrait_tmp, portrait_tmp, portrait)
# header(per_participant, ios_tmp, ios_tmp, ios)
# header(per_participant, handout_tmp, handout_tmp, handout)

# sort_pages()

combine_participants()
#combine_pages(id_1)
#combine_pages(id_2)

# header("print_per_participant_TD_v4.pdf", portrait_tmp, "portrait.pdf", portrait)
# header("print_per_participant_TD_v4.pdf", "header_l.pdf", "ios.pdf", ios_pages)
# header("print_per_participant_TD_v4.pdf", "handout.pdf", "final_handout.pdf", handout_page)

# sort_pages()
# clean_up()

