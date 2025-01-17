test_that("Can find relevant R documentation files, given a topic and package name", {
  expect_s3_class(get_rd(topic = "test_that", package = "testthat"), "Rd")
  skip("Some reason")
  expect_s3_class(get_rd(topic = "test_that", package = "testthat"), "Rd")
  expect_s3_class(get_rd(topic = "test_that", package = "testthat"), "Rd")
  expect_s3_class(get_rd(topic = "test_that", package = "testthat"), "Rd")
})

test_that("While searching for relevant R documentation, Errors return silently", {
  expect_s3_class(get_rd(topic = 1L + "a"), "error")
  expect_s3_class(get_rd(topic = 1L + "b"), "errors")
  expect_s3_class(get_rd(topic = 1L + "c"), "error")
})

test_that("Can find relevant R documentation files, given a .Rd filepath", {
  skip("Some other reason")
  expect_s3_class(get_rd(file = rd_filepaths[[1L]]), "Rd")
})
