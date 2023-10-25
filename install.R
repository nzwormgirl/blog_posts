CRAN <- "https://mirror.las.iastate.edu/CRAN/"

process_file <- function(filepath) {
  con <- file(filepath, "r")
  while (TRUE) {
    line <- trimws(readLines(con, n = 1))
    if (length(line) == 0) {
      break
    }
    install.packages(line, repos = CRAN)
  }
  
  close(con)
}

process_file("requirements.txt")