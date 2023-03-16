# Relationship Metrics ----------------------------------------------------
# Calculate the scores for all relationship-related questionnaires

setwd(dirname(rstudioapi::getActiveDocumentContext()$path))
library(tidyverse)

# Import data, filter non-participant responses, and
# remove unnecessary columns
drop_col = c("StartDate", "EndDate", "Status", "IPAddress", "Progress",
           "ResponseID","RecipientLastName", "RecipientFirstName",
           "RecipientEmail", "ExternalReference", "LocationLatitude",
           "LocationLongitude", "DistributionChannel", "UserLanguage")


dat = read_csv("data/questionnaire_2.csv", show_col_types = FALSE) |> 
  filter(grepl("139", Q2)) |> 
  select(-any_of(drop_col)) |> 
  mutate(across(Q3:Q49 | Q51_1 | Q52_1, as.integer))
rm(drop_col)

# Calculate questionnaire results



# Overview of all questionnaires
# Double-check if starting question and item count are correct.
scales <- tribble(
  ~name, ~start, ~item_count,
  "CSI_4", "Q5", 4,
  "SWLS", "Q9_1", 5,
  "PPRS_12", "Q10_1", 12,
  "IRI_C", "Q11_1", 13,
  "ECR-S", "Q12_1", 12,
  "GMSEX", "Q13_1", 5,
  "FSFI", "Q15", 19,
  "IIEF", "Q35", 15
)

# Column name of first question for a scale
first_question = \(x) {
  return(
    scales |> filter(name == x) |> pull(start)
    )
}

# Item count for a scale
get_count = \(x) {
  return(
    scales |> filter(name == x) |> pull(item_count)
    )
}

# Range of columns belonging to a scale
get_range = \(dat, name) {
  x = which(names(dat) == first_question(name))
  y = x + get_count(name) - 1
  z = c(x:y)
  return(z)
}



# Couple Satisfaction Index (CSI-4)
# Q5 - Q8
# Qualtrics records the lowest response as "1", but for scoring
# it is changed to "0".

add_csi = \(dat) {
  range = get_range(dat, "CSI_4")
  csi = dat |> select(all_of(range))
  dat = dat |> mutate(CSI_4 = rowSums(csi) - 4, .after = max(range))
  return(dat)
}
  # Note. Scores for scales will be NA if any questions were skipped.
  

get_csi = \(dat) {
  return(
    dat |> select(Q2 | CSI_4)
  )
}


get_scale = \(dat, participant, scale) {
  return(
    dat |> select(all_of(c(scale, "Q2"))) |> filter(Q2 == participant)
  )
}

add_swls = \(dat) {
  swls = dat |> mutate(SWLS = swls_cols , .after = Q9_5)
  swls = swls |> mutate(SWLS2 = rowSums(select(swls, starts_with("Q9_"))), .after = Q9_5)
  # Note. Score will be NA if any questions were skipped.
  
  return(swls)
}

test = add_csi(dat)

new = dat |> add_swls() |> add_csi()

csi = dat |> select(Q5:Q8)
csi = csi |> mutate(across(everything(), as.numeric)) |> 
  mutate(CSI_4 = Q5 + Q6 + Q7 + Q8 - 4)





  mutate(csi4 = as.numeric(Q5) + 4)
csi$Q5 = csi$Q5 + 1

csi4 = \(x) {
  csi = dat |> select(Q5:Q8) |> lapply(as.numeric)
    mutate(csi4 = as.numeric(Q5) + 4)
      
  csi = 
  
  
  return(result)
}

n(result)
}

