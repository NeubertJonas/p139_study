if (!require("devtools")) install.packages("devtools")
devtools::install_github("JackEdTaylor/LexOPS@*release")

setwd(dirname(rstudioapi::getActiveDocumentContext()$path))

library(LexOPS)
library(readr)


# LexOPS::run_shiny()

# DAT Task: Match items for "chair"

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
# Best match: scarf

# Word Association Tasks

stim <- lexops %>%
  subset(FAM.Glasgow_Norms > 4) %>%
  subset(Zipf.SUBTLEX_UK > 4) %>%
  split_by(CNC.Glasgow_Norms, 1:2.5 ~ 3.5:4.5) %>%
  split_by(VAL.Glasgow_Norms, 4.5:5.5 ~ 7:9) %>%
  control_for(Length, -1:1) %>%
  control_for(DOM.Glasgow_Norms, -1.5:1.5) %>%
  control_for(AROU.Glasgow_Norms, -1.5:1.5) %>%
  generate(30)


plot_design(stim)
plot_sample(stim)

# Selected columns: Prevalence (Zipf), length, Glasgow criteria
select_columns = c(1, 6, 16, 21, 45, 48, 51, 52, 55, 57, 59:61)
# remove_columns = -c(2:5, 7:15, 22:44)

#  l = lexops

# Generate words: Emotional (Valence + Arousal)
# Remove unnecessary columns, only words with high frequency (subtitles)
# Only nouns, high valence and arousal, Concreteness above average
emotional2 <- lexops[select_columns] %>%
  subset(Zipf.SUBTLEX_UK > 4) %>%
  subset(PoS.SUBTLEX_UK == "noun") %>%
  subset(VAL.Glasgow_Norms > 7) %>%
  subset(AROU.Glasgow_Norms > 7) %>%
  subset(CNC.Glasgow_Norms > 4)
# 17 results


abstract <- lexops[select_columns] %>%
  subset(Zipf.SUBTLEX_UK > 4) %>%
  subset(PoS.SUBTLEX_UK == "noun") %>%
  subset(VAL.Glasgow_Norms > 4) %>%
  subset(VAL.Glasgow_Norms < 6) %>%
  subset(AROU.Glasgow_Norms > 4) %>%
  subset(AROU.Glasgow_Norms < 6) %>%
  subset(CNC.Glasgow_Norms < 3)
# 18 results

neutral <- lexops[select_columns] %>%
  subset(Zipf.SUBTLEX_UK > 4) %>%
  subset(PoS.SUBTLEX_UK == "noun") %>%
  subset(VAL.Glasgow_Norms > 4.7) %>%
  subset(VAL.Glasgow_Norms < 5.3) %>%
  subset(AROU.Glasgow_Norms > 4.7) %>%
  subset(AROU.Glasgow_Norms < 5.3) %>%
  subset(CNC.Glasgow_Norms > 6)
# 10 results

############--------------------------------------------
  subset(CNC.Glasgow_Norms > 6)


  split_by(VAL.Glasgow_Norms, 4.5:5.5 ~ 7:9) %>%
  control_for(Length, -1:1) %>%
  control_for(IMAG.Glasgow_Norms, -1:1) %>%
  control_for(DOM.Glasgow_Norms, -1.5:1.5) %>%
  control_for(AROU.Glasgow_Norms, -1.5:1.5) %>%
  generate(30)



stim <- lexops %>%
  subset(FAM.Glasgow_Norms > 5) %>%
  split_by(CNC.Glasgow_Norms, 1:3 ~ 5:7) %>%
  split_by(VAL.Glasgow_Norms, 4:6 ~ 7:9) %>%
  control_for(Length, -1:1) %>%
  generate(20)


  control_for(IMAG.Glasgow_Norms, -1:1) %>%
  control_for(DOM.Glasgow_Norms, -1.5:1.5) %>%
  control_for(AROU.Glasgow_Norms, -1.5:1.5) %>%
  generate(20)


write.csv(stim, "wordlist.csv")



plot_design(stim)
plot_sample(stim)

stim3 <- lexops %>%
  subset(VAL.Glasgow_Norms > 7) %>%
  
  split_by(AROU.Glasgow_Norms, 4.75:5.25 ~ 7:9) %>%
  control_for(Length, -1:1) %>%
  generate(20)

  control_for(AROU.Glasgow_Norms, -1:1) %>%
  control_for(Length, -1:1) %>%
  generate(20)

  subset(FAM.Glasgow_Norms >= 5) %>%
  split_by(VAL.Glasgow_Norms, 4.75:5.25 ~ 7:9) %>%
  control_for(Length, -1:1) %>%
  control_for(AROU.Glasgow_Norms, -1:1) %>%
  control_for(CNC.Glasgow_Norms, -1:1) %>%
  generate(20)

stim <- lexops %>%
  subset(PK.Brysbaert >= 0.9) %>%
  split_by(CNC.Brysbaert, 1:2 ~ 4:5) %>%
  split_by(BG.SUBTLEX_UK, 0:0.003 ~ 0.009:0.013) %>%
  control_for(Length, 0:0) %>%
  control_for(Zipf.SUBTLEX_UK, -0.2:0.2) %>%
  generate(n = 25)

# LANG <- read_csv("glasgow.csv", locale=locale(encoding = "latin1"))

stim <- LANG %>%
  subset(FAM_M >= 5) %>%
  split_by(VAL_M, 1:3.5 ~ 4.75:5.25 ~ 6.5:9) %>%
  control_for(length, 0:0) %>%
  control_for(AROU_M, -1:1) %>%
  control_for(CNC_M, -1:1) %>%
  generate(20)

stim <- lexops %>%
  subset(FAM.Glasgow_Norms >= 5) %>%
  split_by(VAL.Glasgow_Norms, 1:3.5 ~ 4.75:5.25 ~ 6.5:9) %>%
  control_for(Length, 0:0) %>%
  control_for(AROU.Glasgow_Norms, -1:1) %>%
  control_for(CNC.Glasgow_Norms, -1:1) %>%
  generate(20)

plot_design(stim)
plot_sample(stim)




stim <- lexops %>%
  subset(FAM.Glasgow_Norms >= 5) %>%
  split_by(VAL.Glasgow_Norms, 1:3.5 ~ 4.75:5.25 ~ 6.5:9) %>%
  control_for(Length, 0:0) %>%
  control_for(AROU.Glasgow_Norms, -1:1) %>%
  control_for(CNC.Glasgow_Norms, -1:1) %>%
  generate(20)

