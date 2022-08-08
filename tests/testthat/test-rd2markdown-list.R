test_that("rd2markdown formats LIST Rd_tags", {
  expect_silent({
    list_rd <- rawRd("\\describe{This is a {test} of LIST Rd_tags.}", quiet = TRUE)
    which_describe <- lapply(list_rd, attr, "Rd_tag") == "\\describe"
    describe <- list_rd[which_describe][[1L]]
  })

  # confirm that we actually produced a LIST Rd_tag as part of our test
  expect_true(any(lapply(describe, attr, "Rd_tag") == "LIST"))

  # test rendering of LIST element, {test}
  expect_match(rd2markdown(list_rd), "is a test of")
})
