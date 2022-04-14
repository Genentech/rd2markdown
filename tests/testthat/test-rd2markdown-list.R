test_that("rd2markdown formats LIST Rd_tags", {
  list_rd <- rawRd("
    \\describe{
      This is a {test} of LIST Rd_tags.
    }
  ")

  expect_match(rd2markdown(list_rd), "test of LIST Rd_tags")
})
