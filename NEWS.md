rd2markdown 0.0.4
-----------------

* Fix the bug where empty `\verba{}` tag would cause `rd2markdown.code` to throw unexpected 
  warnings and NAs (#22 @maksymiuks).


rd2markdown 0.0.3
-----------------

* Stop trimming white signs in `rd2markdown.TEXT` and `map_rd2markdown`. This
  should ensure that paragraphs are applied whenever they are necessary
  instead of being skipped. (#17 @maksymiuks, @dgkf)

* Enhance behavior of the `rd2markdown.character` function allowing it 
  to discover improper arguments names and rise meaningful errors. (@maksymiuks)

rd2markdown 0.0.2
-----------------

* Adding preformatted code block handling (#15 @dgkf)

* Minor change to S3 method exports (#1 @dgkf)

* Minor bug fix to header formatting (additional preceeding newline), which
  affects a subset of markdown renderers (#3 @dgkf)

* Add `macros` parameter to `get_rd()` function to allow handling of 
  custom macros while converting to markdown. (#6 @maksymiuks)
  
* Replace any possible `character(0)` with `""` in the `rd2markdown.tabular`,
  additional handling for missing lines/cells in table rendering 
  (#8 @maksymiuks, @dgkf)
  
rd2markdown 0.0.1
-----------------

* rd2markdown goes public
