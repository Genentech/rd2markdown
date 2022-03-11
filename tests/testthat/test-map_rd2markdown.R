test_that("A list of fragments can be mapped over to individually map to markdown", {
  rd <- get_rd(file = file.path(test_path(), "data", "man", "rd_sampler.Rd"))
  expect_silent(md <- map_rd2markdown(rd))
  expect_true(length(md) > 1L)  # dependent on how many tags have been implemented
  expect_true(all(sapply(md, is.character)))
  expect_silent(md <- map_rd2markdown(rd, strwrap = 30L))
})
