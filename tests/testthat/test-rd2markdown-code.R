test_that("rd2markdown code tags wrap code in single backticks", {
  rd <- rawRd("\\code{1 + 2}")
  expect_silent(md <- rd2markdown(rd))
  expect_equal(md, "`1 + 2`")
})
