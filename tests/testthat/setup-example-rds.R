rd_files <- c("example.Rd", "example2.Rd")
rd_filepaths <- file.path(test_path(), "data", "man", rd_files)
rds <- documentation_to_markdown(rd_filepaths)

rawRd <- function(text, quiet = FALSE) {
  # trim left hand side spaces from multi-line string
  textspl <- strsplit(text, "\n")[[1]]
  n <- length(textspl)
  if (!nchar(trimws(textspl[[n]]))) textspl <- textspl[-n]
  if (!nchar(trimws(textspl[[1]]))) textspl <- textspl[-1]

  textws <- textspl[grepl("\\S", textspl)]  # only consider lines with non-ws
  nleadingws <- min(nchar(gsub("\\S.*$", "", textws)))
  text <- paste0(substring(textspl, nleadingws + 1), collapse = "\n")

  # write content to tempfile
  tmp_rd <- tempfile("rd_", fileext = ".Rd")
  on.exit(file.remove(tmp_rd))
  writeLines(text, tmp_rd)

  # first try to parse as complete Rd
  res <- tryCatch(tools::parse_Rd(file = tmp_rd, fragment = FALSE), condition = identity)
  if (inherits(res, "condition")) {
    res <- tools::parse_Rd(file = tmp_rd, fragment = TRUE)
  }

  # trim "\n" text from res, which seems to always be added when fragment=FALSE
  if (res[[length(res)]] == "\n") res <- res[-length(res)]

  # if interactive (and not within a test), print Rd2txt as reference
  if (!quiet && interactive() && identical(parent.frame(), globalenv()))
    tools::Rd2txt(res, fragment = TRUE)

  res
}

Rd2txt2chr <- function(text) {
  opts <- list(underline_titles = FALSE)
  rd <- rawRd(text)
  res <- capture.output(tools::Rd2txt(rd, options = opts))
  paste0(res, collapse = "\n")
}

test_that("markdown example fixtures initialized", {
  expect_named(rds)
  expect_length(rds, 2)
})
