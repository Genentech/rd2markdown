test_that("rd2markdown works as expected for tables and new lines", {
  expect_silent(md <- rd2markdown(file = rd_filepaths[[2L]]))
  expect_match(substr(md, 1, 40), "adding \n\n||||||\n|:--|:--|:--|:--|:--|\n|mpg|cyl|disp|hp|drat|\n|21.0|6|160|110|3.90|\n|21.0|6|160|110|3.90|\n|22.8|4|108|93|3.85|\n|21.4|6|258|110|3.08|\n|18.7|8|360|175|3.15|\n\n")
})

test_that("rd2markdown works as expected for tables with blank lines", {
  table_rd <- rawRd("
    \\tabular{lll}{
       Rd \\tab Sampler \\tab Table \\cr
       rd \\tab sampler \\tab table \\cr
       \\cr
       Rd \\tab \\tab test
    }
  ")

  expect_silent(table_md <- rd2markdown(table_rd))

  # expect title line to be blank
  expect_true(grepl("||||", trimws(table_md)[[1L]]))

  # expect that one of the lines is blank
  expect_true(any(grepl("^||\\s*$", strsplit(trimws(table_md), "\n")[[1L]])))

  # expect that last line has an empty cell
  expect_true(any(grepl("|\\s*|", tail(strsplit(trimws(table_md), "\n")[[1L]], 1L))))
})

test_that("rd2markdown crops trialing \\cr, often added by roxygen2", {
  table_rd <- rawRd("
    \\tabular{lll}{
       Rd \\tab Sampler \\tab Table \\cr
       rd \\tab sampler \\tab table \\cr
    }
  ")

  expect_silent(table_md <- rd2markdown(table_rd))
  expect_length(strsplit(trimws(table_md), "\n")[[1L]], 4L)
})
