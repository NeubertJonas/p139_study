#### WORD ASSOCIATION TASK - Semantic Distance ####

# Purpose: Prepare raw data from the Word Association Task
# Author: Jonas Neubert (dev@jonaz.de)
# Generates four outcome variables:
# 1. First response
# 2. Last response
# 3. Chain score
# 4. Forward flow

##### PREPARATION #####
# Set RStudio working directory to file location
setwd(dirname(rstudioapi::getActiveDocumentContext()$path))

# Load the other R files
# This will likely include the installation of new packages
source("prepare_data.r")
source("chain_score.r")
source("forward_flow.r")

# Export raw data as csv files, one per seed word.
# Columns: Participant, Session, 1, 2, ..., n (responses)
# Please make sure no additional columns/data are present.

# Invalid/problematic responses, e.g., proper nouns (Austria, Netflix), etc.
# should be marked beforehand by placing a single asterisk (*)
# in front of the offending response.
# This way the response will be identified by the code and properly dealt with.

# Correctly define seed words and file names below:
files <- tribble(
  ~seed, ~filename,
  "snow", "snow.csv",
  "candle", "candle.csv",
  "table", "table.csv",
  "paper", "paper.csv",
  "bear", "bear.csv",
  "toaster", "toaster.csv"
)

##### PART 1: FIRST, LAST, and CHAIN RESPONSE #####

# The three functions below output csv files to the directory.
# first_response.csv; last_response.csv; chain_response.csv
# Those are ready to be upload to SemDis
# In order to calculate semantic distances for
# the first response, last response, and all neighboring words
# http://semdis.wlu.psu.edu

first_response()
last = last_response()
chain_response()

# Bonus: The functions silently return tibbles containing the data
# In case you wish to continue working with them in R,
# you can simple assign them to variable. For example,
# chain <- chain_response()

##### PART 2: CHAIN SCORES #####

# Once you have uploaded chain_response.csv to SemDis,
# you can use the following code to further analyse the data.
# As SemDis only provides semantic distance scores for word pairs,
# you are likely interested in the mean & standard deviation
# for every word chain.

# Place the downloaded file in the same directory and
# make sure the variable below correctly refers to it.

filename <- "chain_responses_SemDis.csv"

# Two variants are offered.
# One uses all the data (exclude_invalid = FALSE)
# The other excludes data from word pairs, which
# were previously marked problematic/invalid (exclude_invalid = TRUE)
# Omitting the argument will run the default (exclude = TRUE)

# You can also run both as filenames of generated csv files are not identical.
# The suffix "_ex" identifies the output without the invalid words.

chain_stats(filename, exclude = FALSE)
chain_stats(filename, exclude = TRUE)


##### FORWARD FLOW #####
# Calculate forward flow statistics for responses

# Forward flow uses the same csv files defined in the files tibble above.
# It requires the installation of a few packages and
# a tidyverse API token linked to a Google account
# necessary for downloading the semantic spaces from Google Drive

# Define the semantic spaces you're interested in
spaces <- c("baroni", "cbow", "cbow_ukwac", "en100", "glove", "tasa")

# Creates a csv file ("forward_flow.csv"), which includes
# the mean forward flow (per participant and seed word) and
# its standard deviation

# Invalid responses are not included in the analysis.

export_forward_flow()

# The function silently returns a data frame with all the data. Useful, if
# you wanna have a look at the forward flow of individual responses.
# ff = export_forward_flow()