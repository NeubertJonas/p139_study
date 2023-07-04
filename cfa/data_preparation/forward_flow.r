# FORWARD FLOW

# Installing/loading required packages
if (!require("tidyverse")) install.packages("tidyverse")
if (!require("remotes")) install.packages("remotes")
if (!require("SemNeT")) remotes::install_github("AlexChristensen/SemNeT")

library(tidyverse)
library(SemNeT)

# Collect data from all csv files and prepare for forward_flow()
export_forward_flow <- function() {
  data <- mapply(calculate_ff,
    seed = files[["seed"]],
    filename = files[["filename"]],
    SIMPLIFY = FALSE
  )


  results <- bind_rows(data)

  # The for loop is equivalent to the mapply() function above,
  # but is less efficient
  #
  # data = vector(mode = "list", length = nrow(files))
  #
  # for(i in 1:length(files)) {
  #   data[i] = list(calculate_ff(files[[i,1]], files[[i,2]]))
  #
  # }
  # results = bind_rows(data)

  write_csv(results, "forward_flow.csv")

  invisible(results)
}

calculate_ff <- function(seed, filename) {
  # Adjust data format for forward_flow()
  # Take care of duplicate entries with suffixes,
  # rename columns, move IDs to row names, lowecase responses
  # replace answers starting with "*" with NA.
  raw_data <- read.csv(filename)
  raw_data[[1]] <- make.unique(as.character(raw_data[[1]]))
  raw_data <- raw_data %>%
    mutate(Session = seed) %>%
    rename(seed = Session) %>%
    column_to_rownames(var = "Participant") %>%
    mutate(across(.cols = everything(), tolower)) %>%
    mutate(across(.cols = everything(), 
                  function(x) ifelse(str_detect(x, "\\*"), "", x)))

  # Drop empty columns
  raw_data <- raw_data[!sapply(raw_data, function(x) all(is.na(x)))]

  # Forward flow
  ff <- forward_flow(
    response_matrix = raw_data,
    semantic_space = spaces,
    type = "fluency"
  )

  # Extracting the mean_flow and calculating standard deviation
  results <- read_csv(filename,
                      col_select = 1:2, show_col_types = FALSE)
  results["seed"] <- seed
  for (s in spaces) {
    results[paste0("M_", s)] <- ff[[s]][["mean_flow"]]

    for (i in seq_len(nrow(results))) {
      results[i, paste0("SD_", s)] <- sd(ff[[s]][["response_flow"]][[i]],
                                         na.rm = TRUE)
    }
  }

  return(results)
}
