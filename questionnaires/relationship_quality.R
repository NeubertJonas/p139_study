# Calculate the scores for all relationship-related questionnaires

setwd(dirname(rstudioapi::getActiveDocumentContext()$path))
library(tidyverse)

# Import data, filter non-participant responses, and
# remove unneccesary columns
drop_col = c("StartDate", "EndDate", "Status", "IPAddress", "Progress",
           "ResponseID","RecipientLastName", "RecipientFirstName",
           "RecipientEmail", "ExternalReference", "LocationLatitude",
           "LocationLongitude", "DistributionChannel", "UserLanguage")


dat = read_csv("data/questionnaire_2.csv", show_col_types = FALSE) |> 
  filter(grepl("139", Q2)) |> 
  select(-any_of(drop_col)) |> 
  mutate(across(Q3:Q49 | Q51_1 | Q52_1, as.integer))


# Calculate questionnaire results

# Couple Satisfaction Index (CSI-4)
# Q5 - Q8
# Qualtrics records the lowest response as "1", but for scoring
# it is changed to "0".

add_csi = \(dat) {
  csi = dat |> mutate(CSI_4 = Q5 + Q6 + Q7 + Q8 - 4, .after = Q8)
  
  # Does not work:
#  csi = dat |> mutate(CSI_4 = sum(across(Q5:Q8)) - 4, .after = Q8)
  return(csi)
}

new = add_csi(dat)

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

