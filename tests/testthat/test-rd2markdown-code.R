test_that("rd2markdown code tags wrap code in single backticks", {
  rd <- rawRd("\\code{1 + 2}")
  expect_silent(md <- rd2markdown(rd))
  expect_equal(md, "`1 + 2`")
})

test_that("rd2markdown long code tags do not emit warnings (#28)", {
  rd <- rawRd("\\code{a b c d e f g h i j k l m n o p q r s t u v w x y z a b c d e f g h i j k l m n o p q r s t u v w x y z}")
  expect_silent(md <- rd2markdown(rd))
})
