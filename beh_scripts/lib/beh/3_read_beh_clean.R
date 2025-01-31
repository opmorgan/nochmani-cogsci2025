## Read cleaned behavioral file (per-subject)
## e.g., data/proc/sub-003/beh_sub-003.csv
library(readr)
read_beh_clean <- function(file_path) {
  readr::read_csv(
    file_path,
    col_types =
      cols(
        trial_number = col_integer(),
        n_block = col_integer(),
        catch = col_logical(),
        hand = col_character(),
        mot = col_character(),
        val = col_character(),
        stim_name = col_character(),
        #run_number = col_character(),
        run_number = col_factor(levels = c("1", "2", "3", "4"), ordered=T),
        num_block = col_integer(),
        ran = col_logical(),
        order = col_integer(),
        response = col_character(),
        response_cleaned = col_character(),
        time_of_response = col_double(),
        rt = col_double(),
        subject_number = col_integer(),
        left_side_resp_label = col_character(),
        trial_onset = col_double(),
        blk_instr_onset = col_double(),
        baseline_onset = col_double(),
        response_hand = col_character(),
        response_lat = col_character(),
        response_meaning = col_character()
      )
  )
}