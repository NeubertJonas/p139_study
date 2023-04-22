# P96 - Data Wrangling ----------------------------------------------------
#
# Adapts a wide data format for further analysis.
#


# Load Packages -----------------------------------------------------------

# Set working directory to current file location (shortcut)
# setwd(dirname(rstudioapi::getActiveDocumentContext()$path))

library(conflicted)
library(tidyverse)
library(sjmisc)
library(writexl)

conflicts_prefer(
  dplyr::filter,
  dplyr::lag
)


# Preparation -------------------------------------------------------------

# 1. The cells with "Version A: Pen", etc. are used as markers when
# responses begin. Make sure these cells align with the first response!
# Example: If "Version B: Towel" is in A81, all participant responses
# have to start in row 81.
# (I have already uploaded an adapted version to the rdm: "..._v2.xlsx")
# 2. Export Excel file as csv
# 3. Place in the data folder
# (Everything saved there is ignored by Git, see .gitignore)


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

write_xlsx(output, path = "data/P96_wide_v1.xlsx")
