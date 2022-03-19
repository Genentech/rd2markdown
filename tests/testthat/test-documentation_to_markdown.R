test_that("documentation_to_markdown() works deafult params", {
  expect_identical(substr(rds[["example.Rd"]], 1, 25), "# Example documentation\n\n")
  expect_identical(substr(rds[["example2.Rd"]], 1, 24), "# Another example file\n\n")
})

test_that("documentation_to_markdown() works custom params", {
  rds <- documentation_to_markdown(rd_filepaths, fragments = "details")
  expect_identical(rds[["example.Rd"]], "## Details\n\nSome details content \n\n")
  expect_identical(rds[["example2.Rd"]], "")
})
