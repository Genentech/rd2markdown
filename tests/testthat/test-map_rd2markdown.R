test_that("A list of fragments can be mapped over to individually map to markdown", {
  rd <- get_rd(file = file.path(test_path(), "data", "man", "rd_sampler.Rd"))
  expect_silent(md <- map_rd2markdown(rd))
  expect_true(length(md) > 1L)  # dependent on how many tags have been implemented
  expect_true(all(sapply(md, is.character)))
  expect_silent(md <- map_rd2markdown(rd, strwrap = 30L))
})

test_that("merge_text_spaces works as expected", {
  x <- list("    ", " ", "   ")
  expect_equal(
    merge_text_spaces(x),
    list("        ")
  )
  
  x <- list(" a ", "`b`", "  ", "  ", " c ", " ", " ")
  expect_equal(
    merge_text_spaces(x),
    list(" a ", "`b`    ", " c   ")
  )
  
  x <- list(" a ", "`b`", " ", "  ", "    c ", block(), "\n", "e   \n", "f")
  expect_equal(
    merge_text_spaces(x),
    list(" a ", "`b`   ", "    c ", block(), "\n", "e   \n", "f")
  )
  
  x <- list(" a ", "`b`", " ", "  ", " c ", block(), " ", "   ", block())
  expect_equal(
    merge_text_spaces(x),
    list(" a ", "`b`   ", " c ", block(), "    ", block())
  )

  x <- list(block(), " ", "      ", block())
  expect_equal(
    merge_text_spaces(x),
    list(block(), "       ", block())
  )
})

