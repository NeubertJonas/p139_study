"""This script adds the participant ID, day, and date to the header of print questionnaires.

The resulting PDF contains all pages, which need to be printed as preparation
for the acute testing day, with the exception of labels for blood samples and the CRF.

When running the script for the first time,
run "pip install -r requirements.txt" in the terminal.
"""


# Import packages

import sys
import os

from pathlib import Path
from typing import Union, Literal, List

from reportlab.pdfgen import canvas
from reportlab.lib.units import mm
from reportlab.lib.pagesizes import A4, landscape

from pypdf import PdfWriter, PdfReader, PdfMerger
from variables import *  # pylint: disable=W0401
# pylint: disable=C0103


def header_portrait(ID):
    """Create a temp. PDF with the header for portrait pages."""

    pdf = canvas.Canvas(portrait_tmp, pagesize=A4)
    pdf.setFont("Courier-Bold", 12)
    pdf.drawString(46*mm, 279.5*mm, ID)
    pdf.drawString(98*mm, 279.5*mm, day)
    pdf.setFont("Courier-Bold", 10)
    pdf.drawString(137.5*mm, 279.5*mm, date)
    pdf.save()


def header_ios(ID):
    """Create a temp. PDF with the header for landscape pages, namely the IOS."""

    pdf = canvas.Canvas(ios_tmp, pagesize=landscape(A4))
    pdf.setFont("Courier-Bold", 12)
    pdf.drawString(87*mm, 196.5*mm, ID)
    pdf.drawString(141*mm, 196.5*mm, day)
    pdf.setFont("Courier-Bold", 10)
    pdf.drawString(180*mm, 196.5*mm, date)
    pdf.save()


def header_couple():
    """Create a temp. PDF with the header for portrait pages, but with two IDs."""

    pdf = canvas.Canvas(couple_tmp, pagesize=A4)
    pdf.setFont("Courier-Bold", 12)
    pdf.drawString(98*mm, 279.5*mm, day)
    pdf.setFont("Courier-Bold", 10)
    pdf.drawString(137.5*mm, 279.5*mm, date)
    ID = ID_1+" & "+ID_2
    pdf.drawString(41*mm, 279.5*mm, ID)
    pdf.save()


def id_handout(ID):
    """Create a temp. PDF with the participant ID for the handout."""

    pdf = canvas.Canvas(handout_tmp, pagesize=A4)
    pdf.setFont("Courier-Bold", 26)
    pdf.drawString(90.5*mm, 245.3*mm, ID[-2:])
    pdf.save()


def header(
    content_pdf: Path,
    header_pdf: Path,
    page_indices: Union[Literal["ALL"], List[int]] = "ALL",
):
    """Merge temporary PDFs with the paper questionnaires."""
    header_page = PdfReader(header_pdf).pages[0]
    writer = PdfWriter()
    reader = PdfReader(content_pdf)

    if page_indices == "ALL":
        page_indices = list(range(0, len(reader.pages)))

    for index in page_indices:
        content_page = reader.pages[index]
        content_page.merge_page(header_page)
        writer.add_page(content_page)

    with open(header_pdf, "wb") as fp:
        writer.write(fp)


def combine_pages(ID):
    """ Combine the output from header_ios(), header_portrait(), and id_handout() into one PDF. 
    This function creates the PDF for one participant, so it needs to be run twice
    The output is saved as tmp_ID.pdf. This file is then merged with the output from the other participant"""

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

    # Place the IOS pages in the correct location
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
    """ Label header for the per_testing_day_v2.pdf documents.
    These are the paper questionnaire, which are shared between both participants
    and contain both subject IDs"""

    header_couple()
    header(per_day, couple_tmp, "ALL")

    return couple_tmp


def main():
    """ Combine the output from combine_pages() plus the shared pages into one final PDF. """

    final = PdfMerger()

    files = [combine_pages(ID_1), combine_pages(ID_2), shared_pages()]
    for f in files:
        final.append(f)

    final.write(output)
    final.close()

    print("Done! Created a pre-labelled PDF for "+ID_1+" and "+ID_2)
    if day == "A1":
        print("Their first testing day is on "+date)
    elif day == "A3":
        print("Their second testing day is on "+date)
    print("\nThe PDF is saved as "+output+"\n")
    print("NB: Please print it single-sided.")
    print("It contains everything you need for the testing days, except for the CRF and the labels for the blood samples.")
    print("The order of the pages follows the schedule of the testing day.")


def clean_up():
    """Delete temporary files from previous runs of the script."""
    files = [f for f in os.listdir('.')
         if os.path.isfile(f)]
   
    for f in files:
        if f.startswith('tmp_') and f.endswith('.pdf'):
            os.remove(f)


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

    clean_up()
