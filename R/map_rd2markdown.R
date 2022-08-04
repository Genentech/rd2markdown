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
  out <- clean_text_newlines(out)
  if (!is.null(collapse)) out <- paste0(out, collapse = collapse)
  out
}

#' Convert standalone TEXT tag newlines to cr
#'
#' `TEXT` `Rd_tag` newlines are discarded, unless they are standalone `TEXT`
#' tags with only a single newline character (and possible non-newline
#' whitespace) and both preceeded and followed by `TEXT` tags.
#'
#' @param x `list` of Rd tags
#' @keywords internal
#'
clean_text_newlines <- function(x) {
  n <- length(x)
  tags <- as.character(lapply(x, attr, "Rd_tag"))
  is_text <- tags == "TEXT"

  # convert TEXT to carriage returns if only whitespace with >=1 newline
  is_nl <- logical(n)
  is_nl[is_text] <- grepl("^\\s*\n\\s*$", x[is_text])
  x[is_text] <- gsub("\\s+$", " ", trimws(x[is_text], "left"))
  x[is_nl] <- list(rd2markdown.cr())
  is_nl <- vapply(x, is_cr, logical(1L))  # add new cr's to "is_nl"

  # filter leading and trailing whitespace-only TEXT tags
  first_non_nl <- Position(Negate(identity), is_nl, nomatch = n + 1)
  last_non_nl <- Position(Negate(identity), is_nl, nomatch = 0, right = TRUE)

  # trim consecutive carriage returns
  cons_nl <- logical(n)
  cons_nl[-1] <- is_nl[-n] & is_nl[-1]

  i <- seq_along(x)
  x[i >= first_non_nl & i <= last_non_nl & !cons_nl]
}
