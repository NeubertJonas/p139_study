# Relationship Metrics ----------------------------------------------------
# Calculate the scores for all relationship-related questionnaires

setwd(dirname(rstudioapi::getActiveDocumentContext()$path))
library(tidyverse)

# Import data, filter non-participant responses, and
# remove unnecessary columns
drop_col <- c(
  "StartDate", "EndDate", "Status", "IPAddress", "Progress",
  "ResponseID", "RecipientLastName", "RecipientFirstName",
  "RecipientEmail", "ExternalReference", "LocationLatitude",
  "LocationLongitude", "DistributionChannel", "UserLanguage"
)


dat <- read_csv("data/questionnaire_2.csv", show_col_types = FALSE) |>
  filter(grepl("139", Q2)) |>
  select(-any_of(drop_col)) |>
  mutate(across(Q3:Q49 | Q51_1 | Q52_1, as.integer)) |>
  mutate(across(Q2, as.character))

rm(drop_col)


# Overview of all questionnaires
# Double-check if starting question and item count are correct.
scales <- tribble(
  ~name,       ~start,  ~item_count,
  "CSI_4",     "Q5",    4,
  "SWLS",      "Q9_1",  5,
  "PPRS_12",   "Q10_1", 12,
  "PPRS_12_U", "Q10_3", 5,
  "PPRS_12_V", "Q10_8", 5,
  "IRI_C",     "Q11_1", 13,
  "ECR_S",     "Q12_1", 12,
  "GMSEX",     "Q13_1", 5,
  "FSFI",      "Q15",   19,
  "IIEF",      "Q35",   15
)

calculate_metrics <- \(dat) {
  dat <- dat |>
    csi() |>
    swls() |>
    pprs() |>
    iri() |>
    ecr()
  #|> ecr() |> gmsex() |> fsfi() |> iief()
  return(dat)
}


# Generic Helper Functions ------------------------------------------------

# Column name of first question for a scale
first_question <- \(x) {
  return(
    scales |> filter(name == x) |> pull(start)
  )
}

# Item count for a scale
get_count <- \(x) {
  return(
    scales |> filter(name == x) |> pull(item_count)
  )
}

# Range of columns belonging to a scale
get_range <- \(dat, name) {
  x <- which(names(dat) == first_question(name))
  y <- x + get_count(name) - 1
  z <- c(x:y)
  return(z)
}

# Results for Scales
# Leaving "participant" and "column" blank will return data for
# all participants and all scales
# Vectors are allowed as input, e.g.,
# get_results(dat, c("13902", "P13901"), c("CSI_4", "SWLS"))

get_results <- \(dat, participant = NA, column = NA) {
  if (is.logical(participant) && is.logical(column)) {
    results <- dat |> select(any_of(c("Q2", scales$name)))
  } else if (!is.logical(participant) && !is.logical(column)) {
    results <- dat |>
      select(any_of(c("Q2", scale))) |>
      filter(Q2 == participant)
  } else if (!is.logical(scale)) {
    results <- dat |> select(any_of(c("Q2", column)))
  } else if (!is.logical(participant)) {
    results <- dat |>
      select(any_of(c("Q2", scales$name))) |>
      filter(Q2 == participant)
  }

  return(results)
}


# Questionnaire Functions -------------------------------------------------
# Note. Scores for scales will be NA if any questions were skipped.

# Couple Satisfaction Index (CSI-4)
# Qualtrics records the lowest response as "1", but for scoring
# it is changed to "0".

csi <- \(dat) {
  range <- get_range(dat, "CSI_4")
  x <- dat |> select(all_of(range))
  dat <- dat |> mutate(CSI_4 = rowSums(x) - 4, .after = max(range))

  return(dat)
}

# Satisfaction with Life Scale (SWLS)
swls <- \(dat) {
  range <- get_range(dat, "SWLS")
  x <- dat |> select(all_of(range))
  dat <- dat |> mutate(SWLS = rowSums(x), .after = max(range))

  return(dat)
}

# Perceived Partner Responsiveness Scale (PPRS)
pprs <- \(dat) {
  range <- get_range(dat, "PPRS_12")
  x <- dat |> select(all_of(range))
  dat <- dat |> mutate(PPRS_12 = rowSums(x), .after = max(range))

  dat <- dat |>
    pprs_u() |>
    pprs_v()

  return(dat)
}

# PPRS: Understanding subscale
pprs_u <- \(dat) {
  range <- get_range(dat, "PPRS_12_U")
  x <- dat |> select(all_of(range))
  dat <- dat |> mutate(PPRS_12_U = rowSums(x), .after = PPRS_12)

  return(dat)
}

# PPRS: Validation subscale
pprs_v <- \(dat) {
  range <- get_range(dat, "PPRS_12_V")
  x <- dat |> select(all_of(range))
  dat <- dat |> mutate(PPRS_12_V = rowSums(x), .after = PPRS_12)

  return(dat)
}

# Interpersonal Reactivity Index for Couples (IRI-C)
iri <- \(dat) {
  range <- get_range(dat, "IRI_C")
  x <- dat |> select(all_of(range))

  # Subtract 1 from all items for scoring
  # (to change range from 1:5 to 0:4)
  # Reverse code items 2, 6, 7, and 8
  x <- x |>
    mutate(across(everything(), minus_one)) |>
    mutate(across(ends_with(c("_2", "_6", "_7", "_8")), reverse_iri))

  dat <- dat |> mutate(IRI_C = rowSums(x), .after = max(range))

  # Subscales
  dat <- dat |>
    iri_ec(x) |>
    iri_pt(x)

  return(dat)
}


# IRI-C: Empathic Concern scale
iri_ec <- \(dat, iri_dat) {
  x <- iri_dat |> select(
    ends_with(c("_1", "_2", "_4", "_6", "_8", "_9", "_11"))
  )

  dat <- dat |> mutate(IRI_C_EC = rowSums(x), .after = IRI_C)

  return(dat)
}

# IRI-C: Perspective Taking scale
iri_pt <- \(dat, iri_dat) {
  x <- iri_dat |> select(
    !ends_with(c("_1", "_2", "_4", "_6", "_8", "_9", "_11"))
  )

  dat <- dat |> mutate(IRI_C_PT = rowSums(x), .after = IRI_C)

  return(dat)
}

# Helper Functions
reverse_iri <- \(x) {
  x <- abs(x - 4)
  return(x)
}

minus_one <- \(x) {
  return(x - 1)
}


# Experiences in Close Relationship Scale (ECR-S)
ecr <- \(dat) {
  range <- get_range(dat, "ECR_S")
  x <- dat |> select(all_of(range))

  # Reverse code items 1, 5, 8, and 9
  x <- x |> mutate(across(
    ends_with(c("_1", "_5", "_8", "_9")), ecr_reverse
  ))

  dat <- dat |> mutate(ECR_S = rowSums(x), .after = max(range))

  # Subscales
  dat <- dat |>
    ecr_s_an(x) |>
    ecr_s_av(x)

  return(dat)
}

# ECR-S: Attachment Anxiety scale
ecr_s_an <- \(dat, ecr_dat) {
  x <- ecr_dat |> select(
    ends_with(c("_2", "_4", "_6", "_8", "_10", "_12"))
  )

  dat <- dat |> mutate(ECR_S_AN = rowSums(x), .after = ECR_S)

  return(dat)
}

# ECR-S: Attachment Avoidance scale
ecr_s_av <- \(dat, ecr_dat) {
  x <- ecr_dat |> select(
    !ends_with(c("_2", "_4", "_6", "_8", "_10", "_12"))
  )

  dat <- dat |> mutate(ECR_S_AV = rowSums(x), .after = ECR_S)

  return(dat)
}

# Global Measure of Sexual Satisfaction (GMSEX)
gmsex <- \(dat) {
  range <- get_range(dat, "GMSEX")
  x <- dat |> select(all_of(range))

  # Reverse code all items
  x <- x |> mutate(across(everything(), reverse_7))

  dat <- dat |> mutate(GMSEX = rowSums(x), .after = max(range))

  return(dat)
}

reverse_7 <- \(x) {
  x <- abs(x - 8)
  return(x)
}


# Female Sexual Function Index (FSFI)
fsfi <- \(dat) {
  range <- get_range(dat, "FSFI")
  x <- dat |> 
 #   filter(Q4 == 1) |> 
    select(all_of(range))
  
  x <- x |>
    mutate(
      across(ends_with(c("15", "16", "29", "30")), reverse_5)) |>
    mutate(
      across(ends_with(c(
      "17", "18", "19", "20", "21", "23", "25", "27", "28")), reverse_6)) |>
    mutate(
      across(ends_with(c("22", "24", "26", "31", "32", "33")), minus_one
    ))
  
  # Calculate domains (subscales):
  # Desire, Arousal, Lubrication, Orgasm, Satisfaction, Pain
  x <- x |>
    mutate(FSFI_D = (x[[1]] + x[[2]]) * 0.6) |>
    mutate(FSFI_A = (x[[3]] + x[[4]] + x[[5]] + x[[6]]) * 0.3) |>
    mutate(FSFI_L = (x[[7]] + x[[8]] + x[[9]] + x[[10]]) * 0.3) |>
    mutate(FSFI_O = (x[[11]] + x[[12]] + x[[13]]) * 0.4) |>
    mutate(FSFI_S = (x[[14]] + x[[15]] + x[[16]]) * 0.4) |>
    mutate(FSFI_P = (x[[17]] + x[[18]] + x[[19]]) * 0.4)
 # x <- mutate(x, FSFI2 = rowSums(x[20:25]), .after = 19)
  x <- x |> mutate(FSFI = rowSums(pick(20:25)), .after = 19)
  fsfi <- x |> select(contains("FSFI"))
  
  dat <- dat |> add_column(fsfi, .after = "Q33")

  return(dat)
}



# Reverse code 1:5 --> 5:1
reverse_5 <- \(x) {
  x <- abs(x - 6)
  return(x)
}

# reverse_5 <- \(x) {abs(x - 6)}

# Reverse and recode "no sex. activity" as 0
# 1:6 --> 0, 5:1
reverse_6 <- \(x) {
  x <- abs(x - 7)
  x <- case_when(
    x == 6 ~ 0,
    .default = x
  )
#  if (x == 6) x <- 0
  # if statements do not work with vectors, use case_when() instead
  return(x)
}

# International Index of Erectile Function (IIEF)
iief <- \(dat) {
  range <- get_range(dat, "IIEF")
  x <- dat |> select(all_of(range))
  
  # Reverse code all items
  x <- x |> mutate(across(everything(), reverse_7))
  
  dat <- dat |> mutate(IIEF = rowSums(x), .after = max(range))
  
  return(dat)
}


output <- calculate_metrics(dat)
