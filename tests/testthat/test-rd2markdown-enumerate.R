test_that("rd2markdown enumerate separated by exactly one newline", {
  enum_rd <- rawRd("
    \\enumerate{
    \\item{a}
    \\item{b}
    }
  ")

  expect_silent(md <- rd2markdown(enum_rd))
  expect_match(md, "1. a", fixed = TRUE)
  expect_match(md, "a\n2", fixed = TRUE)

  enum_rd <- rawRd("
    \\enumerate{
    \\item{a}
    \\item{
      b
      \\enumerate{
      \\item{x}
      \\item{y}
      \\item{z}
      }
    }
    }
  ")

  expect_silent(md <- rd2markdown(enum_rd))
  expect_match(md, "1. a", fixed = TRUE)
  expect_match(md, "a\n2", fixed = TRUE)
})
