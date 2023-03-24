# RELATIONSHIP METRICS ----------------------------------------------------
#
# Calculate scores for standardized questionnaires
# recorded via Qualtrics.
#
# Questionnaires: CSI-4, SWLS, PPRS-12, IRI-C, ECR-S, GMSEX, FSFI, IIEF
#
# Load Packages -----------------------------------------------------------

# Set working directory to current file location
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
# Download files anywhere the working directory. No need to rename them.
#
# Script is designed for the following three Qualtrics surveys.
# "TrainingDay_baseline" -> baseline
# "Follow up" -> follow_up
# "At home questionnaire" -> home

# Automatically detect the three files.
files = list.files("./data_fake/", pattern = "[[:alnum:]]+.csv$", 
               full.names = TRUE, recursive = TRUE)
sources = c(
  baseline = files[grep("TrainingDay_Baseline", files, fixed = TRUE)],
  follow_up = files[grep("Follow+up", files, fixed = TRUE)],
  home = files[grep("At+home+questionnaire", files, fixed = TRUE)]
  )
rm(files)

# Alternatively, define files manually like so:
# sources <- c(
#   baseline = "data/baseline.csv",
#   follow_up = "data/follow_up.csv",
#   home = "data/home.csv"
# )

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
  "ID",        "Q1.2",    1,
  "Day",       "Q1.3",    1,
  "SWLS",      "Q2.1_1",  5,
  "CSI_4",     "Q3.1",    4,
  "IOS",       "Q1",      1,
  "GMSEX",     "Q4.1_1",  5
)

locations[["home"]] <- tribble(
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
    "StartDate", "EndDate", "Duration (in seconds)", "RecordedDate",
    "Status", "IPAddress", "Progress", "Finished",
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
  
  # Catch cases when questionnaire is not present
  # E.g., the PPRS_12 in the follow_up questionnaire
  if (identical(x, integer(0))) return(NA)
    
  y <- x + get_count(name) - 1
  c(x:y)
}

get_results <- \(dat, test, participant = "all", subscales = TRUE) {
  if (participant[1] == "all") participant = unique(dat[["ID"]])
  
  if (subscales) {
    dat |> filter(ID == participant) |> 
      select(ID | starts_with(test))
  } else {
    dat |> filter(ID == participant) |> 
      select(ID | eval(test))
  }
}

get_overview <- \(dat, basic = FALSE) {
  if (!basic) {
    dat |> select(!starts_with("Q"))
  } else {
    dat |>
      select(!starts_with("Q")) |>
      select(!ends_with(c(
        "_V",
        "_U",
        "_AV",
        "_AN",
        "_PT",
        "_EC",
        "_D",
        "_A",
        "_L",
        "_O",
        "_S",
        "_P",
        "_E",
        "_OF",
        "_I",
        "_OS"
      )))
  }
}

# Questionnaire Functions -------------------------------------------------
# Note. Scores for scales will be NA if any questions were skipped.

# Couple Satisfaction Index (CSI-4)
# Qualtrics records the lowest response as "1", but for scoring
# it is changed to "0".

csi <- \(dat) {
  range <- get_range(dat, "CSI_4")
  
  # Exit early if questionnaire is not found.
  if (is.na(range[1])) return(dat)
  
  x <- dat |> select(all_of(range))
  dat <- dat |> mutate(CSI_4 = rowSums(x) - 4, .after = max(range))

  return(dat)
}

# Satisfaction with Life Scale (SWLS)
swls <- \(dat) {
  range <- get_range(dat, "SWLS")
  if (is.na(range[1])) return(dat)
  
  x <- dat |> select(all_of(range))
  dat <- dat |> mutate(SWLS = rowSums(x), .after = max(range))

  return(dat)
}

# Perceived Partner Responsiveness Scale (PPRS)
pprs <- \(dat) {
  range <- get_range(dat, "PPRS_12")
  if (is.na(range[1])) return(dat)
  
  x <- dat |> select(all_of(range))

  # Understanding subscale
  pprs_u <- x |> select(3:7)

  # Validation subscale
  pprs_v <- x |> select(8:12)

  dat <- dat |>
    mutate(PPRS_12 = rowSums(x), .after = max(range)) |>
    mutate(PPRS_12_U = rowSums(pprs_u), .after = PPRS_12) |>
    mutate(PPRS_12_V = rowSums(pprs_v), .after = PPRS_12)

  return(dat)
}


# Interpersonal Reactivity Index for Couples (IRI-C)
iri <- \(dat) {
  range <- get_range(dat, "IRI_C")
  if (is.na(range[1])) return(dat)
  
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
  if (is.na(range[1])) return(dat)
  
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
  if (is.na(range[1])) return(dat)
  
  x <- dat |> select(all_of(range))

  # Reverse code all items
  x <- x |> mutate(across(everything(), ~ abs(. - 8)))

  dat |> mutate(GMSEX = rowSums(x), .after = max(range))
}

# Female Sexual Function Index (FSFI)
fsfi <- \(dat) {
  range <- get_range(dat, "FSFI")
  if (is.na(range[1])) return(dat)
  
  x <- dat |>
    select(all_of(range))


  x <- x |>
    mutate(across(
      c(1, 2, 15, 16),
      # Reverse code 1:5 --> 5:1
      ~ abs(. - 6)
    )) |>
    mutate(across(
      c(3:7, 9, 11, 13, 15),
      # Reverse and recode "no sex. activity" as 0
      # 1:6 --> 0, 5:1
      \(.) case_when(
        . == 1 ~ 0,
        .default = abs(. - 7)
      )
    )) |>
    mutate(across(
      c(8, 10, 12, 17, 18, 19),
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
  if (is.na(range[1])) return(dat)
  
  x <- dat |>
    select(all_of(range))

  x <- x |>
    mutate(across(
      c(11:15),
      # Reverse code 1:5 --> 5:1
      ~ abs(. - 6)
    )) |>
    mutate(across(
      c(1:4, 7:10),
      # Reverse and recode "no sex. activity" from 1 to 0
      # 1:6 --> 0, 5:1
      \(.) case_when(
        . == 1 ~ 0,
        .default = abs(. - 7)
      )
    )) |>
    mutate(across(
      c(5, 6),
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

# Combine all data in one tibble ------------------------------------------
import_data()
calculate_metrics()

baseline_2 <- get_overview(baseline) |> 
  mutate(Day = "0", .after = ID)


follow_up_2 <- get_overview(follow_up) |> 
  mutate(Day = paste(Day, "_FU1"))

home_2 <- get_overview(home) |> 
  mutate(Day = paste(Day, "_FU2"))

combination <- bind_rows(baseline_2, follow_up_2, home_2)

# Run Script --------------------------------------------------------------

# First, import the data:
import_data()
# You know have the raw data for baseline and follow_up questionnaires
# in the R environment as tibbles (special data tables from the tidyverse).

# Second, calculate all questionnaire scores and add them to those tibbles
calculate_metrics()
# The function goes through all scales and extracts their associated items.
# Then necessary calculations are performed. Mainly reverse coding or changing
# the range of responses from 1:6 to 0:5 for example. 
# Then subscales and final scores are calculated. The results are added back
# to the main tibbles in separate columns.

# Extracting Data Easily

# I provide two more functions to easily access the results. I added examples
# how to use them below.

# get_results() provides results for a specific test.
get_results(baseline, "PPRS_12")

# If you're only interested in one participant:
get_results(baseline, "PPRS_12", "P13901")

# Two or more participants:
get_results(baseline, "IRI_C", c("P13901", "P13902"))

# Without the subscales:
get_results(baseline, "IRI_C", c("P13901", "P13902"), subscales = FALSE)

# Two or more tests:
get_results(home, c("SWLS", "CSI_4", "ECR_S"))


# Use get_overview() to see all calculated scores at once.

baseline_o <- get_overview(baseline)
follow_up_o <- get_overview(follow_up)
home_o <- get_overview(home)

# Exclude subscales

get_overview(baseline, basic = TRUE)
get_overview(follow_up, basic = TRUE)

# Those two functions return a tibble, which can be saved and then used
# for further analysis.

overview <- get_overview(baseline, basic = TRUE)

# Print overview
print(overview)

# Print overview for participants 1 and 2
print(filter(overview, ID == "P13901" | ID == "P13902"))

