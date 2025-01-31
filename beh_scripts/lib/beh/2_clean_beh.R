## Load and clean raw data
# Example csv path: "/Users/om/proj/nochmani_scripts/data/2023-07-18-1553_777.csv"
requireNamespace("here")
requireNamespace("dplyr")
requireNamespace("readr")
source(here::here("lib", "beh", "0_read_beh_raw.R"))

clean_beh <- function(sub_labels, data_raw_dir, data_proc_dir,
                               verbose = TRUE) {
  for (sub_label in sub_labels) {
    beh_raw_dir <- here::here(data_raw_dir, sub_label, "beh")
    beh_raw_filename <- list.files(beh_raw_dir, pattern = "*\\d.csv")
    beh_raw_path <- here::here(beh_raw_dir, beh_raw_filename)
    
    beh_raw <- read_beh_raw(sub_label, beh_raw_path)
    if (verbose == T) {
    cli::cli_alert_success("Loaded behavioral data for subject {sub_label}.")
    }
    ## Clean up data types:
    ## Convert "ran" to logical; 
    ## Convert "order" to integer
    ## Convert `Subject number` from double to integer
    beh_proc <- beh_raw |> 
      dplyr::mutate(
        ran = as.logical(ran),
        order = as.integer(order),
        `Subject number` = as.integer(`Subject number`)
      ) |> 
      ## Clean up unweildy variable names
      dplyr::rename(subject_number = `Subject number`,
                    trial_number = TrialNumber) |> 
      ## Remove redundant "n_b" column (use "num_block" instead)
      dplyr::select(-n_b)
    
    
    ## Add column indicating participant's response hand. sub-035 started backwards.
    ## Start hand (for practice round): left for even-numbered subjects, right for odd numbered subjects.
    ## Odd-number subjects used their left hand for Run 1.
    ## Even-numbered subjects used their right hand for Run 1.
    ## This is correct for subject 035 (using the run numbers from their cleaned data), even though their first run was aborted.
    beh_proc <- beh_proc |>
      dplyr::mutate(
        response_hand =
          dplyr::case_when(
            is_even(subject_number) & is_even(as.integer(run_number)) ~ "left", # Even subject: even runs are "left"
            is_even(subject_number) & !is_even(as.integer(run_number)) ~ "right", # Even subject: odd runs are "right"
            !is_even(subject_number) & !is_even(as.integer(run_number)) ~ "left", # Odd subject: odd runs are "left"
            !is_even(subject_number) & is_even(as.integer(run_number)) ~ "right" # Odd subject: even runs are "right"
          )
      )
    
    ## Clean data for participants whose button presses weren't recorded correctly. (Interpolate "2" for empty responses)
    ## Note: SD used "3" for left and "1" for right.
    ## All subsequent participants have "1" for left and "2" for right, because they used the rectangular button box. 
    ## sub-KP, sub-003, sub-020, sub-028, and sub-058 only have "1" (left) presses recorded -- the rest are blank (because of an error in updating the code for the new button box)
    ## KP also pressed "3" in two trials, by mistake (they likely meant to press "2").
    if (sub_label %in% c("sub-KP", "sub-003", "sub-020", "sub-028", "sub-058")) {
      # recode response "--" as "2"
      beh_proc <- beh_proc |>
        dplyr::mutate(response_cleaned = dplyr::case_match(response, "1" ~ "1", "--" ~ "2", "3" ~ "2"))
    } else {
      beh_proc <- beh_proc |> 
        dplyr::mutate(response_cleaned = response)
    }
    
    ## Add column "response_lat" with "right"/"left" (explaining meaning of button presses)
    ## For SD, "3" meant left and "1" meant right
    ## And, add "response_lat_cleaned" using cleaned button presses.
    if (sub_label == "sub-SD") {
      beh_proc <- beh_proc |> 
        dplyr::mutate(response_lat = dplyr::case_match(response, "3" ~ "left", "1" ~ "right")) |> 
        dplyr::mutate(response_lat_cleaned = dplyr::case_match(response_cleaned, "3" ~ "left", "1" ~ "right"))
    } else {
      beh_proc <- beh_proc |> 
        dplyr::mutate(response_lat = dplyr::case_match(response, "1" ~ "left", "2" ~ "right")) |> 
        dplyr::mutate(response_lat_cleaned = dplyr::case_match(response_cleaned, "1" ~ "left", "2" ~ "right"))
    }
    
    
    ## Add column "response_meaning" with "eat"/"not_eat"
    ## And column "response_meaning_cleaned" using cleaned response data
    beh_proc <- beh_proc |>
      dplyr::mutate(response_meaning =
                      dplyr::case_when(
                        (
                          stringr::str_starts(left_side_resp_label, "EAT")
                          & response_lat == "left"
                        ) ~ "eat",
                        (
                          stringr::str_starts(left_side_resp_label, "EAT")
                          & response_lat == "right"
                        ) ~ "not_eat",
                        (
                          stringr::str_starts(left_side_resp_label, "DON'T EAT")
                          & response_lat == "left"
                        ) ~ "not_eat",
                        (
                          stringr::str_starts(left_side_resp_label, "DON'T EAT")
                          & response_lat == "right"
                        ) ~ "eat",
                        (
                          !(response_lat %in% c("left", "right")) ~ "no_response"
                        )
                      ),
                    response_meaning_cleaned =
                      dplyr::case_when(
                        (
                          stringr::str_starts(left_side_resp_label, "EAT")
                          & response_lat_cleaned == "left"
                        ) ~ "eat",
                        (
                          stringr::str_starts(left_side_resp_label, "EAT")
                          & response_lat_cleaned == "right"
                        ) ~ "not_eat",
                        (
                          stringr::str_starts(left_side_resp_label, "DON'T EAT")
                          & response_lat_cleaned == "left"
                        ) ~ "not_eat",
                        (
                          stringr::str_starts(left_side_resp_label, "DON'T EAT")
                          & response_lat_cleaned == "right"
                        ) ~ "eat",
                        (
                          !(response_lat_cleaned %in% c("left", "right")) ~ "no_response"
                        )
                      )
      )
    
    ## Add columns indicating block condition:
    #### condition_mot ("approach" or "avoid")
    #### condition_val ("approach" or "avoid")
    #### condition ("approach-pos", "approach-neg", "avoid-pos", "avoid-neg")
    
    ## (1) Find condition of each block.
    ## Goal: a 3x32 table with columns: num_block, condition_val, (condition_mot)
    ## condition_val ("pos", "neg")
    condition_val_idx <- beh_proc |>
      dplyr::group_by(num_block, val) |> 
      dplyr::count() |> 
      dplyr::filter(n == 9) |>
      dplyr::select(num_block, val) |> 
      dplyr:: rename(condition_val = val)
    
    ## condition_mot ("approach", "avoid")
    condition_mot_idx <- beh_proc |>
      dplyr::group_by(num_block, mot) |> 
      dplyr::count() |> 
      dplyr::filter(n == 8) |>
      dplyr::select(num_block, mot) |> 
      dplyr:: rename(condition_mot = mot)
    
    ## (2) Combine table of block conditions with beh_proc
    condition_idx <- dplyr::left_join(condition_mot_idx, condition_val_idx,
                                      by = "num_block")
    beh_proc <- dplyr::left_join(beh_proc, condition_idx, by = "num_block")
    
    ## (3) Create combined "condition" column
    beh_proc <- beh_proc |> 
      dplyr::mutate(condition = stringr::str_c(condition_mot, "-", condition_val))
    
    
    ## Add column indicating correctness.
    ## Correct response: "eat" for "approach" trials; "not_eat" for "avoid" trials.
    ## And "correct_cleaned" using cleaned response data
    beh_proc <- beh_proc |>
      dplyr::mutate(
        correct = dplyr::case_when(
          (mot == "approach") & (response_meaning == "eat") ~ 1,
          (mot == "approach") & (response_meaning == "not_eat") ~ 0,
          (mot == "approach") & (response_meaning == "no_response") ~ NA,
          (mot == "avoid") & (response_meaning == "not_eat") ~ 1,
          (mot == "avoid") & (response_meaning == "eat") ~ 0,
          (mot == "avoid") & (response_meaning == "no_response") ~ NA,
        ),
        correct_cleaned = dplyr::case_when(
          (mot == "approach") & (response_meaning_cleaned == "eat") ~ 1,
          (mot == "approach") & (response_meaning_cleaned == "not_eat") ~ 0,
          (mot == "approach") & (response_meaning_cleaned == "no_response") ~ NA,
          (mot == "avoid") & (response_meaning_cleaned == "not_eat") ~ 1,
          (mot == "avoid") & (response_meaning_cleaned == "eat") ~ 0,
          (mot == "avoid") & (response_meaning_cleaned == "no_response") ~ NA,
        )
      ) |> 
      dplyr::mutate(correct = as.integer(correct)) |> 
      dplyr::mutate(correct_cleaned = as.integer(correct_cleaned))
    
    ## Recode RT as a double (NA instead of "--")
    beh_proc <- beh_proc |>
      dplyr::mutate(
        RT = dplyr::case_match(
          RT, "--" ~ NA,
          .default = RT
        ) |> 
        as.numeric()
    )
    
    ## Add column indicating RT (ms)
    ## (The column "RT" in the raw data records what time they responded, in seconds)
    ## Recode "RT" to avoid confusion
    beh_proc <- beh_proc |>
      dplyr::rename(time_of_response = RT) |>
      dplyr::mutate(rt = (time_of_response)*1000 - (trial_onset)*1000)
    
    ## Add column with subject ID label, put it in front
    beh_proc <- beh_proc |> 
      dplyr::mutate(subject = sub_label) |> 
      dplyr::select(subject, everything())
    
    ## Save processed data
    ## Check if output dir exists. If it doesn't exist, create it. 
    beh_proc_dir <- here::here(data_proc_dir, sub_label, "beh")
    if (!dir.exists(beh_proc_dir)) {dir.create(beh_proc_dir, recursive = TRUE)}
    out_path <- here::here(
      beh_proc_dir,
      stringr::str_c("beh_", sub_label, ".csv")
    )
    readr::write_csv(beh_proc, out_path)
    
    if (verbose == T) {
    cli::cli_alert_success("Cleaned behavioral data for subject {sub_label}.")
    }
  }
}
