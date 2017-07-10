# Data processing for the Fragile Families Challenge

Functions to facilitate working with the data set provided by the Fragile Families Challenge, with a focus on transforming the data into a form appropriate for statistical modeling. For more information on the challenge: fragilefamilieschallenge.org.

## Getting started

**Required packages:** This repo requires a number of [Tidyverse](http://tidyverse.org/) packages---dplyr, forcats, haven, labelled, readr, and stringr. In particular, both haven and labelled are essential for working with Stata files in R.

**Data:** You will need to sign up for the Fragile Families Challenge to obtain the Fragile Families data. Place the four data files in the `data/` subdirectory of this project.

**To run:** Run `init.R` to load packages, source all functions, and produce the outputs described in Examples 1 and 2.

### Example 1: minor data processing

**`process_data_minimal` does not address missingness.** You should remove unusable variables and decide how to address missing observations before using the resulting data set for modeling. The helper functions described below provide potential options.

### Example 2: significant data processing

**`process_data_maximal` makes theoretically unwarranted assumptions about missingness.** In particular, you should think about how to address valid skips (-6s) and possibly modify some of the helper functions before using the resulting data set in modeling.

## Helper functions

For more flexibility and control, you may want to access the provided helper functions directly.

- the `get_vars_*` functions
- the `recode_na_*` functions. As a rule, `recode_na_character` should *always* be run, to convert the string "NA" to proper `NA`s.
- the `subset_vars_*` functions are convenience wrappers around `dplyr::select` for ease of use with a `get_vars_*` function, e.g. `background %>% subset_vars_keep(get_vars_constructed)`.

## Notes about variables

### Character variables

The functions `character_to_*` in `convert_classes.R` attempt to address character variables.

In `background.dta`, roughly 3000 variables are of the `character` class rather than the `labelled` class. Approximately a third of these are unusable for statistical analysis due to missingness or lack of variation and can be safely discarded.

Of the rest, a few hundred can be clearly classified as either categorical (factors) or continuous (numeric). The vast majority, however, cannot be unambiguously classified programmatically.

By default, `character_to_factor_or_numeric` uses a very conservative threshold (100), and converts the large majority of these variables to factors. It would be reasonable to lower the threshold to 50 or 25 (29), but it is likely that a few categorical variables will then be inappropriately converted to numerics. A potentially viable alternative would be to handle those variables manually.

### Censored variables

In the Fragile Families data, some otherwise continuous variables are only partially observed. These are censored, with non-numeric values recorded for parts of their range. The variables can be left-censored, right-censored, or both.

For instance, for the variable `cm4age`, "Constructed - Mother's age (years)", the value 20 represents "20 and younger", and the value 50 represents "50 and older".

The data processing code generally converts these variables to factors. A good heuristic for finding these variables would be to look at categorical variables with large numbers of unique values, like so:

```{r}
variable_types %>%
  filter(variable_type == "categorical") %>%
  arrange(desc(unique_values))
```

Tobit models are a way of modeling censored dependent variables, but recommendations for censored independent variables are [cite Rigobon and Stoker 2007]

## TODO:
