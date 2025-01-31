## Load long behavioral data table
library(readr)
read_beh_long <- function(data_proc_dir, subjects_tsv) {
  beh_long <- readr::read_csv(here::here(data_proc_dir, "beh_long.csv"),
                              col_types =
                                cols(
                                  trial_number = col_integer(),
                                  n_block = col_integer(),
                                  catch = col_logical(),
                                  hand = col_character(),
                                  mot = col_character(),
                                  val = col_character(),
                                  stim_name = col_character(),
                                  #run_number = col_integer(),
                                  run_number = col_factor(levels = c("1", "2", "3", "4"), ordered=T),
                                  num_block = col_integer(),
                                  ran = col_logical(),
                                  order = col_integer(),
                                  response = col_character(),
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
                                ))
  
  subjects_temp <- subjects_tsv |> dplyr::rename(subject = participant_id, visit_order = order)
  beh_long <- beh_long |> 
    dplyr::left_join(subjects_temp, by = "subject") |>
    dplyr::mutate(subject = as.factor(subject), ordered = T) |> 
    dplyr::mutate(subject = forcats::fct_reorder(subject, visit_order)) |> 
    dplyr::select(-visit_order)
  
  return(beh_long)
}