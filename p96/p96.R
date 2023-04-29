# Alternative Uses: Change Data Format ------------------------------------

# Study: P96
# Task: Alternative Uses
#
# Rearrange data from an Excel sheet to simplify further analysis (e.g., 
# (e.g., semantic distance).
# 
# Author: Jonas Neubert (https://neubert.eu)
# last updated: 29.04.2023

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
# 3. Export Excel file as comma separated values (csv) (UTF-8) file.
#     (The second worksheet "Total score" can be ignored altogether)
#
#     NB: All formatting (e.g., responses marked with red font color) is lost
#     when exporting as csv. Those would have to be added manually again to the
#     output Excel file, if important for further analysis.
#
# 4. Place the csv file in the data folder.
#     (Content of the data folder is ignored by Git, see .gitignore)
#     (The data folder and this script have to be in the same location.)

# Load Packages -----------------------------------------------------------

# Set working directory to current file location 
# (Either use UI or uncomment the shortcut below)
# setwd(dirname(rstudioapi::getActiveDocumentContext()$path))

library(readr)
library(dplyr)
library(tibble)
library(sjmisc, include.only = c("rotate_df", "remove_empty_cols"))
library(openxlsx)

# Import Data -------------------------------------------------------------

# Only import first column and those starting with "P96"
dat <- read_csv("data/p96.csv",
  col_select = c(1, starts_with("P96")),
  lazy = TRUE) |>
  rename(seed = ...1)


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

rotate <- \(s) {
  dat[start[s]:end[s], ] |>
    rowid_to_column("ID") |>
    select(-"seed") |>
    rotate_df(cn = TRUE, rn = "subject") |>
    mutate(seed = str_to_title(s), .after = subject) |>
    remove_empty_cols()
}


# Combine Responses for Versions A, B, and C-----------------------------

# Named list of tibbles
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

if (!dir.exists("output")) {dir.create("output")}

write.xlsx(output, file = "output/P96_wide_v2.xlsx", colWidths = "auto")
