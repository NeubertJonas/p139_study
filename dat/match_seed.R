# Divergent Association Task (DAT) ----------------------------------------
#
# Find a second seed word for DAT, which is similar to "chair".
#
# Link to GitHub repository:
# https://github.com/NeubertJonas/p139_study/tree/main/dat
#
# Author: Jonas Neubert (https://neubert.eu)
# Last updated: 04.07.2023
#
# Load Packages -----------------------------------------------------------

if (!require("devtools")) install.packages("devtools")
if (!require("LexOPS")) devtools::install_github("JackEdTaylor/LexOPS@*release")

library(LexOPS)

# Match Chair -------------------------------------------------------------

match_chair <- lexops %>%
  match_item(
    "chair",
    Length = 0:0,
    FAM.Glasgow_Norms  = -0.5:0.5,
    VAL.Glasgow_Norms  = -0.5:0.5,
    AROU.Glasgow_Norms = -0.5:0.5,
    CNC.Glasgow_Norms  = -0.5:0.5,
    IMAG.Glasgow_Norms = -0.5:0.5
  )

result = match_chair[[1,1]]

cat("The best match for 'chair' is ", result)


# Result ------------------------------------------------------------------
#
# Best match for "chair" is "scarf".
#
# Matched for length, familiarity, valence, arousal, concreteness, imageability
# All variables taken from the Glasgow Norms:
# https://doi.org/10.3758/s13428-018-1099-3
#
# Inspect match_chair for runner-up results and more details
