library(dplyr)
library(forcats)
library(haven)
library(labelled)
library(readr)
library(stringr)

source("R/convert_classes.R")
source("R/get_vars.R")
source("R/merge_train.R")
source("R/process_data.R")
source("R/recode_na.R")
source("R/subset_vars.R")
source("R/summarize_variables.R")

background <- read_dta("data/background.dta")

# example 1 ----
# process all variables, leaving ambiguous variables as characters
# does not handle missing values, does not remove any variables
# then summarize variable type information and write to csv

background_processed <- process_data_minimal(background)
variable_types <- summarize_variables(background, background_processed)

if (!dir.exists("output")) dir.create("output")
write_csv(variable_types, "output/ffc_variable_types.csv")

# example 2 ----
# subset to constructed variables
# process by converting all variables, removing all NAs,
# and removing variables that are unusable for modeling
# then merge with train

train <- read_csv("data/train.csv")
ffc <- 
  background %>% 
  subset_vars_keep(get_vars_constructed) %>%
  process_data_maximal() %>%
  merge_train(train)
