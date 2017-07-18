# Data processing for the Fragile Families Challenge

Functions to facilitate working with the data set provided by the Fragile Families Challenge, with a focus on transforming the data into a form appropriate for statistical modeling. For more information on the challenge: http://www.fragilefamilieschallenge.org/.

Vignettes: [Example 1](https://ccgilroy.github.io/ffc-data-processing/vignettes/example1.html) [Example 2](https://ccgilroy.github.io/ffc-data-processing/vignettes/example2.html) [Integration with FFCRegressionImputation](https://ccgilroy.github.io/ffc-data-processing/vignettes/integration.html)

## Getting started

To use this code, clone this repository to your local machine: `git clone https://github.com/ccgilroy/ffc-data-processing.git`.

**Required packages:** This repository requires a number of [Tidyverse](http://tidyverse.org/) packages---`dplyr`, `forcats`, `haven`, `labelled`, `readr`, and `stringr`. In particular, both `haven` and `labelled` are essential for working with Stata files in R.

**Data:** You will need to sign up for the Fragile Families Challenge to obtain the Fragile Families data. Place the four data files in the `data/` subdirectory of this project.

**To run:** Run `source('init.R')` to load packages and source all functions. Run the vignettes to produce the outputs described in Examples 1 and 2 from `background.dta` and `train.csv`.

## Vignettes

These vignettes can each be run from the respective RMarkdown files in the `vignettes/` subdirectory.

### Example 1: minor data processing

[Example 1](https://ccgilroy.github.io/ffc-data-processing/vignettes/example1.html) turns all labelled variables into factors or numerics as appropriate. It leaves ambiguous character variables unaddressed. (Use `summarize_variable_classes` to see the results of these operations.)

In addition, it summarizes information about each variable's label, type, and number of unique values and records this in `output/ffc_variable_types.csv`. See the "Variable types" section below for more information about this csv file.

```
background <- read_dta("data/background.dta")
background_processed <- process_data_minimal(background)
variable_types <- summarize_variables(background, background_processed)
```

**`process_data_minimal` does not address missingness.** You should remove unusable variables and decide how to address missing observations before using the resulting data set for modeling. The helper functions described below provide potential options.

### Example 2: significant data processing

[Example 2](https://ccgilroy.github.io/ffc-data-processing/vignettes/example2.html) subsets to constructed variables, does more extensive data processing to handle missing values, character variables, and unusable variables, and merges the resulting data set with the outcomes in `train.csv`.

```
train <- read_csv("data/train.csv")
ffc <-
  background %>%
  subset_vars_keep(get_vars_constructed) %>%
  process_data_maximal() %>%
  merge_train(train)
```

**`process_data_maximal` makes theoretically unwarranted assumptions about missingness.** In particular, you should think about how to address valid skips (-6s) and possibly modify some of the helper functions before using the resulting data set in modeling.

### Integration with `FFCRegressionImputation`

An [extended vignette](https://ccgilroy.github.io/ffc-data-processing/vignettes/integration.html) demonstrates integration with the [FFCRegressionImputation](https://github.com/annafil/FFCRegressionImputation) package by Anna Filippova.

## Helper functions

The `process_data_*` functions are just wrappers around pipelines of data-transforming functions. If you aren't familiar with magrittr-style pipes (`%>%`), check out the Tidyverse vignette [here](http://magrittr.tidyverse.org/). The full pipeline for `process_data_maximal` is this:

```{r}
data %>%
  recode_na_character() %>%
  labelled_to_factor() %>%
  labelled_to_numeric() %>%
  character_to_factor() %>%
  character_to_numeric() %>%
  # use a less conservative threshold than default
  character_to_factor_or_numeric(threshold = 29) %>%
  recode_na_factor() %>%
  recode_na_numeric() %>%
  subset_vars_remove(get_vars_na) %>%
  subset_vars_remove(get_vars_unique)
```

As you can see, the pipeline functions abstract away implementation details while remaining reasonably descriptive about the overall process.

For more flexibility and control, you may want to access the provided helper functions directly. These functions may throw warnings (or, more rarely, errors) to suggest the order they should be run in.

- the `get_vars_*` functions return the *names* of variables satisfying particular criteria, as a character vector.
- the `recode_na_*` functions turn Stata labelled missing values into proper R `NA`s. As a rule, `recode_na_character` should *always* be run, to convert the string "NA" to proper `NA`s. The other functions (for factors, labelled, and numerics) should be run with caution, and possibly modified.
- the `subset_vars_*` functions are convenience wrappers around `dplyr::select` for ease of use with a `get_vars_*` function, e.g. `background %>% subset_vars_keep(get_vars_constructed)`.

## Notes about variables

### Variable types

`summarize_variables` produces a data frame wherein each observation is a variable. For each variable, various metadata are reported.

`label` is the Stata variable label from the original data frame. The variable label is generally more descriptive than the variable name about the question that was asked or the method of variable construction.

`unique_values` is the number of *non-NA* unique values that variable takes on. This value will be 0 if all observations are NA, and it will generally be larger for continuous variables and smaller for categorical variables.

`variable_type` represents a best guess at the level of measurement of each variable, which is a critical piece of information for appropriately treating a variable in a statistical model. Possible values are "categorical," "continuous," or "unknown." These are calculated from value labels and other distinguishing information. The other metadata in the data frame can be used to manually assess the validity of this classification.

The version of this data frame that is saved in `output/ffc_variable_types.csv` uses `process_data_minimal` and is conservative about assigning variables to types. As a result, approximately 2000 variables are listed as "unknown." You could use `process_data_maximal` instead to make reasonably accurate assignments for many of these variables.

### Character variables

The functions `character_to_*` in `convert_classes.R` attempt to address character variables.

In `background.dta`, roughly 3000 variables are of the `character` class rather than the `labelled` class. Approximately a third of these are unusable for statistical analysis due to missingness or lack of variation and can be safely discarded.

Of the rest, a few hundred can be clearly classified as either categorical (factors) or continuous (numeric). The vast majority, however, cannot be unambiguously classified programmatically.

By default, `character_to_factor_or_numeric` uses a very conservative threshold (100), and converts the large majority of these variables to factors. It would be reasonable to lower the threshold to 50 or 25, but it is likely that a few categorical variables will then be inappropriately converted to numerics. (`process_data_maximal` uses a threshold of 29.) A potentially viable alternative would be to handle those variables manually.

### Censored variables

In the Fragile Families data, some otherwise continuous variables are only partially observed. These are censored, with non-numeric values recorded for parts of their range. The variables can be left-censored, right-censored, or both.

For instance, for the variable `cm4age`, "Constructed - Mother's age (years)", the value 20 represents "20 and younger", and the value 50 represents "50 and older".

The data processing code generally converts these variables to factors. A good heuristic for finding these variables would be to look at categorical variables with large numbers of unique values, like so:

```{r}
variable_types %>%
  filter(variable_type == "categorical") %>%
  arrange(desc(unique_values))
```

Tobit models are a way of modeling censored dependent variables, but recommendations for using censored independent variables are less widespread. See Rigobon and Stoker 2007 for a discussion of censored independent variables.

## TODO:

- break out examples into vignettes with more detailed commentary
- write tests
- release as R package?
