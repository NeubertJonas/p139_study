import os
from pathlib import Path
from typing import Union, Literal, List

from reportlab.pdfgen import canvas
from reportlab.lib.units import mm, cm
# from reportlab.lib import colors
from reportlab.lib.pagesizes import A4

from pypdf import PdfWriter, PdfReader, PdfMerger, Transformation

# subject = input("Enter the subject code here:")
subject = "P13910"

# only get the last two characters of the subject code

day = "A1"
date = "12.05.2023"
output = "print_"+subject+"_"+day+".pdf"


ios_pages = [2, 7, 17, 19, 26, 30, 33]
handout_page = [34]
portrait_pages = [0, 1, 3, 4, 5, 6, 8, 9, 10, 11, 12, 13, 14, 15,
                   16, 18, 20, 21, 22, 23, 24, 25, 27, 28, 29, 31, 32]


def header_portrait():
    pdf = canvas.Canvas("header_p.pdf", pagesize=A4)
 #   pdf.translate(cm, cm)
#    pdf.setFillColor(colors.grey, alpha=0.6)
    pdf.setFont("Courier-Bold", 12)
    pdf.drawString(46*mm, 279.5*mm, subject)
    pdf.drawString(98*mm, 279.5*mm, day)
    pdf.setFont("Courier-Bold", 10)
    pdf.drawString(137.5*mm, 279.5*mm, date)
    pdf.save()


def header_landscape():
    pdf = canvas.Canvas("header_l.pdf", pagesize=A4)
    pdf.setFont("Courier-Bold", 12)
    pdf.drawString(87*mm, 196.5*mm, subject)
    pdf.drawString(141*mm, 196.5*mm, day)
    pdf.setFont("Courier-Bold", 10)
    pdf.drawString(180*mm, 196.5*mm, date)
    pdf.save()

def handout():
    pdf = canvas.Canvas("handout.pdf", pagesize=A4)
    pdf.setFont("Courier-Bold", 26)
    pdf.drawString(90.5*mm, 245.3*mm, subject[-2:])
    pdf.save()


header_portrait()
header_landscape()
handout()


def header(
    content_pdf: Path,
    stamp_pdf: Path,
    pdf_result: Path,
    page_indices: Union[Literal["ALL"], List[int]] = "ALL",
):
    stamp_page = PdfReader(stamp_pdf).pages[0]

    writer = PdfWriter()

    reader = PdfReader(content_pdf)
    if page_indices == "ALL":
        page_indices = list(range(0, len(reader.pages)))
    for index in page_indices:
        content_page = reader.pages[index]
        content_page.merge_page(stamp_page)
        # content_page.merge_transformed_page(
        #     stamp_page,
        #     Transformation(),
        # )
        writer.add_page(content_page)

    with open(pdf_result, "wb") as fp:
        writer.write(fp)



def add_blank_header(
    content_pdf: Path,
    stamp_pdf: Path,
    pdf_result: Path,
    page_indices: Union[Literal["ALL"], List[int]] = "ALL",
):
    stamp_page = PdfReader(stamp_pdf).pages[0]

    writer = PdfWriter()

    reader = PdfReader(content_pdf)
    if page_indices == "ALL":
        page_indices = list(range(0, len(reader.pages)))
    for index in page_indices:
        content_page = reader.pages[index]
        content_page.merge_page(stamp_page)
        # content_page.merge_transformed_page(
        #     stamp_page,
        #     Transformation(),
        # )
        writer.add_page(content_page)

    with open(pdf_result, "wb") as fp:
        writer.write(fp)

def clean_up():
    os.remove("header_p.pdf")
    os.remove("header_l.pdf")
    os.remove("handout.pdf")




def sort_pages():
    # extract single page from pdf
    pdf_1 = PdfReader("portrait.pdf")
    pdf_2 = PdfReader("ios.pdf")
    pdf_3 = PdfReader("final_handout.pdf")
    merger = PdfMerger()
    merger.append(pdf_1)

    merger.merge(2, pdf_2, pages=(0, 1))
    merger.merge(7, pdf_2, pages=(1, 2))
    merger.merge(17, pdf_2, pages=(2, 3))
    merger.merge(19, pdf_2, pages=(3, 4))
    merger.merge(26, pdf_2, pages=(4, 5))
    merger.merge(30, pdf_2, pages=(5, 6))
    merger.merge(33, pdf_2, pages=(6, 7))

    merger.append(pdf_3)

    merger.write(output)
    merger.close()






header("TD_printing_per_participant_v3.pdf", "header_p.pdf", "portrait.pdf", portrait_pages)
header("TD_printing_per_participant_v3.pdf", "header_l.pdf", "ios.pdf", ios_pages)
header("TD_printing_per_participant_v3.pdf", "handout.pdf", "final_handout.pdf", handout_page)

sort_pages()
clean_up()

# add_header("EGT_no_header.pdf", "header.pdf", "egt_with_header.pdf")

# stamp("test.pdf", "stamp.pdf", output, vas_pages)

# canvas.getAvailableFonts()
# Pages containing VAS: 1,2,4,5,6,7, 21:26, 29, 30, 32, 33
