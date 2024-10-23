test_that("Can find relevant R documentation files, given a topic and package name", {
  expect_s3_class(get_rd(topic = "test_that", package = "testthat"), "Rd")
})

test_that("While searching for relevant R documentation, Errors return silently", {
  expect_s3_class(get_rd(topic = 1L + "a"), "error")
})

test_that("Can find relevant R documentation files, given a .Rd filepath", {
  expect_s3_class(get_rd(file = rd_filepaths[[1L]]), "Rd")
})

test_that("get_rd find macros by file", {
  rd_filepath <- system.file("examples", "rd_file_sample_2.Rd", package = "rd2markdown")
  rd_macro <- system.file("examples", "macros", "macros.Rd", package = "rd2markdown")
  expect_s3_class(get_rd(file = rd_filepath, macros = rd_macro), "Rd")
  expect_silent(rd <- get_rd(file = rd_filepath, macros = rd_macro))
  expect_equivalent(
    rd[[17]][[3]],
    structure(c("\\code{\\link[=#1]{#1()}}", "rnorm"), Rd_tag = "USERMACRO", macro = "\\function")
  )
})

test_that("get_rd find macros embedded in the package", {
  rd_filepath <- system.file("examples", "rd_file_sample_2.Rd", package = "rd2markdown")
  expect_s3_class(get_rd(file = rd_filepath, macros = NULL), "Rd")
  expect_silent(rd <- get_rd(file = rd_filepath, macros = NULL))
  expect_equivalent(
    rd[[17]][[3]],
    structure(c("\\code{\\link[=#1]{#1()}}", "rnorm"), Rd_tag = "USERMACRO", macro = "\\function")
  )
})
