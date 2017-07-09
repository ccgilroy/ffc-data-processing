# TODO: rewrite recode_na_* to avoid mutate_if ----
# separate recode_na_* into separate file

cols_in_order <- names(data)
numeric_vars <- get_vars_char_decimal(data)
d1 <- data %>% select(-one_of(numeric_vars))
d2 <- data %>% select(one_of(numeric_vars)) %>% mutate_all(as.numeric)
bind_cols(d1, d2) %>% select(one_of(cols_in_order))

recode_na_labelled <- function(data) {
  cols_in_order <- names(data)
  labelled_vars <- get_vars_labelled(data)
  d1 <- data %>% select(-one_of(labelled_vars)) 
  d2 <- data %>% select(one_of(labelled_vars))
  d2[d2 < 0] <- NA
  bind_cols(d1, d2) %>% select(one_of(cols_in_order))
}

recode_na_factor <- function(data) {
  ## NOTE:
  ## there are some rare labels, like "-12 Still breastfeed" and 
  ## "-11 >12 hours" for specific questions
  ## -10, in particular, has a variety of possible labels
  ## these are not handled by this recoding function
  
  get_vars_continuous()
  d1 <- df
  
  data %>%
    mutate_if(is.factor, function(x) { 
      fct_recode(x, 
                 NULL = "-9 Not in wave",
                 NULL = "-8 Out of range", 
                 NULL = "-7 N/A",
                 NULL = "-6 Skip", 
                 NULL = "-5 Not asked",
                 NULL = "-4 Multiple ans",
                 NULL = "-3 Missing", 
                 NULL = "-2 Don't know", 
                 NULL = "-1 Refuse")
    })
}

recode_na_numeric <- function(data) {
  data %>%
    mutate_if(is.numeric, function(x) ifelse(x < 0, NA, x))
}

recode_na_character <- function(data) {
  data %>%
    mutate_if(is.character, function(x) ifelse(x == "NA", NA, x))
}

recode_na_all <- function(data) {
  # faster than mutate_if
  
  factor_nas <- c("-9 Not in wave",
                  "-8 Out of range", 
                  "-7 N/A",
                  "-6 Skip", 
                  "-5 Not asked",
                  "-4 Multiple ans",
                  "-3 Missing", 
                  "-2 Don't know", 
                  "-1 Refuse")
  
  # character
  # data[is.character(data) && data == "NA"] <- NA
  data[data == "NA"] <- NA
  
  # numeric and labelled
  data[data < 0] <- NA
  
  # factor
  data[data %in% factors_nas] <- NA
  
  data
}