#### SemDis Data Preparation ####
# Code used to prepare data in csv files

# Install tidyverse package if missing and load it
# The package is required to work with tibbles
if (!require("tidyverse")) install.packages("tidyverse")
library(tidyverse)


# Check if files are present
check_files <- function() {
  for (i in seq_len(nrow(files))) {
    if (!file.exists(files[[i, 2]])) {
      stop("Unable to locate ", files[[i, 2]],
        "\nFile missing or not named correctly?",
        call. = FALSE
      )
    }
  }
}

##### VALID RESPONSES #####
# Some responses are not considered valid for the task.
# This includes, among others, proper nouns such as Austria, Netflix, etc.
# Words like these have to be manually identified before importing the data.
# To do this please add a single dash (-) in front of the invalid response.
# "Austria" changes to "-Austria".
# This way the R script can easily identify those words and assign a variable.
# The variable "valid" is defined as 1=valid and 0=invalid
# Later statistical analysis can then be run either with or without those words.
# (The dash is automatically removed by the script)

check_validity <- function(data) {
  if (grepl("\\*", data[, "response"]) || grepl("\\*", data[, "item"])) {
    data <- mutate(data, valid = 1)

    for (i in seq_len(nrow(data))) {
      if (startsWith(data[[i, "item"]], "*")) {
        data[[i, "valid"]] <- 0
        data[[i, "item"]] <- gsub("*", "", data[[i, "item"]],
                                  fixed = TRUE)
      }
      if (startsWith(data[[i, "response"]], "*")) {
        data[[i, "valid"]] <- 0
        data[[i, "response"]] <- gsub("*", "", data[[i, "response"]],
                                      fixed = TRUE)
      }
    }

    n <- sum(data$valid == 0)
    if (n != 0) {
      message(n, " word pairs are problematic/invalid. Consider exclusion.")
    }
  } else {
    data <- mutate(data, valid = 1)
  }

  return(data)
}

##### FIRST RESPONSE #####
# Create word pairs consisting of the seed word and the first response

# Create tibble in the correct format for SemDis, add data by calling
# the function add_first_response() for each seed word,
# then check validity, save csv file
# (if "first_response.csv" is already present, it will be overwritten),
# and (invisibly) return the tibble

first_response <- function() {
  check_files()

  data <- tribble(
    ~id, ~session, ~valid, ~item, ~response
  )

  for (i in seq_len(nrow(files))) {
    data <- add_first_response(data, files[[i, 1]], files[[i, 2]])
  }
  data <- check_validity(data)

  write_csv(data, "first_response.csv")
  message("File created: first_response.csv")

  invisible(data)
}

# This function opens the csv file, extracts the first response,
# adds them to the tibble, and returns the tibble

add_first_response <- function(data, seed, filename) {
  raw_data <- read_csv(filename, col_select = 1:3,
                show_col_types = FALSE, name_repair = "minimal")

  # Initialize vectors
  rows <- nrow(raw_data)
  id <- vector(mode = "integer", length = rows)
  session <- vector(mode = "integer", length = rows)
  item <- rep(seed, rows)
  response <- vector(mode = "character", length = rows)

  # Fill vectors with data
  for (i in seq_len(nrow(raw_data))) {
    id[i] <- raw_data[[i, 1]]
    session[i] <- raw_data[[i, 2]]
    response[i] <- raw_data[[i, 3]]
  }

  # Add them to tibble and then return
  data <- add_row(data,
                  id = id,
                  session = session,
                  item = item,
                  response = response)

  invisible(data)
}

##### LAST RESPONSE #####
# Create word pairs consisting of
# the seed word and the last response in the chain

last_response <- function() {
  check_files()

  data <- tribble(
    ~id, ~session, ~word_count, ~item, ~response
  )

  for (i in seq_len(nrow(files))) {
    data <- add_last_response(data, files[[i, 1]], files[[i, 2]])
  }

  # Not necessary anymore
  # If the last word is invalid, it is replaced by the next valid word
  # data <- check_validity(data)

  write_csv(data, "last_response.csv")
  message("File created: last_response.csv")

  invisible(data)
}

# This function opens the csv file, extracts the last response,
# adds them to the tibble, and returns the tibble

add_last_response <- function(data, seed, filename) {
  raw_data <- read_csv(filename,
                show_col_types = FALSE, name_repair = "minimal")

  # Initialize vectors
  rows <- nrow(raw_data)
  id <- vector(mode = "integer", length = rows)
  session <- vector(mode = "integer", length = rows)
  word_count <- vector(mode = "integer", length = rows)
  item <- rep(seed, rows)
  response <- vector(mode = "character", length = rows)

  # Fill vectors with data
  for (i in seq_len(nrow(raw_data))) {
    id[i] <- raw_data[[i, 1]]
    session[i] <- raw_data[[i, 2]]

    # Convert row to vector and remove NA
    y <- as.vector(raw_data[i, ])
    y <- y[!is.na(y)]

    # Subtract the first two columns
    word_count[i] <- length(y) - 2
    last_response <- last(y)
    
    # If the last word is invalid, go backwards until
    # a valid word is found
    j = -2
    while (grepl("\\*", last_response)) {
      last_response <- nth(y, j)
      word_count[i] <- word_count[i] - 1
      j = j - 1
    }


    if (!is.character(last_response)) {
      stop(
        "Integer cannot be added accepted as valid response.\n",
        "Please check ", filename, " for any additional columns on the right."
      )
    }
    response[i] <- last_response
  }

  # Add them to tibble and then return
  data <- add_row(data,
    id = id,
    session = session,
    word_count = word_count,
    item = item,
    response = response
  )

  return(data)
}


##### CHAIN RESPONSES #####
# SemDis only allows for pairwise comparisons between words to calculate
# the semantic distance. Thus, all the chains need to be reformatted from
# being in a single row to two words per row. The scores of all pairwise
# comparisons can then be averaged to calculate a chain score.
# (The chain score can be calculated automatically
# with the script "chain_score.r")

# Words are again checked for validity
# (see variable "valid" and explanation above)
# Given the conversion of the data in a long format,
# the position of a pairwise comparison within their chain is also
# recorded in the column "pair".
# (Might be interesting to analyse how the semantic distance
# score "develops" within the chain)

# For loop through the seed words
chain_response <- function() {
  check_files()

  master_list <- vector(mode = "list", length = nrow(files))

  for (i in seq_len(nrow(files))) {
    master_list[i] <- list(build_chain(files[[i, 1]], files[[i, 2]]))
  }

  output <- bind_rows(master_list)
  output <- check_validity(output)

  write_csv(output, "chain_response.csv")
  message("File created: chain_response.csv")

  invisible(output)
}

# Loop through the rows
build_chain <- function(seed, filename) {
  raw_data <- read_csv(filename,
                       show_col_types = FALSE, name_repair = "minimal")

  data_list <- vector(mode = "list", length = nrow(raw_data))

  for (r in seq_len(nrow(raw_data))) {
    data_list[r] <- list(follow_chain(
      raw_data, r,
      raw_data[[r, 1]], raw_data[[r, 2]], seed
    ))
  }
  data <- bind_rows(data_list)

  return(data)
}

# Loop through the chains/columns
follow_chain <- function(raw_data, row, id, session, seed) {
  # Initialize empty tibble
  data <- tribble(
    ~id, ~session, ~valid, ~pair, ~seed, ~item, ~response
  )

  # Prepare chain as vector (remove NA, drop first two columns)
  chain <- as.vector(raw_data[row, ], mode = "character")
  chain <- chain[!grepl("NA", chain, fixed = TRUE)]
  chain <- chain[!is.na(chain)]
  chain <- chain[c(-1, -2)]

  chain_length <- length(chain)

  # Initialize vectors
  id <- rep(as.numeric(id), chain_length)
  session <- rep(as.numeric(session), chain_length)
  pair <- 1:chain_length
  seed_list <- rep(as.character(seed), chain_length)
  item <- vector(mode = "character", length = chain_length)
  response <- vector(mode = "character", length = chain_length)

  # First word pair is special because it references the seed word
  item[1] <- seed
  response[1] <- chain[1]

  # Add the other word pairs
  # Catch exception if only one response has been provided
  if (chain_length >= 2) {
    for (i in 2:chain_length) {
      item[i] <- chain[i - 1]
      response[i] <- chain[i]
    }
  }

  data <- add_row(data,
    id = id,
    session = session,
    pair = pair,
    seed = seed_list,
    item = item,
    response = response
  )

  return(data)
}
