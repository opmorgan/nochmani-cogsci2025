
library(readr)

read_subjects_tsv <- function(subjects_tsv_path) {
  subjects <- readr::read_tsv(subjects_tsv_path,
                              col_types = cols(
                                participant_id = col_character(),
                                order = col_integer(),
                                group = col_character()
                              )
  )
  
  return(subjects)
}