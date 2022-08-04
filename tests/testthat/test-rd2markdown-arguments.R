test_that("rd2markdown arguments separated by exactly one newline", {
  arg_rd <- rawRd("
    \\arguments{
    \\item{a}{a arg}
    \\item{b}{b arg}
    }
  ")

  expect_silent(md <- rd2markdown(arg_rd))
  expect_match(md, "- **a**: a arg", fixed = TRUE)
  expect_match(md, "arg\n-", fixed = TRUE)
})
