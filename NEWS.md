rd2markdown 0.0.3
-----------------

* Stop trimming white signs in `rd2markdown.TEXT`. Instead if there is any new 
  line sign, double it to make proper paragraphs (#17 @maksymis)

rd2markdown 0.0.2
-----------------

* minor change to S3 method exports (#1 @dgkf)

* minor bug fix to header formatting (additional preceeding newline), which
  affects a subset of markdown renderers (#3 @dgkf)

* Add `macros` parameter to `get_rd()` function to allow handling of 
  custom macros while converting to markdown. (#6 @maksymiuks)
  
* Replace any possible `character(0)` with `""` in the `rd2markdown.tabular`,
  additional handling for missing lines/cells in table rendering 
  (#8 @maksymiuks, @dgkf)
  
rd2markdown 0.0.1
-----------------

* rd2markdown goes public
