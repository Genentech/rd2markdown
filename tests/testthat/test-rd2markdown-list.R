test_that("rd2markdown formats LIST Rd_tags", {
  expect_silent({
    list_rd <- rawRd("\\description{This is a {test} of LIST Rd_tags.}", quiet = TRUE)
    which_desc <- lapply(list_rd, attr, "Rd_tag") == "\\description"
    desc <- list_rd[which_desc][[1L]]
  })

  # confirm that we actually produced a LIST Rd_tag as part of our test
  expect_true(any(lapply(desc, attr, "Rd_tag") == "LIST"))

  # test rendering of LIST element, {test}
  expect_match(rd2markdown(list_rd), "is a test of")
})
