test_that("Can find relevant R documentation files, given a topic and package name", {
  expect_s3_class(get_rd(topic = "test_that", package = "testthat"), "Rd")
})

test_that("While searching for relevant R documentation, Errors return silently", {
  expect_s3_class(get_rd(topic = 1L + "a"), "error")
})

test_that("Can find relevant R documentation files, given a .Rd filepath", {
  expect_s3_class(get_rd(file = file.path(test_path(), "data" , "man", "autovalidate.Rd")), "Rd")
})
