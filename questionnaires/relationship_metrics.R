# RELATIONSHIP METRICS ----------------------------------------------------
#
# Calculate scores for standardized questionnaires
# recorded via Qualtrics.
#
# Questionnaires: CSI-4, SWLS, PPRS-12, IRI-C, ECR-S, GMSEX, FSFI, IIEF
#
# Load Packages -----------------------------------------------------------

setwd(dirname(rstudioapi::getActiveDocumentContext()$path))

library(conflicted)
library(tidyverse)

conflicts_prefer(
  dplyr::filter,
  dplyr::lag
)


# Data Sources -------------------------------------------------------------
#
# Download the data as comma separated values (csv) file from Qualtrics.
# Select "Download all fields" and "Use numeric values" as options.
# Define files and their location below:

sources <- c(
  baseline = "data/baseline.csv",
  follow_up = "data/questionnaire_2.csv"
)

# Locating Data ------------------------------------------------------------
#
# The table below helps R to navigate the csv file by defining the content
# of all questions. Check if everything is correct before continuing!
# You do this in Qualtrics or by opening the csv file in Excel.
# For example, is "ID" saved in "Q2"? Does the IRI-C start with "Q11_1"?
#
# item_count defines the number of items(columns) belonging to a questionnaire
# You probably won't need to change this.
#
# Background: Numbering of questions might not be consistent across Qualtrics
# questionnaires, because the order or composition of questions is different.
# For example, the first item of the CSI-4 might change from
# "Q5" to "Q6" if another question is added before.
# Defining all starting questions here (rather than in the middle of the code),
# makes the script more robust and easier to adapt.

locations <- vector(mode = "list", length = 0)

locations[["baseline"]] <- tribble(
  ~name,          ~start,  ~item_count,
  "ID",           "Q2",    1,
  "Psychedelics", "Q3",    1,
  "SWLS",         "Q7_1",  5,
  "CSI_4",        "Q8",    4,
  "PPRS_12",      "Q12_1", 12,
  "ECR_S",        "Q13_1", 12,
  "IRI_C",        "Q14_1", 13,
  "GMSEX",        "Q15_1", 5,
  "Sex",          "Q16",   1,
  "FSFI",         "Q18",   19,
  "IIEF",         "Q38",   15,
)

locations[["follow_up"]] <- tribble(
  ~name,       ~start,  ~item_count,
  "ID",        "Q2",    1,
  "Day",       "Q3",    1,
  "Gender",    "Q4",    1,
  "CSI_4",     "Q5",    4,
  "SWLS",      "Q9_1",  5,
  "PPRS_12",   "Q10_1", 12,
  "IRI_C",     "Q11_1", 13,
  "ECR_S",     "Q12_1", 12,
  "GMSEX",     "Q13_1", 5,
  "FSFI",      "Q15",   19,
  "IIEF",      "Q35",   15,
  "Other",     "Q50",   4
)

# TODO: Sex != Gender (change in Qualtrics)

# Import Data -------------------------------------------------------------
#
# Import data, filter non-participant responses, and
# remove unnecessary columns

import_data <- \() {
  drop_col <- c(
    "StartDate", "EndDate", "Status", "IPAddress", "Progress",
    "ResponseId", "RecipientLastName", "RecipientFirstName",
    "RecipientEmail", "ExternalReference", "LocationLatitude",
    "LocationLongitude", "DistributionChannel", "UserLanguage"
  )

  for (i in seq_along(sources)) {
    assign("ds", names(sources[i]), pos = 1)
    col_names <- names(read_csv(sources[i],
      n_max = 0,
      show_col_types = FALSE
    ))

    dat <- read_csv(sources[i],
      skip = 3,
      col_names = col_names,
      show_col_types = FALSE
    ) |>
      select(-any_of(drop_col)) |>
      rename(ID = column("ID")) |>
      rename(Day = column("Day")) |>
      filter(grepl("139", ID)) |>
      mutate(across(ID, as.character)) |>
      mutate(ID = if_else(str_starts(ID, "139"),
        paste0("P", ID), ID
      ))

    assign(names(sources[i]), dat, pos = 1)
  }
  rm(ds, pos = 1)
}


calculate_metrics <- \() {
  for (i in seq_along(sources)) {
    assign("ds", names(sources[i]), pos = 1)
    dat <- get(ds) |>
      csi() |>
      swls() |>
      pprs() |>
      iri() |>
      ecr() |>
      gmsex() |>
      fsfi() |>
      iief()
    assign(names(sources[i]), dat, pos = 1)
  }
  rm(ds, pos = 1)
}


# Generic Helper Functions ------------------------------------------------

# Column name of first item/question
column <- \(x) {
  locations[[ds]] |>
    filter(name == x) |>
    pull(start)
}

# Item count for a scale
get_count <- \(x) {
  locations[[ds]] |>
    filter(name == x) |>
    pull(item_count)
}

# Range of columns belonging to a scale
get_range <- \(dat, name) {
  x <- which(names(dat) == column(name))
  y <- x + get_count(name) - 1
  c(x:y)
}


# Results for Scales
# Leaving "participant" and "column" blank will return data for
# all participants and all scales
# Vectors are allowed as input, e.g.,
# get_results(dat, c("P13902", "P13901"), c("CSI_4", "SWLS"))
get_results <- \(dat, participant = NA, column = NA) {
  if (is.logical(participant) && is.logical(column)) {
    results <- dat |> select(any_of(c(locations[[1]]$name)))
  } else if (!is.logical(participant) && !is.logical(column)) {
    results <- dat |>
      select(any_of(c("ID", column))) |>
      filter(ID == participant)
  } else if (!is.logical(column)) {
    results <- dat |> select(any_of(c("ID", column)))
  } else if (!is.logical(participant)) {
    results <- dat |>
      select(any_of(c(locations[[1]]$name))) |>
      filter(ID == participant)
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
  
  # Understanding subscale
  pprs_u <- x |> select(3:7)
  
  # Validation subscale
  pprs_v <- x |> select(8:12)
  
  dat <- dat |> mutate(PPRS_12 = rowSums(x), .after = max(range)) |> 
    mutate(PPRS_12_U = rowSums(pprs_u), .after = PPRS_12) |> 
    mutate(PPRS_12_V = rowSums(pprs_v), .after = PPRS_12)

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
    mutate(across(everything(), ~ . - 1)) |> 
    mutate(across(c(2, 6:8), ~ abs(. - 4)))

  # IRI-C: Empathic Concern scale
  iri_ec <- x |> select(c(1, 2, 4, 6, 8, 9, 11))

  # IRI-C: Perspective Taking scale
  iri_pt <- x |> select(!c(1, 2, 4, 6, 8, 9, 11))

  dat <- dat |>
    mutate(IRI_C = rowSums(x), .after = max(range)) |>
    mutate(IRI_C_EC = rowSums(iri_ec), .after = IRI_C) |>
    mutate(IRI_C_PT = rowSums(iri_pt), .after = IRI_C)

  return(dat)
}

# Experiences in Close Relationship Scale (ECR-S)
ecr <- \(dat) {
  range <- get_range(dat, "ECR_S")
  x <- dat |> select(all_of(range))

  # Reverse code items 1, 5, 8, and 9
  x <- x |> mutate(across(c(1, 5, 8, 9), ~ abs(. - 8)))
  
  # Attachment Anxiety subscale
  ecr_an <- x |> select(c(2, 4, 6, 8, 10, 12))
  
  # Attachment Avoidance subscale
  ecr_av <- x |> select(!c(2, 4, 6, 8, 10, 12))

  dat <- dat |>
    mutate(ECR_S = rowSums(x), .after = max(range)) |>
    mutate(ECR_S_AN = rowSums(ecr_an), .after = ECR_S) |>
    mutate(ECR_S_AV = rowSums(ecr_av), .after = ECR_S)

  return(dat)
}

# Global Measure of Sexual Satisfaction (GMSEX)
gmsex <- \(dat) {
  range <- get_range(dat, "GMSEX")
  x <- dat |> select(all_of(range))

  # Reverse code all items
  x <- x |> mutate(across(everything(), ~ abs(. - 8)))

  dat |> mutate(GMSEX = rowSums(x), .after = max(range))
}

# Female Sexual Function Index (FSFI)
fsfi <- \(dat) {
  range <- get_range(dat, "FSFI")
  x <- dat |>
    #   filter(Q4 == 1) |>
    select(all_of(range))


  x <- x |>
    mutate(across(
      c(15, 16, 29, 30),
      # Reverse code 1:5 --> 5:1
      ~ abs(. - 6)
    )) |>
    mutate(across(
      c(17:21, 23, 25, 27, 29),
      # Reverse and recode "no sex. activity" as 0
      # 1:6 --> 0, 5:1
      \(.) case_when(
        . == 1 ~ 0,
        .default = abs(. - 7)
      )
    )) |>
    mutate(across(
      c(22, 24, 26, 31, 32, 33),
      # Minus one
      ~ . - 1
    ))

  # Calculate domains (subscales):
  # Desire[D], Arousal[A], Lubrication[L], Orgasm[O], Satisfaction[S], Pain[P]
  x <- x |>
    mutate(FSFI_D = (x[[1]] + x[[2]]) * 0.6) |>
    mutate(FSFI_A = rowSums(x[3:6]) * 0.3) |>
    mutate(FSFI_L = rowSums(x[7:10]) * 0.3) |>
    mutate(FSFI_O = rowSums(x[11:13]) * 0.4) |>
    mutate(FSFI_S = rowSums(x[14:16]) * 0.4) |>
    mutate(FSFI_P = rowSums(x[17:19]) * 0.4)

  x <- x |> mutate(FSFI = rowSums(pick(20:25)), .after = 19)
  fsfi <- x |> select(contains("FSFI"))

  dat |> add_column(fsfi, .after = max(range))
}


# International Index of Erectile Function (IIEF)
iief <- \(dat) {
  range <- get_range(dat, "IIEF")
  x <- dat |>
    #   filter(Q4 == 1) |>
    select(all_of(range))


  x <- x |>
    mutate(across(
      c(45:49),
      # Reverse code 1:5 --> 5:1
      ~ abs(. - 6)
    )) |>
    mutate(across(
      c(35:38, 41:44),
      # Reverse and recode "no sex. activity" from 1 to 0
      # 1:6 --> 0, 5:1
      \(.) case_when(
        . == 1 ~ 0,
        .default = abs(. - 7)
      )
    )) |>
    mutate(across(
      c(39, 40),
      # Minus one
      ~ . - 1
    ))

  # Calculate domains (subscales):
  # Erectile Function[E], Orgasmic Function[OF], Sexual Desire[S],
  # Intercourse Satisfaction[I], Overall Satisfaction[OS]
  x <- x |>
    mutate(IIEF_E = rowSums(x[1:5]) + x[[15]]) |>
    mutate(IIEF_OF = rowSums(x[9:10])) |>
    mutate(IIEF_S = rowSums(x[11:12])) |>
    mutate(IIEF_I = rowSums(x[6:8])) |>
    mutate(IIEF_OS = rowSums(x[13:14]))

  x <- x |> mutate(IIEF = rowSums(pick(16:20)), .after = 15)
  iief <- x |> select(contains("IIEF"))

  dat |> add_column(iief, .after = max(range))
}
