from reportlab.pdfgen import canvas
from reportlab.lib.units import mm, cm
from reportlab.lib import colors
from reportlab.lib.pagesizes import A4


from pathlib import Path
from typing import Union, Literal, List

from pypdf import PdfWriter, PdfReader, Transformation

# subject = input("Enter the subject code here:")
subject = "P13903"
day = "A_3"
date = "10.05.2023"
output = subject+"print_TD.pdf"

vas_pages = [0, 1, 3, 4, 5, 6, 20, 21, 22, 23, 24, 25, 28, 29, 31, 32]


def stampVAS():
    #    text = input("Enter the watermark text here:")
    pdf = canvas.Canvas("stamp.pdf", pagesize=A4)
#    pdf.translate(cm, cm)
#    pdf.setFillColor(colors.grey, alpha=0.6)
    pdf.setFont("Courier-Bold", 12)
    pdf.drawString(48*mm, 280*mm, subject)
    pdf.drawString(100*mm, 280*mm, day)
    pdf.setFont("Courier-Bold", 10)
    pdf.drawString(143*mm, 280*mm, date)
    pdf.save()


stampVAS()


def stamp(
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


def stamp_2(
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
    
    content_page = reader.pages[2]
    writer.add_page(content_page)

    with open(pdf_result, "wb") as fp:
        writer.write(fp)




def add_header(
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


add_header("EGT-post-print_no header.pdf", "header.pdf", "egt_with_header.pdf")

# stamp("test.pdf", "stamp.pdf", output, vas_pages)

# canvas.getAvailableFonts()
# Pages containing VAS: 1,2,4,5,6,7, 21:26, 29, 30, 32, 33
