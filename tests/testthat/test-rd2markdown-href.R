test_that("rd2markdown href works on links with url target", {
  rd <- rawRd("\\href{test}{www.test.com}")
  expect_silent(md <- rd2markdown(rd))
  expect_equal(md, "[test](www.test.com)")
})
