rd2markdown 0.0.7
-----------------

* Add `rd2markdown.subsection` to further support various .Rd structures. And 
  explicitly enhances the support for the inst/NEWS.rd files. (`?utils::news`)

* `rd2markdown.section` now returns output as a block to make sure it is 
  wrapped with new lines and renders sections properly.
  
* add `merge_text_spaces` functions that merges standalone TEXT 
  spaces (`" "`) into surrounding TEXT tags. Excessive spaces are not rendered
  by markdown and therefore can be appended to other meaningful tags. (To later
  get reduced by the "clean_text_whitespace")
  
* Add `levels` parameter to most of the tags that could be nested in subsection
  to make sure proper amount of `#` is appended.

rd2markdown 0.0.6
-----------------

* `rd2markdown.item` no longer throws an error if `\\item` tag was miss used in
  the .Rd file and is read as `list()`.

rd2markdown 0.0.5
-----------------

* `\code{}` no longer throws unnecessary warnings for long `\code{}` contents.
  (#28 @dgkf)


rd2markdown 0.0.4
-----------------

* Fix the bug where empty `\verb{}` tag would cause `rd2markdown.code` to throw unexpected 
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
