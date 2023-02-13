# Generate seed words for the Word Association Task

# Install prerequisites
if (!require("devtools")) install.packages("devtools")
if (!require("LexOPS")) devtools::install_github("JackEdTaylor/LexOPS@*release")
setwd(dirname(rstudioapi::getActiveDocumentContext()$path))

library(LexOPS)
library(dplyr)
library(tidyselect)


# Filtering and sorting the lexops dataset
# - Removing unnecessary columns
# - Sorting by word frequency (Zipf.SUBTLEX_UK)
# - Only keeping nouns (PoS.SUBTLEX_UK)
# Other options for word frequency and word type are available
# SUBTLEX_UK is based on British TV/movie subtitle data


dataset <- lexops %>%
  filter(!is.na(VAL.Glasgow_Norms) &
           PoS.SUBTLEX_UK == "noun" | PoS.SUBTLEX_UK == "unclassified") %>%
  select(contains(c("string", "Zipf.SUBTLEX_UK",
                    "length", "Glasgow_Norms"))) %>%
  arrange(desc(Zipf.SUBTLEX_UK))

# The Glasgow Norms are used to classify words.
# See here: https://link.springer.com/article/10.3758/s13428-018-1099-3


# EMOTIONAL
# High in valence and arousal
# Concreteness above average (to differentiate from abstract words)
emotional <- dataset %>%
  filter(VAL.Glasgow_Norms > 7 &
           AROU.Glasgow_Norms > 7 &
           CNC.Glasgow_Norms > 4)
cat(nrow(emotional), "emotional words.")


# ABSTRACT
# Average valence and arousal
# Low in concreteness (i.e., high in abstractness)

abstract <- dataset %>%
  filter(between(VAL.Glasgow_Norms, 4, 6) &
           between(AROU.Glasgow_Norms, 4, 6) &
           CNC.Glasgow_Norms < 3)
cat(nrow(abstract), "abstract words.")


# NEUTRAL
# Average valence and arousal
# Concreteness above average

neutral <- dataset %>%
  filter(between(VAL.Glasgow_Norms, 4.7, 5.3) &
           between(AROU.Glasgow_Norms, 4.7, 5.3) &
           CNC.Glasgow_Norms > 4)
cat(nrow(neutral), "neutral words.")


# Output to csv (optional)
write.csv(emotional[, 1:2], "output/emotional.csv")
write.csv(abstract[, 1:2], "output/abstract.csv")
write.csv(neutral[, 1:2], "output/neutral.csv")
