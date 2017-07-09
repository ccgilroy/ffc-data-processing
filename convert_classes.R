summarize_class_info <- function(data) {
  # evaluates the class distribution of variables in a data frame
  # use to assess results of class conversion functions
  summary(as.factor(vapply(data, class, character(1))))
}

# character variables ----

character_to_numeric <- function(data) {
  # characters with all-numeric values that include noninteger values are 
  # converted to numerics. 
  cols_in_order <- names(data)
  numeric_vars <- get_vars_char_decimal(data)
  d1 <- data %>% select(-one_of(numeric_vars))
  d2 <- data %>% select(one_of(numeric_vars)) %>% mutate_all(as.numeric)
  bind_cols(d1, d2) %>% select(one_of(cols_in_order))
}

character_to_factor <- function(data) {
  # characters with string values that can't be numeric are converted to factors
  # this includes censored variables that would otherwise be numeric
  # (e.g., an age variable with an "18 and younger" category)
  cols_in_order <- names(data)
  factor_vars <- get_vars_char_nonnumeric(data)
  d1 <- data %>% select(-one_of(factor_vars))
  d2 <- data %>% select(one_of(factor_vars)) %>% mutate_all(as.factor)
  bind_cols(d1, d2) %>% select(one_of(cols_in_order))
}

character_to_factor_or_numeric <- function(data, cutoff = 100) {
  ## characters with many unique values are likely to be continuous
  ## how many is 'many'? 50? 100?
  ## what about censored values? those get handled with character_to_factor
}

# labelled variables ----

labelled_to_factor <- function(data) {
  # converts labeled variables that are likely categorical to factors
  # avoids use of mutate_if or mutate_at for speedup (with dplyr 0.7.1)
  cols_in_order <- names(data)
  factor_vars <- get_vars_labelled_factor(data)
  d1 <- data %>% select(-one_of(factor_vars))
  d2 <- data %>% select(one_of(factor_vars)) %>% haven::as_factor()
  bind_cols(d1, d2) %>% select(one_of(cols_in_order))
}

labelled_to_factor_SLOW <- function(data) {
  data %>% mutate_if(is_labelled_factor, haven::as_factor)
}

labelled_to_numeric <- function(data) {
  # converts labeled variables that are likely continuous to numeric
  # avoids use of mutate_if or mutate_at for speedup (with dplyr 0.7.1)
  cols_in_order <- names(data)
  numeric_vars <- get_vars_labelled_numeric(data)
  d1 <- data %>% select(-one_of(numeric_vars))
  d2 <- data %>% select(one_of(numeric_vars)) %>% mutate_all(as.numeric)
  bind_cols(d1, d2) %>% select(one_of(cols_in_order))
}

labelled_to_numeric_SLOW <- function(data) {
  ## roughly 10x slower than above version
  data %>% mutate_if(is_labelled_numeric, as.numeric)
}

