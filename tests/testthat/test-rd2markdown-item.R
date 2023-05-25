test_that("rd2markdown item empty tag does not throw error", {
  rd <- rawRd("\\itemize{\\item{}{}}")
  expect_silent(md <- rd2markdown(rd))
  expect_equal(md, " * ")
})
