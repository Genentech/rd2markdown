test_that("rd2markdown can be used as markdown wrapper around `help` formal arguments", {
  expect_silent(md <- rd2markdown(topic = "test_that", package = "testthat"))
  expect_true(nchar(md) > 100L)  # insure we've actually retrieved some docs
  expect_silent(md <- rd2markdown(topic = "test_that"))
  expect_true(nchar(md) > 100L)  # insure we've actually retrieved some docs
})

test_that("rd2markdown can operate on a list of fragments", {
  rd <- get_rd(file = file.path(test_path(), "data", "man", "rd_sampler.Rd"))
  expect_equal(rd2markdown(rd), rd2markdown(as.list(rd)))
})

test_that("rd2markdown always includes an empty newline before a section title", {
  rd <- get_rd(file = file.path(test_path(), "data", "man", "rd_sampler.Rd"))
  expect_silent(md <- rd2markdown(rd))

  # expect all sections (starting with # headers) to be preceeded by two newlines
  expect_silent(sections <- strsplit(md, "#+\\s*")[[1L]][-1L])

  # omit first (before first header) and last (no following section)
  expect_true(all(grepl("\n{2,}$", head(sections, -1L))))
})

test_that("Rd fragments can be split on Rd_tag, such as for list elements", {
  rd <- get_rd(file = file.path(test_path(), "data", "man", "rd_sampler.Rd"))
  expect_silent(details <- rd_filter_fragments(rd, "details")[[1L]])
  expect_silent(itemize <- rd_filter_fragments(details, "itemize")[[1L]])
  expect_silent(items <- splitRdtag(itemize, "\\item"))
  expect_equal(length(items), sum(vapply(itemize, attr, character(1L), "Rd_tag") == "\\item") + 1L)
  expect_silent(enumerate <- rd_filter_fragments(details, "enumerate")[[1L]])
  expect_silent(items <- splitRdtag(itemize, "\\item"))
  expect_equal(length(items), sum(vapply(enumerate, attr, character(1L), "Rd_tag") == "\\item") + 1L)
})


test_that("Rd document titles are properly rendered to markdown", {
  rd <- get_rd(file = file.path(test_path(), "data", "man", "rd_sampler.Rd"))
  title_frag <- rd[sapply(rd, function(i) attr(i, "Rd_tag") == "\\title")]
  title <- title_frag[[1]][[1]]
  expect_match(rd2markdown(title_frag), paste0("# ", title))
})

test_that("Rd document descriptions are properly rendered to markdown", {
  rd <- get_rd(file = file.path(test_path(), "data", "man", "rd_sampler.Rd"))
  description_frag <- rd[sapply(rd, function(i) attr(i, "Rd_tag") == "\\description")]
  description <- description_frag[[1]][[2]]
  expect_silent(md <- rd2markdown(description_frag))
  expect_match(trimws(md), trimws(description))
  expect_match(md, "\n.*\n")
})

test_that("Rd document authors are properly rendered to markdown", {
  rd <- get_rd(file = file.path(test_path(), "data", "man", "rd_sampler.Rd"))
  author_frag <- rd[sapply(rd, function(i) attr(i, "Rd_tag") == "\\author")]
  author <- author_frag[[1]][[2]]
  expect_silent(md <- rd2markdown(author_frag))
  expect_match(trimws(md), trimws(author))
  expect_match(md, "## Author\\(s\\)\n\n.*\n\n")
})

test_that("Rd document usage is properly rendered to markdown", {
  rd <- get_rd(file = file.path(test_path(), "data", "man", "rd_sampler.Rd"))
  usage_frag <- rd[sapply(rd, function(i) attr(i, "Rd_tag") == "\\usage")]
  usage <- usage_frag[[1]][[2]]
  expect_silent(md <- rd2markdown(usage_frag))
  expect_match(trimws(md), trimws(usage), fixed = TRUE)
  expect_match(md, "\n```r\n.*\n```\n\n")
})

test_that("Rd document examples are properly rendered to markdown", {
  rd <- get_rd(file = file.path(test_path(), "data", "man", "rd_sampler.Rd"))
  examples_frag <- rd[sapply(rd, function(i) attr(i, "Rd_tag") == "\\examples")]
  examples <- examples_frag[[1]][[2]]
  expect_silent(md <- rd2markdown(examples_frag))
  expect_match(trimws(md), trimws(examples), fixed = TRUE)
  expect_match(md, "\n```r\n.*\n```\n\n")
})

test_that("Rd document details are properly rendered to markdown", {
  rd <- get_rd(file = file.path(test_path(), "data", "man", "rd_sampler.Rd"))
  details_frag <- rd[sapply(rd, function(i) attr(i, "Rd_tag") == "\\details")][[1]]
  pre_frag <- details_frag[sapply(details_frag, function(i) attr(i, "Rd_tag") == "\\preformatted")][[1]]
  expect_silent(md <- rd2markdown(pre_frag))
  expect_match(trimws(md), trimws(pre_frag[[1L]]), fixed = TRUE)
  expect_match(md, "^\\s*```")
  expect_match(md, "```\\s*$")
})

test_that("Rd document preformatted code blocks are properly rendered to markdown", {
  rd <- get_rd(file = file.path(test_path(), "data", "man", "rd_sampler.Rd"))
  details_frag <- rd[sapply(rd, function(i) attr(i, "Rd_tag") == "\\details")]
  expect_silent(md <- rd2markdown(detail_frag))
  expect_match(trimws(md), trimws(detail_frag[[1L]][[2L]]), fixed = TRUE)
  expect_match(trimws(md), trimws(detail_frag[[1L]][[8L]]), fixed = TRUE)
  expect_match(md, "## Details\n\n.*\n\n")
})

test_that("Rd data document format is properly rendered to markdown", {
  rd <- get_rd(file = file.path(test_path(), "data", "man", "rd_data_sampler.Rd"))
  format_frag <- rd[sapply(rd, function(i) attr(i, "Rd_tag") == "\\format")]
  expect_silent(md <- rd2markdown(format_frag))
  expect_match(md, trimws(format_frag[[1L]][[2L]]))
  expect_match(md, "## Format\n\n.*\n\n")
})

test_that("Rd data document source is properly rendered to markdown", {
  rd <- get_rd(file = file.path(test_path(), "data", "man", "rd_data_sampler.Rd"))
  source_frag <- rd[sapply(rd, function(i) attr(i, "Rd_tag") == "\\source")]
  expect_silent(md <- rd2markdown(source_frag))
  expect_match(md, trimws(source_frag[[1L]][[2L]]))
  expect_match(md, "## Source\n\n.*\n\n")
})

test_that("rd2markdow works as expected with x missing", {
  expect_silent(md <- rd2markdown(file = file.path(test_path(), "data", "man", "rd_data_sampler.Rd")))
  expect_match(substr(md, 1, 40), "data # Rd data sampler\n## Format\n\nA data")
})
