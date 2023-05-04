# Alternative Uses: Change Data Format ------------------------------------

# Study: P96
# Task: Alternative Uses
#
# Rearrange data from an Excel sheet to simplify further analysis (e.g.,
# (e.g., semantic distance).
#
# Link to GitHub repository:
# https://github.com/NeubertJonas/p139_study/blob/main/p96/p96.R
#
# Author: Jonas Neubert (https://neubert.eu)
# last updated: 04.05.2023

# Preparation -------------------------------------------------------------

# Some manual changes to the original Excel file are required to ensure
# the R script runs smoothly. The following two changes were made and resulted
# in the "P96_Alternative USes_SilviaScoring_v2.xlsx" file.
#
# 1. The cells indicating version and seed word serve as markers when
#     responses begin. Their location needs to align with the first response.
#
#     "Version A: Newspaper" moved from A39 to A38.
#     Responses to "Newspaper" moved up by one to row 38 for subjects 1 to 34.
#     (Responses for subjects 35 to 63 already started on row 38.)
#
#     "Version: C: Brick" moved from A152 to A149.
#     Responses for subjects 2 to 31 moved to row 149.
#     (Remaining subjects already started on row 149)
#
#     No changes for the other seed words.
#
# 2. Research notes such as "(testday 1 for this participant)" were identified
#     and tagged by adding a preceding underscore. They will be removed by
#     the R script for the output file, but have been added to the
#     new file "P96_Research_Notes.xlsx"
#
#     NB: All formatting (e.g., responses marked with red font color) is lost
#     when importing in R. Those would have to be added manually again to the
#     output Excel file, if important for further analysis.
#
# 3. Make sure the Excel file is in the data folder and referenced correctly in
#     line 63.
#     (Content of the data folder is ignored by Git, see .gitignore)
#     (The data folder and this script have to be in the same location.)

# Set Working Directory ---------------------------------------------------

# Set working directory to current file location
# (Either use UI or uncomment the API shortcut below)

# setwd(dirname(rstudioapi::getActiveDocumentContext()$path))

# Load Packages -----------------------------------------------------------

# Selected tidyverse packages
library(dplyr)
library(tibble)
library(stringr)
library(readxl)
# Note: While readxl is part of the tidyverse,
# it is not loaded by default when calling library(tidyverse)

# Packages to extend the tidyverse and allow for Excel output
library(sjmisc, include.only = c("rotate_df", "remove_empty_cols"))
library(openxlsx)

# Import Data -------------------------------------------------------------

dat <- read_xlsx("data/P96_Alternative Uses_SilviaScoring_v2.xlsx",
  .name_repair = "minimal",
  trim_ws = TRUE
) |>
  select(
    seed = 1,
    starts_with("P96")
  )

# Create Index ------------------------------------------------------------
# Identify where each seed starts and ends

# Version A, B, C (two seeds each)
seeds <- c("pen", "newspaper", "towel", "bottle", "brick", "shoe")

# Initialize empty, named vectors
start <- vector(length = length(seeds))
names(start) <- seeds

end <- vector(length = length(seeds))
names(end) <- seeds

# Look for seeds and identify their range
for (i in seq_along(seeds)) {
  start[i] <- grep(seeds[i], dat$seed, ignore.case = TRUE)

  # Last seed: take the final row
  if (i == length(seeds)) {
    end[i] <- nrow(dat)
    break
  }

  end[i] <- grep(seeds[i + 1], dat$seed, ignore.case = TRUE) - 1
}
rm(i)

# Rotate Data -----------------------------------------------------------
# Also removes any cells starting with "_"

rotate <- \(s) {
  dat[start[s]:end[s], ] |>
    rowid_to_column("ID") |>
    select(-"seed") |>
    rotate_df(cn = TRUE, rn = "subject") |>
    mutate(seed = str_to_title(s), .after = subject) |>
    remove_empty_cols() |>
    mutate(across(
      everything(),
      \(.) case_when(
        grepl("^_", .) ~ NA,
        .default = .
      )
    ))
}

# Combine Responses for Versions A, B, and C-----------------------------

# Named list of all data frames
output <- list(
  "Version A" = bind_rows(
    rotate("pen"),
    rotate("newspaper")
  ),
  "Version B" = bind_rows(
    rotate("towel"),
    rotate("bottle")
  ),
  "Version C" = bind_rows(
    rotate("brick"),
    rotate("shoe")
  )
)
# Export to Excel ---------------------------------------------------------

# Create folder if it is missing
if (!dir.exists("output")) {
  dir.create("output")
}

# Optional styling for Excel
hs <- createStyle(
  fgFill = "#4F81BD", halign = "CENTER", textDecoration = "Bold",
  border = "Bottom", fontColour = "white"
)

write.xlsx(output,
  file = "output/P96_wide_v2.xlsx",
  colWidths = "auto",
  headerStyle = hs,
  borders = "rows",
  borderColour = "grey",
  firstRow = TRUE,
  firstCol = TRUE
)

# Clean-Up

rm(hs, output, dat, end, seeds, start, rotate)
