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


test_that("rd2markdown arguments can mix test with items", {
  # As described in "Writing R Extensions"
  # > There may be optional text outside the \item entries, for example to give
  # > general information about groups of parameters.

  # although this style is rarely used, it is permitted
  arg_rd <- rawRd("
    \\arguments{
      test

      \\item{a}{a arg}
      \\item{b}{b arg}

      test2

      \\item{a}{a arg}
      \\item{b}{b arg}
    }
  ")

  expect_silent(md <- rd2markdown(arg_rd))
  expect_match(md, "- `a`: a arg", fixed = TRUE)
  expect_match(md, "\n\ntest\\s?\n\n-")
  expect_match(md, "arg\\s?\n\ntest2\\s?\n\n-")
})
