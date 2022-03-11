test_that("documentation_to_markdown() works deafult params", {
  doc_files <- documentation_to_markdown(c(file.path(test_path(), "data" , "man", "autovalidate.Rd"),
                                           file.path(test_path(), "data" , "man", "avu_log.Rd")))
  expect_identical(substr(doc_files[[1]], 1, 45), 
                   "# Write out an assortment of package metadata")
  expect_identical(substr(doc_files[[2]], 1, 45), 
                   "# Log to the autovalidateutils log file\n\n```r")
  expect_named(doc_files)
  expect_length(doc_files, 2)
  
})

test_that("documentation_to_markdown() works custom params", {
  doc_files <- documentation_to_markdown(c(file.path(test_path(), "data" , "man", "autovalidate.Rd"),
                                           file.path(test_path(), "data" , "man", "avu_log.Rd")),
                                         "details")
  expect_identical(doc_files[[1]], 
                   "## Details\n\nSome details content \n\n")
  expect_identical(doc_files[[2]], 
                   "")
  expect_named(doc_files)
  expect_length(doc_files, 2)
})