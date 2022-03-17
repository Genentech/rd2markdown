test_that("Can find relevant R documentation files, given a topic and package name", {
  expect_s3_class(get_rd(topic = "test_that", package = "testthat"), "Rd")
})

test_that("While searching for relevant R documentation, Errors return silently", {
  expect_s3_class(get_rd(topic = 1L + "a"), "error")
})

test_that("Can find relevant R documentation files, given a .Rd filepath", {
  expect_s3_class(get_rd(file = file.path(test_path(), "data" , "man", "autovalidate.Rd")), "Rd")
})

test_that("get_rd find macros properly", {
  expect_s3_class(get_rd(file = system.file("examples", "rd_file_sample_2.Rd", package = "rd2markdown"), macros = NA), "Rd")
  rd_file <- get_rd(file = system.file("examples", "rd_file_sample_2.Rd", package = "rd2markdown"), macros = NA)
  expect_equivalent(
    rd_file[[17]][[3]], 
    structure(c("\\code{\\link[=#1]{#1()}}", "rnorm"), Rd_tag = "USERMACRO", macro = "\\function")
  )
})
