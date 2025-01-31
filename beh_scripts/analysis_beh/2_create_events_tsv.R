requireNamespace("here")
requireNamespace("tidyverse")
library(readr)
requireNamespace("gt")
requireNamespace("testthat")
requireNamespace("cli")

source(here::here("lib", "util.R"))

source(here::here("lib", "beh", "0_read_subjects_tsv.R"))
source(here::here("lib", "beh", "3_read_beh_clean.R"))

## config
DATA_RAW_DIR <- here::here("data", "raw")
DATA_PROC_DIR <- here::here("data", "proc")
DEBUG <- FALSE
VERBOSE = TRUE

DO_NOCHMANI = TRUE
DO_TAP = TRUE

## Load participants list
subjects <- read_subjects_tsv(here::here("data", "subjects.tsv"))
SUB_LABELS <- subjects$participant_id


#### Create events file for fMRI analysis

## Nochmani task

# -   Create event description file for each run with three columns: onset (s), duration (s), trial_type (approach, avoid, baseline)
# -   Name them like this: sub-003_task-nochmani_run-01_events.tsv


if (DO_NOCHMANI == TRUE) {
  TASK_LABEL = "nochmani"
  
  for (sub_label in SUB_LABELS) {
    if (VERBOSE == T) {
      cli::cli_alert_success("Creating {TASK_LABEL} task events.tsv files for {sub_label}...")
    }
    
    beh_proc_dir <- here::here(DATA_PROC_DIR, sub_label, "beh")
    beh_proc_filename <- list.files(beh_proc_dir, pattern = "*\\.csv")
    beh_proc_path <- here::here(beh_proc_dir, beh_proc_filename)
    
    beh_proc <- read_beh_clean(beh_proc_path)
    if (VERBOSE == T) {
      cli::cli_alert_success("-- Loaded behavioral data for {sub_label}.")
    }
    
    for (run_var in c("1", "2", "3", "4")) {
      run_label = stringr::str_glue("0{run_var}")
      if (VERBOSE == T) {
        cli::cli_alert_success("-- Creating {TASK_LABEL} task events.tsv for {sub_label}, run-{run_label}...")
      }
      #### Subset data to run N
      beh_run <- beh_proc |> dplyr::filter(run_number == run_var)
      
      #### To make robust across runs, relabel:
      ## "trial_number" to 1-80
      ## "num_block" to 1-8
      if (sub_label %in% c("sub-035", "sub-199", "sub-217")) {
        
        synthetic_trial_number = seq(1, 80, by = 1) |> as.integer()
        synthetic_num_block = seq(1, 8, by = 1) |> rep(10) |> sort() |> as.integer()
        beh_run <- beh_run |> dplyr::mutate(trial_number = synthetic_trial_number,
                                 num_block = synthetic_num_block)
        
      } else {
      beh_run <- beh_run |>
        dplyr::mutate(trial_number = as.integer(trial_number - (80 * (as.integer(run_var)-1) ))) |> 
        dplyr::mutate(num_block = as.integer(num_block - (8 * (as.integer(run_var)-1) ))) |>
        dplyr::select(subject, trial_number, num_block, everything())
    }
      
      ##### Calculate condition onsets and durations
      
      #### Record onsets, durations of trial conditions (approach-pos, etc)
      events_trials <- beh_run |>
        dplyr::group_by(num_block, condition) |>
        dplyr::summarize(
          onset = dplyr::first(trial_onset),
          duration = 20,
          .groups = 'drop'
        )
      
      #### Find baseline onsets.
      ## Baseline onsets are 2s after the last trial onset of each block.
      ## Each baseline condition has a variable duration, between 10 and 14s.
      
      num_block_list <- events_trials$num_block
      ## Check that num_block is a vector with integers 1-8
      testthat::expect_identical(num_block_list, c(1:8))
      
      ## Make a tibble with columns: num_block (int), condition (char), onset (dbl), duration (dbl)
      events_baseline_init <- tidyr::tibble(
        num_block = num_block_list,
        condition = "baseline",
        onset = as.numeric(rep(NA, 8)),
        offset = as.numeric(rep(NA, 8)),
        duration = as.numeric(rep(NA, 8))
      )
      
      events_baseline <- events_baseline_init
      for (num_block_var in num_block_list) {
        #### How to Find baseline onsets:
        ## First onset (block 1): equal to baseline_onset.
        ## All subsequent onsets (block 2-8):
        ## Find the trial onset of the last trial of the previous block 
        ## (These trials are every tenth trial; trial_number = 10, ...70))
        ## Then, add two seconds.
        if (num_block_var == 1) {
          onset_var = beh_run |> dplyr::filter(trial_number == 1) |> dplyr::pull(baseline_onset)
          first_baseline_onset <- onset_var
          events_baseline <- events_baseline |>
            dplyr::mutate(onset = dplyr::case_when(
              (num_block == num_block_var) ~ onset_var, .default = onset)
              )
        } else if (num_block_var %in% c(2:8)) {
          ## Find trial onset of last trial of previous block
          ## Add two seconds
          LAST_TRIALS_OF_BLOCKS <- seq(10, 70, by = 10) ## Should move this out of loop
          num_prev_block <- as.integer(num_block_var) - 1
          onset_var <- beh_run |>
            dplyr::filter(num_block == as.character(num_prev_block)) |> 
            dplyr::filter(trial_number %in% LAST_TRIALS_OF_BLOCKS) |> 
            dplyr::pull(trial_onset)
          onset_var <- onset_var + 2
          
          events_baseline <- events_baseline |>
            dplyr::mutate(onset = dplyr::case_when(
              (num_block == num_block_var) ~ onset_var, .default = onset)
              )
        }
        
        #### Find baseline offsets
        #### How to find baseline offsets:
        ## All offsets:
        ## These are equal to "blk_isntr_onset" from trials: (trial_number = 1, 11, ... 311)
        FIRST_TRIALS_OF_BLOCKS <- seq(1, 71, by = 10) ## Should move this out of loop
        offset_var <- beh_run |>
            dplyr::filter(num_block == num_block_var) |> 
            dplyr::filter(trial_number %in% FIRST_TRIALS_OF_BLOCKS) |> 
            dplyr::pull(blk_instr_onset)
        
        events_baseline <- events_baseline |>
            dplyr::mutate(offset = dplyr::case_when(
              (num_block == num_block_var) ~ offset_var, .default = offset)
              )
        
        #### Calculate baseline durations
        events_baseline <- events_baseline |>
          dplyr::mutate(duration = offset - onset)
        
        #### Combine baseline events with trial events
        #### Save baseline onsets, durations (drop offsets)
        events <- dplyr::bind_rows(events_baseline, events_trials) |>
          dplyr::arrange(onset) |> 
          dplyr::select(condition, onset, duration)
        
        
        ## (N) For subject SD, remove first baseline condition from each run
        ## (sub-SD had no dummy scans, making the first baseline condition uninterpretable)
        if (sub_label == "sub-SD") {
          events <- events[-1,]
        }
        
        ## Adjust onsets so that first baseline_onset is zero (matching acquisition zero)
        ## DEBUG: make a copy with the raw timestamps
        if (DEBUG == TRUE) {
        events_raw_timestamps <- events |> 
          dplyr::mutate(onset = round(onset, 2),
                        duration = round(duration, 2))
        }
        
        events <- events |>
          dplyr::mutate(onset = onset - first_baseline_onset) |> 
          ## Round to 0.n
          dplyr::mutate(onset = round(onset, 1),
                        duration = round(duration, 1))
        
        ## Save the data!
        ## Create output directory if it doesn't exist
        func_dir <- here::here(DATA_PROC_DIR, sub_label, "func")
        if (!dir.exists(func_dir)) {
          dir.create(func_dir)
        }
        
        ## Follow BIDS conventions to name events.tsv.
        events_output_filename <- stringr::str_glue(
          "{sub_label}_task-{TASK_LABEL}_run-{run_label}_events.tsv"
          )
        events_output_path <- here::here(func_dir, events_output_filename)
        readr::write_tsv(events, events_output_path)
        
        ## DEBUG: save the copy with the raw timestamps
        if (DEBUG == TRUE) {
        events_raw_timestamps_output_filename <- stringr::str_glue(
          "_DEBUG_raw_timestamps_{events_output_filename}"
          )
        events_raw_timestamps_output_path <- here::here(func_dir, events_raw_timestamps_output_filename)
        readr::write_tsv(events_raw_timestamps, events_raw_timestamps_output_path)
        }
        
      } ## end loop creating file for one run
        if (VERBOSE == T) {
          cli::cli_alert_success("-- Created events.tsv for {sub_label}, task: {TASK_LABEL},  run-{run_label}.")
        }
    } # end loop creating events.tsv for all runs (within one subject)
    
  } # end loop through all subjects
}

