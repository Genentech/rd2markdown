test_that("rd2markdown preserves section paragraph breaks", {
  text_rd <- rawRd("
    one

    two
  ")

  expect_silent(md <- rd2markdown(text_rd))
  expect_match(md, "one\n\ntwo")
  expect_match(md, "^one")
  expect_match(md, "two$")
})

test_that("rd2markdown does not introduce breaks in wrapped lines", {
  # ensure Rd2txt default wraps text lines
  referenceA <- Rd2txt2chr("
    \\name{test}
    \\title{test}
    \\description{


      one
      two


    }
  ")

  referenceB <- Rd2txt2chr("
    \\name{test}
    \\title{test}
    \\description{
      one
      two
    }
  ")

  expect_match(referenceA, "one two", fixed = TRUE)
  expect_identical(referenceA, referenceB)

  # try to match expected representation via markdown formatting
  section_rd <- rawRd("
  \\section{test}{
    one
    two
  }
  ")

  expect_silent(md <- rd2markdown(section_rd))
  expect_match(md, "## test\n\none")
  expect_match(md, "one two")

  # try to match expected representation via markdown formatting
  section_rd <- rawRd("
  \\section{test}{
    one

    two
  }
  ")

  expect_silent(md <- rd2markdown(section_rd))
  expect_match(md, "## test\n\none")
  expect_match(md, "one\\s?\n\ntwo")  # permit one space at end of line
})
