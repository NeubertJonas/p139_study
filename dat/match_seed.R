# Find matching word for "chair"

# Install prerequisites
if (!require("devtools")) install.packages("devtools")
if (!require("LexOPS")) devtools::install_github("JackEdTaylor/LexOPS@*release")
setwd(dirname(rstudioapi::getActiveDocumentContext()$path))

library(LexOPS)

match_chair <- lexops %>%
  match_item(
    "chair",
    Length = 0:0,
    FAM.Glasgow_Norms = -0.5:0.5,
    VAL.Glasgow_Norms = -0.5:0.5,
    AROU.Glasgow_Norms = -0.5:0.5,
    CNC.Glasgow_Norms = -0.5:0.5,
    IMAG.Glasgow_Norms = -0.5:0.5
  )

result = match_chair[[1,1]]
cat("The best match for 'chair' is ", result)
# Best match is "scarf"
# Matched for length, familiarity, valence, arousal, concreteness, imageability
# All variables taken from the Glasgow Norms

# Inspect match_chair for runner-up results and more details
