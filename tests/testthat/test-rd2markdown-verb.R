test_that("rd2markdown verb empty tag does not throw warning (#22)", {
  rd <- rawRd("\\verb{}")
  expect_silent(md <- rd2markdown(rd))
  expect_equal(md, "` `")
})
