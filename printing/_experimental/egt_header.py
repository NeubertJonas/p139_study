""" Add standard header to the EGT PDF files exported from InDesign"""

# Import packages

import os
from pathlib import Path
from typing import Union, Literal, List

from pypdf import PdfWriter, PdfReader, PdfMerger


def add_EGT_header(
        egt_pdf: Path,
        egt_header: Path,
        pdf_result: Path,
):
    reader = PdfReader(egt_pdf)
    reader_header = PdfReader(egt_header)
    page_indices = list(range(0, len(reader.pages)))

    writer = PdfWriter()

    for index in page_indices:
        content_page = reader.pages[index]
        header_page = reader_header.pages[index]

        content_page.merge_page(header_page)

        writer.add_page(content_page)

    with open(pdf_result, "wb") as fp:
        writer.write(fp)

# add_EGT_header("EGT/EGT_no_header_short.pdf", "EGT/EGT_post_header_only.pdf", "EGT/egt_with_header.pdf")
