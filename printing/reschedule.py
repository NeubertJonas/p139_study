"""In case paper questionnaires had been printed but the testing day was cancelled, this script updates the study date.

The old date will be crossed out with "#" and the new date will be added below.

Insert the paper questionnaires into the printer in the exact order as they were printed before.
(Otherwise, the text will not align because of the difference in landscape vs portrait mode)

TODO: Clean up the code
TODO: Adjust instructions (ID and day could be removed)

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

from variables import *  # pylint: disable=W0401

# pylint: disable=C0103

# Functions

# Create header PDFs

def header_portrait(ID):
    """Create a PDF with the header for portrait pages."""
    pdf = canvas.Canvas(portrait_tmp, pagesize=A4)
    # pdf.setFont("Courier-Bold", 12)
    # pdf.drawString(46*mm, 279.5*mm, ID)
    # pdf.drawString(98*mm, 279.5*mm, day)

    # Cross-out cancelled date
    pdf.setFont("Courier-Bold", 10)
    pdf.drawString(137.5*mm, 279.5*mm, "##########")
    # Add new date below
    pdf.setFont("Courier-Bold", 10)
    pdf.drawString(137.5*mm, 273*mm, date)
    pdf.save()


def header_ios(ID):
    """Create a PDF with the header for landscape pages, namely the IOS."""
    pdf = canvas.Canvas(ios_tmp, pagesize=landscape(A4))
    # pdf.setFont("Courier-Bold", 12)
    # pdf.drawString(87*mm, 196.5*mm, ID)
    # pdf.drawString(141*mm, 196.5*mm, day)
    pdf.setFont("Courier-Bold", 10)
    pdf.drawString(180*mm, 196.5*mm, "##########")
    pdf.setFont("Courier-Bold", 10)
    pdf.drawString(180*mm, 190*mm, date)
    pdf.save()


def id_handout(ID):
    """Create a PDF with the participant ID for the handout."""
    pdf = canvas.Canvas(handout_tmp, pagesize=A4)
    pdf.setFont("Courier-Bold", 26)
    # pdf.drawString(90.5*mm, 245.3*mm, ID[-2:])
    pdf.save()


def header_couple():
    """Create a PDF with the header for portrait pages."""
    pdf = canvas.Canvas(couple_tmp, pagesize=A4)
    # pdf.setFont("Courier-Bold", 12)
    # pdf.drawString(98*mm, 279.5*mm, day)
    pdf.setFont("Courier-Bold", 10)
    pdf.drawString(137.5*mm, 279.5*mm, "##########")
    pdf.setFont("Courier-Bold", 10)
    pdf.drawString(137.5*mm, 273*mm, date)
    # ID = ID_1+" & "+ID_2
    # pdf.drawString(41*mm, 279.5*mm, ID)
    pdf.save()


def header(
    content_pdf: Path,
    header_pdf: Path,
    page_indices: Union[Literal["ALL"], List[int]] = "ALL",
):
    """Label the header with subject ID, study day, and date. """
    header_page = PdfReader(header_pdf).pages[0]
    writer = PdfWriter()
    reader = PdfReader(content_pdf)

    if page_indices == "ALL":
        page_indices = list(range(0, len(reader.pages)))

    for index in page_indices:
        # content_page = reader.pages[index]
        # content_page.merge_page(header_page)
        writer.add_page(header_page)

    with open(header_pdf, "wb") as fp:
        writer.write(fp)


def combine_pages(ID):
    """ Combine the output from header_ios(), header_portrait(), and id_handout() into one PDF. """

    
    header_portrait(ID)
    header_ios(ID)
    id_handout(ID)

    header(per_participant, portrait_tmp, portrait)
    header(per_participant, ios_tmp, ios)
    header(per_participant, handout_tmp, handout)

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

    output_tmp = "tmp_"+ID+".pdf"
    merger.write(output_tmp)
    merger.close()

    # Cleaning up temporary files
    os.remove(portrait_tmp)
    os.remove(ios_tmp)
    os.remove(handout_tmp)

    return output_tmp


def shared_pages():
    """ Label header for the per_testing_day_v2.pdf documents. """

    header_couple()

    header(per_day, couple_tmp, "ALL")

    return couple_tmp


def main():
    """ Combine the output from combine_pages() into one PDF and add the shared pages. """

    first = combine_pages(ID_1)
    second = combine_pages(ID_2)
    couple = shared_pages()

    both = PdfMerger()
    both.append(first)
    both.append(second)
    both.append(couple)

    both.write("rescheduled_"+output)

    both.close()

    print("Done! Created a pre-labelled PDF for "+ID_1+" and "+ID_2)
    if day == "A1":
        print("Their first testing day is on "+date)
    elif day == "A3":
        print("Their second testing day is on "+date)
    print("\nThe PDF is saved as "+output+"\n")
    print("NB: Please print it single-sided.\nIt contains everything you need for the testing days, except for the CRF and the labels for the blood samples.")
    print("The order of the pages follows the schedule of the testing day.")
    # Cleaning up temporary files
    os.remove(first)
    os.remove(second)
    os.remove(couple)


if __name__ == "__main__":

    # Check if all required files exist
    try:
        open(per_participant, encoding="utf-8")
    except FileNotFoundError:
        print("Error! Cannot find "+per_participant)
        print("Add this file to the script directory and try again.")
        sys.exit(1)

    try:
        open(per_day, encoding="utf-8")
    except FileNotFoundError:
        print("Error! Cannot find "+per_day)
        print("Add this file to the script directory and try again.")
        sys.exit(1)

    print("Labelling all paper questionnaires now...\n")
    # Run the script to create a single PDF for printing

    main()
