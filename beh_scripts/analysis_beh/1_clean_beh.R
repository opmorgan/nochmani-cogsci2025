requireNamespace("here")
requireNamespace("tidyverse")
library(readr)
library(ggplot2)
library(lme4)
library(emmeans)
requireNamespace("gt")
requireNamespace("testthat")
requireNamespace("cli")
library(knitr) # For include_graphics

source(here::here("lib", "util.R"))

source(here::here("lib", "beh", "0_read_subjects_tsv.R"))
source(here::here("lib", "beh", "0_read_beh_raw.R"))
source(here::here("lib", "beh", "1_pre_clean_sub-035.R"))
source(here::here("lib", "beh", "2_clean_beh.R"))
source(here::here("lib", "beh", "3_read_beh_clean.R"))
source(here::here("lib", "beh", "4_validate_beh.R"))
source(here::here("lib", "beh", "5_create_beh_long.R"))
source(here::here("lib", "beh", "6_read_beh_long.R"))

options(dplyr.summarise.inform=F) 


# Constants
RUN_LABELS <- c(
  '1' = "Run 1",
  '2' = "Run 2",
  '3' = "Run 3",
  '4' = "Run 4"
)

## CONFIG
DATA_RAW_DIR <- here::here("data", "raw")
DATA_PROC_DIR <- here::here("data", "proc")

## Load participants list
subjects <- read_subjects_tsv(here::here("data", "subjects.tsv"))
SUB_LABELS <- subjects$participant_id

## Specify which processing steps to run
DO_PRECLEAN_035_BEH <- T

DO_CLEAN_BEH <- T
DO_VALIDATE_BEH <- T
DO_CREATE_BEH_LONG <- T
## Pre-clean data for subject 035 (First run was aborted due to Windows Update notification)
if (DO_PRECLEAN_035_BEH == TRUE) {
  source(here::here("lib", "beh", "1_pre_clean_sub-035.R"))
}

## Load and clean raw data from each subject
## Add calculated columns (including "correct", "condition_mot", "condition_val", condition")
if (DO_CLEAN_BEH == TRUE) {
  clean_beh(SUB_LABELS, DATA_RAW_DIR, DATA_PROC_DIR, verbose = TRUE)
}

## Validate data (check that it has the expected number of conditions, trials, etc)
if (DO_VALIDATE_BEH == TRUE) {
  validate_beh(SUB_LABELS, verbose = TRUE)
}

## Create long table with clean behavioral data from all subjects
if (DO_CREATE_BEH_LONG == TRUE) { 
  create_beh_long(DATA_PROC_DIR)
}