requireNamespace("testthat")

## Test if an integer is even or odd
is_even <- function(input_number) {
  ## Throw error if input is not an integer
  testthat::expect_type(input_number, "integer")
  output <- ((input_number %% 2) == 0)
}

## Test whether all items in a vector are equal to n.
all_equal_n <- function(input_vector, n) {
  if ((max(input_vector) == min(input_vector)) & (max(input_vector) == n)) {
    all_equal_n <- TRUE
  } else {
    all_equal_n <- FALSE
  }
  return(all_equal_n)
}

## Function to make pretty table that rounds to 2 digits and stays in place
requireNamespace("gt")
pretty_table <- function(table, title = NULL, digits = 3,
                         groupname_col = NULL
                         ) {
    gt::gt(table, groupname_col = groupname_col) |> 
      gt::tab_header(title = title) |> 
      gt::sub_missing(columns = everything(), missing_text = "-") |> 
      gt::fmt_number(columns = where(is.numeric),
                 drop_trailing_zeros = T,
                 decimals = digits) |> 
   gt::tab_style(
      #Apply new style to all column headers
     locations = gt::cells_column_labels(columns = everything()),
     style     = list(
       #Give a thick border below
       # cell_borders(sides = "bottom", weight = px(2)),
       #Make text bold
       gt::cell_text(weight = "bold")
     )
   ) |> 
    # Changed to "true" to put groups on the side, instead of in header rows.
  gt::tab_options(row_group.as_column = TRUE) |> 
    ## Bold grouping variable headers
  gt::tab_style(
    style = list(gt::cell_text(weight = "bold")),
    locations = gt::cells_row_groups()
  ) 
  
}


## Format p-values in a table
format_p.value <- function(tbl) {
  tbl  %>%
    ## display p as "<.001" if it is less than 0.001; or else, round.
    ## Diaply p as "<.0001 if less that .0001; or else, round.
    mutate(p.value = case_when(
      (p.value < 0.0001) ~ "<.0001",
      (0.0001 <= p.value & p.value < 0.001) ~
        as.character(p.value %>% round(4)),
      (0.001 <= p.value & p.value < 0.01) ~
        as.character(p.value %>% round(3)),
      (0.01 <= p.value) ~
        as.character(p.value  %>% round(3))
    )) |> 
    ## Remove leading zero
    mutate(p.value = p.value |> str_remove("^0+"))
}

## Functions to style plots
gg_style <- function(g) {
  g_styled <- g +
    theme_minimal(base_size = 10) +
    theme(#aspect.ratio = 1 / 1,
          axis.ticks.x = element_blank(),
          panel.grid.minor = element_blank(),
          panel.border = element_rect(fill = NA),
          ## Set a white background (so pngs aren't transparent)
          panel.background = element_rect(fill = 'white', color = 'white'),
          plot.background = element_rect(fill = "white", color = "white")
    )
  return(g_styled)
}

## Function to find SD around a % estimate
find_sd_pct <- function(pct, sample_size) {
  ## How to find SD of a proportion:
  ## sqrt((p(1-p)/n)
  ## p = proportion of hits
  ## n = total n
  sd_out <- 100 * sqrt(((.01 * pct) * (1 - (.01 * pct)) / sample_size))
}