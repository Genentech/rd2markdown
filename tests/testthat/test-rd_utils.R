test_that("Rd documentation files can be filtered for specific fragments", {
  rd <- get_rd(file = file.path(test_path(), "data" , "man", "autovalidate.Rd"))
  expect_silent(frag <- rd_filter_fragments(rd, "title"))
  expect_length(frag, 1L)
  expect_equal(attr(frag[[1L]], "Rd_tag"), "\\title")
})

test_that("Markdown headers are appropriately converted to hash-style headers", {
  news_path <- file.path(test_path(), "data", "NEWS.md")
  news_file <- paste0(readLines(news_path), collapse = "\n")
  md <- convert_markdown_headers_to_hash(news_file)
  expect_true(any(grepl("(?m)^#\\s", md, perl = TRUE)))
  expect_true(any(grepl("(?m)^##\\s", md, perl = TRUE)))
})

test_that("HTML tags get escaped when processing Rd files", {
  expect_equal(escape_html_tags("<a>"), "\\<a\\>")
})
