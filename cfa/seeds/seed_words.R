# Generate Seed Words -----------------------------------------------------

# Study: P139
# Task: Chain Free Association (CFA)
#
# Determines twelve seed words:
# Four each with emotional, abstract, and neutral connotation.
#
# Link to GitHub repository:
# https://github.com/NeubertJonas/p139_study/tree/main/cfa/seeds
#
# Author: Jonas Neubert (https://neubert.eu)
# last updated: 05.07.2023

# Load Packages -----------------------------------------------------------

if (!require("devtools")) install.packages("devtools")
if (!require("LexOPS")) devtools::install_github("JackEdTaylor/LexOPS@*release")

library(LexOPS)
library(dplyr)
library(tidyselect)

# Create Dataset ---------------------------------------------------------

dataset <- lexops |>
  filter(
    !is.na(VAL.Glasgow_Norms) &
      PoS.SUBTLEX_UK == "noun"
  ) |>
  select(contains(c(
    "string", "Zipf.SUBTLEX_UK",
    "length", "Glasgow_Norms"
  ))) |>
  arrange(desc(Zipf.SUBTLEX_UK))

# Description
# 1. Import LexOPS dataset
# 2. Filter: Only words with Glasgow Norms and only nouns
# 3. Select only required columns
# 4. Sort by word frequency (Zipf.SUBTLEX_UK)

# Emotional ---------------------------------------------------------------

# High in valence and arousal
# Concreteness above average (to differentiate from abstract words)

emotional <- dataset %>%
  filter(VAL.Glasgow_Norms > 6 &
    AROU.Glasgow_Norms > 4.6 &
    CNC.Glasgow_Norms > 5)

cat(nrow(emotional), "emotional words identified.")

# Final, human selection: world, people, mother, father


# Abstract ----------------------------------------------------------------

# Average valence and arousal
# Low in concreteness (i.e., high in abstractness)
# AROU to 3.9 to include "time"

abstract <- dataset %>%
  filter(between(VAL.Glasgow_Norms, 3.9, 6) &
    between(AROU.Glasgow_Norms, 3.9, 6) &
    CNC.Glasgow_Norms < 3)

cat(nrow(abstract), "abstract words identified.")

# Final, human selection: mood, illusion, pride, time


# Neutral -----------------------------------------------------------------

# Average valence and arousal
# Concreteness above average

neutral <- dataset %>%
  filter(between(VAL.Glasgow_Norms, 4.85, 5.45) &
    between(AROU.Glasgow_Norms, 4.3, 4.9) &
    CNC.Glasgow_Norms > 6)

cat(nrow(neutral), "neutral words identified.")

# Final, human selection: taxi, jacket, boot, tower

# Raw Output (optional) ---------------------------------------------------

# Set working directory to current file location
# Either in RStudio
# (Session > Set Working Directory > To Source File Location)
# or by uncommenting the API shortcut below.

# setwd(dirname(rstudioapi::getActiveDocumentContext()$path))

# write.csv(emotional[, 1:2], "_output/emotional.csv")
# write.csv(abstract[, 1:2], "_output/abstract.csv")
# write.csv(neutral[, 1:2], "_output/neutral.csv")

# Clean-Up ----------------------------------------------------------------

# rm(dataset, emotional, abstract, neutral)
