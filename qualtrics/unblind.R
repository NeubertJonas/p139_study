# UNBLIND QUESTIONNAIRE RESULTS -------------------------------------------
#
# Define the order for participants for whom data collection is finalized.
# Will export a csv and Excel file with unblinded data.
#
# Setup ------------------------------------------------------------------

# Set working directory to current file location (or use RStudio UI)
if (inherits(try(find.package("rstudioapi"), silent = TRUE), "try-error")) {
  install.packages("rstudioapi")
}
setwd(dirname(rstudioapi::getActiveDocumentContext()$path))

if (!require(openxlsx)) install.packages("openxlsx")

source("relationship_metrics.R")

# Define Order ------------------------------------------------------------

# LSD first, Placebo second
# Update the list of participant IDs
# Put IDs in double quotation marks and seperate them by comma
# No comma after the last item

lsd_first <- c(
  "P13903", "P13904", # Couple 2
  "P13913", "P13914" # Couple 5
)


# Placebo first, LSD second

placebo_first <- c(
  "P13901", "P13902", # Couple 1
  "P13907", "P13908"  # Couple 4
)

# Unblind Data ------------------------------------------------------------

unblind <- \() {
  placebo <- results |>
    filter(ID %in% placebo_first) |>
    mutate(across(
      Day,
      \(.) case_when(
        . == "SA_2a_lab" ~ "SA_Placebo_lab",
        . == "SA_2b_home" ~ "SA_Placebo_home",
        . == "SA_4a_lab" ~ "SA_LSD_lab",
        . == "SA_4b_home" ~ "SA_LSD_home",
        .default = .
      )
    ))

  lsd <- results |>
    filter(ID %in% lsd_first) |>
    mutate(across(
      Day,
      \(.) case_when(
        . == "SA_2a_lab" ~ "SA_LSD_lab",
        . == "SA_2b_home" ~ "SA_LSD_home",
        . == "SA_4a_lab" ~ "SA_Placebo_lab",
        . == "SA_4b_home" ~ "SA_Placebo_home",
        .default = .
      )
    ))

  bind_rows(placebo, lsd)
}


# Export Data -------------------------------------------------------------

unblinded <- unblind()

# As csv files
write_csv(unblinded,
          paste0("_output/relationship_metrics_unblinded_", Sys.Date(), ".csv"))

# As Excel sheet (formatting is a bit nicer)
h_style <- createStyle(fgFill = "lightblue", textDecoration = "bold", halign = "center")

write.xlsx(unblinded,
           file = paste0("_output/relationship_metrics_unblinded_", Sys.Date(), ".xlsx"),
           colWidths = list(c(9, 15, rep(10, 25))),
           borders = "all",
           borderColour = "grey",
           headerStyle = h_style
)

