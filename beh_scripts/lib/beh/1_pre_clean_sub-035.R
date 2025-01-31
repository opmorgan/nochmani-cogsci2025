requireNamespace("tidyverse")
requireNamespace("here")
source(here::here("lib", "beh", "0_read_beh_raw.R"))

data_raw_dir <- here::here("data", "raw")

## Prepare cleaned dataset for sub-035
sub_label <- "sub-035"
sub_raw_dir <- here::here(data_raw_dir, sub_label, "beh", "orig")
beh_orig_filename_1 <- list.files(sub_raw_dir, pattern = "*1351_35.csv")
beh_orig_filename_2 <- list.files(sub_raw_dir, pattern = "*1458_35.csv")

beh_orig_path_1 <- here::here(sub_raw_dir, beh_orig_filename_1)
beh_orig_path_2 <- here::here(sub_raw_dir, beh_orig_filename_2)

beh_orig_1 <- read_beh_raw(sub_label, beh_orig_path_1)
beh_orig_2 <- read_beh_raw(sub_label, beh_orig_path_2)

## Subject 035's scan was aborted during their first run, because a Windows Update prompt appeared on the screen and the participant pressed the emergency squeezeball. The scan was aborted, and the participant then completed the next three runs. After the tapping task, the script was restarted so that the participant could complete their fourth task run.
## For the purposes of analysis, the "run_number" values in the behavioral data should be changed as follows, to reflect the order of the four complete runs:

## First csv file, ending in "*1351_35.csv"
## run_number 1 -> NA
## run_number 2 -> 1
## run_number 3 -> 2
## run_number 4 -> 3

## Second csv file, ending in "*1458_35.csv"
## run_number 1 -> 4
## run_number 2 -> NA
## run_number 3 -> NA
## run_number 4 -> NA

## (1) Re-code run numbers
## (2) Remove rows where run_number is NA
beh_orig_1
beh_1 <- beh_orig_1 |>
  dplyr::mutate(run_number = dplyr::case_match(run_number, "1" ~ NA, "2" ~ "1", "3" ~ "2", "4" ~ "3")) |>
  dplyr::filter(!is.na(run_number))

beh_orig_2
beh_2 <- beh_orig_2 |>
  dplyr::mutate(run_number = dplyr::case_match(run_number, "1" ~ "4", "2" ~ NA, "3" ~ NA, "4" ~ NA)) |>
  dplyr::filter(!is.na(run_number))

## Then, combine the two original data files:
## (3) Add the remaining rows together to make one spreadsheet with 4 runs (320 rows)
beh_combined <- dplyr::add_row(beh_1, beh_2)

## (4) Save the data (as "2024-07-01_sub-035_cleaned.csv")
out_path <- here::here(data_raw_dir,
                 sub_label, "beh",
                 "2024-07-01_cleaned_sub-035.csv")
readr::write_csv(beh_combined, out_path)
