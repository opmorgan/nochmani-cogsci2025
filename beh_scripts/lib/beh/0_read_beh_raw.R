## Load raw behavioral data file, given path
library(readr)
read_beh_raw <- function(sub_label, beh_raw_path) {
    beh_raw <- readr::read_csv(
      beh_raw_path,
      col_types = readr::cols(
        TrialNumber = col_integer(),
        n_block = col_integer(),
        catch = col_logical(),
        hand = col_character(),
        mot = col_character(),
        val = col_character(),
        stim_name = col_character(),
        #run_number = col_integer(),
        run_number = col_factor(levels = c("1", "2", "3", "4"), ordered=T),
        num_block = col_integer(),
        ran = col_double(),
        order = col_double(),
        response = col_character(),
        RT = col_character(),
        `Subject number` = col_double(),
        n_b = col_double(),
        left_side_resp_label = col_character(),
        trial_onset = col_double(),
        blk_instr_onset = col_double(),
        baseline_onset = col_double()
      )
    )
}
