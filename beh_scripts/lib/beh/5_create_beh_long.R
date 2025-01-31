## Create long table with clean behavioral data from all subjects
requireNamespace("readr")
requireNamespace("dplyr")
requireNamespace("purrr")
source(here::here("lib", "beh", "3_read_beh_clean.R"))

create_beh_long <- function(data_proc_dir) {
  
  ## Make list of all filepaths (e.g., "data/proc/sub-003/beh/beh_sub-003.csv")
  beh_cleaned_paths <- list.files(recursive = TRUE, include.dirs = TRUE, pattern = "beh_sub-.*\\.csv")
  
  beh_long <- purrr::map(beh_cleaned_paths, read_beh_clean) |> 
    dplyr::bind_rows()
  
  readr::write_csv(beh_long, here::here(data_proc_dir, "beh_long.csv"))
}

