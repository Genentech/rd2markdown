test_that("rd2markdown href works on links with url target", {
  rd <- rawRd("\\href{www.test.com}{test}")
  expect_silent(md <- rd2markdown(rd))
  expect_equal(md, "[test](www.test.com)")
})
