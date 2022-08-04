#' Apply rd2markdown across Rd fragments
#'
#' @param frags a list of Rd fragments to apply over
#' @param collapse NULL, the default, does no collapsing. If a character value
#'   is provided, the string results of apply [rd2markdown] are collapsed by joining by
#'   the provided value.
#' @param ... Additional arguments passed to subsequent [rd2markdown] calls.
#'
#' @family rd2markdown
#' @keywords internal
#'
map_rd2markdown <- function(frags, ..., collapse = NULL) {
  out <- lapply(frags, rd2markdown, ...)
  out <- Filter(Negate(is.null), out)
  out <- Filter(nchar, out)
  if (!is.null(collapse)) {
    out <- paste0(out, collapse = collapse)
    # Irrelevant form the rendering point of view, just for styling reasons
    out <- trim_extra_newlines(out)
  } 
  out
}
