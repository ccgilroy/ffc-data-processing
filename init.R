library(dplyr)
library(haven)
library(labelled)
library(readr)
library(stringr)

source("R/convert_classes.R")
source("R/get_vars.R")
source("R/process_data.R")
source("R/recode_na.R")
source("R/subset_vars.R")
source("R/summarize_variables.R")

background <- read_dta("data/background.dta")

background_processed <- process_data_minimal(background)
variable_types <- summarize_variables(background, background_processed)

if (!dir.exists("output")) dir.create("output")
write_csv(variable_types, "output/ffc_variable_types.csv")

train <- read_csv("data/train.csv")
ffc <- 
  background %>% 
  subset_vars_keep(get_vars_constructed) %>%
  process_data_maximal() %>%
  merge_train(train)
