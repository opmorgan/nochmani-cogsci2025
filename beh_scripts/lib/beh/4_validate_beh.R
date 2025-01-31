## Validate data for each subject (e.g., data/proc/sub-003/beh/beh_sub-003.csv):
## Check number of blocks of each condition (each of the 4 conditions should have 8 blocks)
## Check number of approach/avoidance trials in each block (should be 8 and 2)
## Check that each condition has the expected stimuli
## Throw an error if any validation checks are failed
requireNamespace("dplyr")
requireNamespace("stringr")
requireNamespace("testthat")
requireNamespace("cli")
source(here::here("lib", "beh", "3_read_beh_clean.R"))

validate_beh <- function(SUB_LABELS, verbose = TRUE) {
  for (sub_label in SUB_LABELS) {
    
    
    sub_pattern = stringr::str_c("beh_", sub_label, ".csv")
    beh_sub_path <- list.files(recursive = TRUE, include.dirs = TRUE, pattern = sub_pattern)
    ## sub-035 does not have 8 blocks of each condition (due to their aborted first run):
    ## Instead, they have:
    ## 8 approach-neg blocks, 
    ## 10 approach-pos trials,
    ## 7 avoid-neg blocks;
    ## 7 avoid-pos blacks.
    ## They passed all other validation checks.
    ## Skip their validation.
    if (sub_label == "sub-035") {
      if (verbose == TRUE) {
        cli::cli_alert_success(
          "Skipping validation for subject {sub_label} ({beh_sub_path}): This participant fails validation for number of blocks: They do not have 8 blocks of each condition, due to their first run being aborted (they pressed the squeezeball after a Windows Update notification appeared). Instead, they have: 8 approach-neg blocks, 10 approach-pos trials, 7 avoid-neg blocks; and 7 avoid-pos blacks. Their data passes all other validation checks.")
      }
      next
    ## Same for sub-199 and sub-217:
    } else if (sub_label == "sub-199") {
      if (verbose == TRUE) {
        cli::cli_alert_success(
          "Skipping validation for subject {sub_label} ({beh_sub_path}): This participant fails validation for number of blocks (the wrong sequence was run for their Run 2).")
      }
      next
      } else if (sub_label == "sub-217") {
      if (verbose == TRUE) {
        cli::cli_alert_success(
          "Skipping validation for subject {sub_label} ({beh_sub_path}): This participant fails validation for number of blocks (they used both hands in Run 1).")
      }
      next
    } else {
      
      beh_sub <- read_beh_clean(beh_sub_path)
      if (verbose == TRUE) {
        cli::cli_alert_success(
          "Validating behavioral data for subject {sub_label} ({beh_sub_path})...")
      }
      
      ## (1) Count approach and avoidance trials in each block
      
      ## Each block should have ten trials
      beh_sub |>
        dplyr::group_by(num_block) |>
        dplyr::count() |> 
        _$n |> 
        testthat::expect_equal(
          rep(10, 32), info = "One or more blocks does not have exactly 10 trials.")
      
      ## Each block should have two catch trials.
      beh_sub |> 
        dplyr::filter(catch == TRUE) |> 
        dplyr::group_by(num_block) |> 
        dplyr::count() |> 
        _$n |> 
        testthat::expect_equal(
          rep(2, 32), info = "One or more blocks does not have exactly two catch trials.")
      
      ## And each block should have eight non-catch trials.
      beh_sub |> 
        dplyr::filter(catch == FALSE) |> 
        dplyr::group_by(num_block) |> 
        dplyr::count() |> 
        _$n |> 
        testthat::expect_equal(
          rep(8, 32), info = "One or more blocks does not have exactly eight non-catch trials.")
      
      ## There should be 8 blocks of each of the four conditions
      beh_sub |>
        dplyr::group_by(condition, num_block) |> 
        dplyr::count() |> 
        dplyr::group_by(condition) |> 
        dplyr::count() |> 
        _$n |> 
        testthat::expect_equal(
          rep(8, 4), info = "One or more conditions does not have exactly 8 blocks.")
      
      ## Each "approach" block should have 8 approach and 2 avoid trials
      beh_sub |> 
        dplyr::filter(condition_mot == "approach") |> 
        dplyr::group_by(num_block, mot) |> 
        dplyr::filter(mot == "approach") |> 
        dplyr::count() |> 
        _$n |> 
        all_equal_n(n = 8) |> 
        testthat::expect_true(info = "One or more approach blocks does not have exactly 8 approach trials.")
      
      beh_sub |> 
        dplyr::filter(condition_mot == "approach") |> 
        dplyr::group_by(num_block, mot) |> 
        dplyr::filter(mot == "avoid") |> 
        dplyr::count() |> 
        _$n |> 
        all_equal_n(n = 2) |> 
        testthat::expect_true(info = "One or more approach blocks does not have exactly 2 avoid trials.")
      
      ## Each "avoid" block should have 8 avoid and 2 approach trials.
      beh_sub |> 
        dplyr::filter(condition_mot == "avoid") |> 
        dplyr:: group_by(num_block, mot) |> 
        dplyr:: filter(mot == "avoid") |> 
        dplyr::count() |> 
        _$n |> 
        all_equal_n(n = 8) |> 
        testthat::expect_true(info = "One or more approach blocks does not have exactly 8 avoid trials.")
      
      beh_sub |> 
        dplyr::filter(condition_mot == "avoid") |> 
        dplyr::group_by(num_block, mot) |> 
        dplyr::filter(mot == "approach") |> 
        dplyr::count() |> 
        _$n |> 
        all_equal_n(n = 2) |> 
        testthat::expect_true(info = "One or more approach blocks does not have exactly 2 approach trials.")
      
      ## Each "pos" block should have 9 "pos" trials and 1 "neg" trial
      beh_sub |> 
        dplyr::filter(condition_val == "pos") |> 
        dplyr::group_by(num_block, val) |> 
        dplyr::filter(val == "pos") |> 
        dplyr::count() |> 
        _$n |> 
        all_equal_n(n = 9) |> 
        testthat::expect_true(info = "One or more pos blocks does not have exactly 9 pos trials.")
      
      beh_sub |> 
        dplyr::filter(condition_val == "pos") |> 
        dplyr::group_by(num_block, val) |> 
        dplyr::filter(val == "neg") |> 
        dplyr::count() |> 
        _$n |> 
        all_equal_n(n = 1) |> 
        testthat::expect_true(info = "One or more pos blocks does not have exactly 1 neg trials.") 
      
      ## Each "neg" block should have 9 "neg" trials and 1 "pos" trial
      beh_sub |> 
        dplyr::filter(condition_val == "neg") |> 
        dplyr::group_by(num_block, val) |> 
        dplyr::filter(val == "neg") |> 
        dplyr::count() |> 
        _$n |> 
        all_equal_n(n = 9) |> 
        testthat::expect_true(info = "One or more neg blocks does not have exactly 9 neg trials.")
      
      beh_sub |> 
        dplyr::filter(condition_val == "neg") |> 
        dplyr:: group_by(num_block, val) |> 
        dplyr::filter(val == "pos") |> 
        dplyr::count() |> 
        _$n |> 
        all_equal_n(n = 1) |> 
        testthat::expect_true(info = "One or more neg blocks does not have exactly 1 pos trials.")   
      
      ## Each "approach-pos" trial has a cake
      beh_sub |> 
        dplyr::filter(mot == "approach" & val == "pos") |> 
        _$stim_name |> 
        stringr::str_starts("cake") |> 
        all_equal_n(n = TRUE) |> 
        testthat::expect_true(info =  "Not all approach-pos trials have cake stimuli")
      
      ## Each "approach-neg" trials has an insect
      beh_sub |> 
        dplyr::filter(mot == "approach" & val == "neg") |> 
        _$stim_name |> 
        stringr::str_starts("insect") |> 
        all_equal_n(n = TRUE) |> 
        testthat::expect_true(info =  "Not all approach-neg trials have insect stimuli")  
      
      ## Each "avoid-pos" trial has a meat
      beh_sub |> 
        dplyr::filter(mot == "avoid" & val == "pos") |> 
        _$stim_name |> 
        stringr::str_starts("meat") |> 
        all_equal_n(n = TRUE) |> 
        testthat::expect_true(info =  "Not all avoid-pos trials have meat stimuli")
      
      ## Each "avoid-neg" trial has a fungus
      beh_sub |> 
        dplyr::filter(mot == "avoid" & val == "neg") |> 
        _$stim_name |> 
        stringr::str_starts("fungus") |> 
        all_equal_n(n = TRUE) |> 
        testthat::expect_true(info =  "Not all avoid-neg trials have fungus stimuli")
    }
    
    if (verbose == TRUE) {
      cli::cli_alert_success(
        "Validated behavioral data for subject {sub_label} ({beh_sub_path}).")
    }
  }
}