# Calculating Chain Scores


# Installing/loading required packages
if (!require("tidyverse")) install.packages("tidyverse")
library(tidyverse)


# Iterate through all participants and seed words
chain_stats <- function(filename, exclude = TRUE) {
  # Read csv file
  raw_data <- read_csv(filename, show_col_types = FALSE)
  rows <- nrow(raw_data)

  if (exclude) {
    raw_data <- filter(raw_data, valid == 1)
    ex <- rows - nrow(raw_data)
    rows <- nrow(raw_data)
  }

  # Calculate variables about the data
  # No. of participants
  n <- max(raw_data["id"])

  # Init. vector to store returned tibbles
  # More efficient to later bind those together rather than
  # growing them in a for loop

  data_list <- vector(mode = "list", length = n)

  for (i in 1:n) {
    data_list[i] <- list(score_participant(raw_data, i))
  }

  # Optimized code written by ChatGPT
  # data_list <- lapply(1:n, function(x) score_participant(raw_data, x))

  
  data <- bind_rows(data_list)
  if (exclude) {
    write_csv(data, "_output/SemDis_chain_stats_ex.csv")
    message(
      ex, " word pairs were excluded and ", rows,
      " word pairs were analysed."
    )
    message("File created: _output/SemDis_chain_stats_ex.csv")
    invisible(data)
  } else {
    write_csv(data, "_output/SemDis_chain_stats.csv")
    message(rows, " word pairs were analysed.")
    message("File created: _output/SemDis_chain_stats.csv")
    invisible(data)
  }
}

score_participant <- function(raw_data, p) {
  # List of seed words
  seeds <- unique(raw_data[["seed"]])
  # Init. vector to store results
  data_list <- vector(mode = "list", length = length(seeds))

  # Iterate through all seeds for one participant
  i <- 1
  for (s in seeds) {
    data_list[i] <- list(score_chain(raw_data, p, s))
    i <- i + 1
  }

  # Combine all elements of the list in a tibble and return
  data <- bind_rows(data_list)

  return(data)
}

# Optimized with ChatGPT / equivalent code for testing purposes
# score_participant = function(raw_data, p) {
#   # List of seed words
#   seeds = unique(raw_data[["seed"]])
#
#   # Combine all elements of the list in a tibble and return
#   data = bind_rows(
#     lapply(seeds, score_chain, raw_data = raw_data, p = p)
#   )
#
#   return(data)
# }


score_chain <- function(raw_data, p, s) {
  # Filter for one participant and seed
  chain <- filter(raw_data, id == p & seed == s)

  # Two edge cases need to be considered:
  # One, missing data (participant did not do this task)
  # Two, double data (they were given the same prompt during both sessions)
  # Examples: Participant 4 and 14

  n_sessions <- unique(chain[["session"]])
  n_sessions <- length(n_sessions)

  # Missing data
  if (n_sessions == 0) {
    data <- tribble(
      ~id, ~session, ~seed,
      p, NA, s
    )
    return(data)
  } else if (n_sessions == 2) {
    # Edge case with double data
    # Not the prettiest code, but hopefully won't run very often

    data_1 <- tribble(
      ~id, ~session, ~seed,
      p, 1, s
    )
    chain_1 <- filter(raw_data, id == p & seed == s & session == 1)
    scores_1 <- get_scores(chain_1)
    data_1 <- bind_cols(data_1, scores_1)

    data_2 <- tribble(
      ~id, ~session, ~seed,
      p, 2, s
    )
    chain_2 <- filter(raw_data, id == p & seed == s & session == 2)
    scores_2 <- get_scores(chain_2)
    data_2 <- bind_cols(data_2, scores_2)

    data <- bind_rows(data_1, data_2)
    return(data)
  }


  data <- tribble(
    ~id, ~session, ~seed,
    p, chain[[1, "session"]], s
  )

  scores <- get_scores(chain)
  data <- bind_cols(data, scores)

  return(data)
}

get_scores <- function(chain) {
  # Extract scores
  score <- chain %>% select(starts_with("SemDis"))

  # Initialize variables
  width <- ncol(score)
  columns <- vector(mode = "character", length = width * 2)
  old_columns <- vector(mode = "character", length = width)
  mean <- vector(mode = "numeric", length = width)
  sd <- vector(mode = "numeric", length = width)
  results <- vector(mode = "numeric", length = width * 2)

  for (i in 1:width) {
    old_columns[i] <- colnames(score[i])
    mean[i] <- mean(score[[i]], na.rm = TRUE)
    sd[i] <- sd(score[[i]], na.rm = TRUE)
  }

  # Reorder data for tibble
  i <- 1
  j <- 1
  for (c in old_columns) {
    columns[i] <- paste0("M_", c)
    results[i] <- mean[j]

    results[i + 1] <- sd[j]
    columns[i + 1] <- paste0("SD_", c)
    i <- i + 2
    j <- j + 1
  }

  data <- tibble(columns, results)
  data <- pivot_wider(data, names_from = columns, values_from = results)

  return(data)
}
