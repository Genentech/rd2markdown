#' Apply rd2markdown across Rd fragments
#'
#' @param frags a list of Rd fragments to apply over
#' @param collapse NULL, the default, does no collapsing. If a character value
#'   is provided, the string results of apply [rd2markdown] are collapsed by joining by
#'   the provided value.
#' @param ... Additional arguments passed to subsequent [rd2markdown] calls.
#'
#' @family rd2markdown

map_rd2markdown <- function(frags, ..., collapse = NULL) {
  out <- lapply(frags, function(i, ...) rd2markdown(i, ...), ...)
  out <- Filter(Negate(is.null), out)
  out <- Filter(function(i) {
    tag <- attr(i, "tag")
    if (!is.null(tag) && tag == "cr") {
      nchar(i)
    } else {
      nchar(trimws(i))
    }
  }, out)
  if (!is.null(collapse)) out <- paste0(out, collapse = collapse)
  out
}
