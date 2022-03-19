rd_files <- c("example.Rd", "example2.Rd")
rd_filepaths <- file.path(test_path(), "data", "man", rd_files)
rds <- documentation_to_markdown(rd_filepaths)

rawRd <- function(text) {
  tmp_rd <- tempfile("rd_", fileext = ".Rd")
  writeLines(text, tmp_rd)
  tools::parse_Rd(file = tmp_rd, fragment = TRUE)
}

test_that("markdown example fixtures initialized", {
  expect_named(rds)
  expect_length(rds, 2)
})
