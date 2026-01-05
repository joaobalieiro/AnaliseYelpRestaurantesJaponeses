library(jsonlite)
library(dplyr)
library(stringr)
library(tidyr)

load_json_lines <- function(path) {
  con <- file(path, "r")
  data <- stream_in(con, verbose = FALSE)
  close(con)
  return(data)
}

