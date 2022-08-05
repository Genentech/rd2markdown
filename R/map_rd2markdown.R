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



#' Process whitespace between elements
#'
#' `TEXT` `Rd_tag` newlines are discarded, unless they are standalone `TEXT`
#' tags with only a single newline character (and possible non-newline
#' whitespace) and both preceeded and followed by `TEXT` tags.
#'
#' @param x `list` of Rd tags
#' @keywords internal
#'
clean_text_newlines <- function(x) {
  x <- add_nl_around_md_blocks(x)

  n <- length(x)
  is_text <- vlapply(x, is_tag, "TEXT")

  # convert TEXT to carriage returns if only whitespace with >=1 newline
  is_nl <- logical(n)
  is_nl[is_text] <- grepl("^\\s*\n\\s*$", x[is_text])
  x[is_text] <- gsub("\\s+$", " ", trimws(x[is_text], "left"))
  x[is_nl] <- list(nl(2))
  is_nl <- vlapply(x, is_nl)  # add new cr's to "is_nl"

  # filter leading and trailing whitespace-only TEXT tags
  first_non_nl <- Position(Negate(identity), is_nl, nomatch = n + 1)
  last_non_nl <- Position(Negate(identity), is_nl, nomatch = 0, right = TRUE)

  # trim consecutive newlines
  cons_nl <- is_consecutive(is_nl)
  x[-n][cons_nl[-n]] <- list(nl(2))  # before removing, promote first nl to double nl

  i <- seq_along(x)
  x[i >= first_non_nl & i <= last_non_nl & !cons_nl]
}



is_consecutive <- function(x) {
  n <- length(x)
  cons <- logical(n)
  cons[-1] <- x[-1] & x[-n]
  cons
}



#' Add a newline block on either side of block elements
#'
#' Add newline elements such that each block element is surrounded by one
#' newline. Will not add newlines where one already exists.
#'
#' @param x `list` of markdown elements, either strings or `md_tag` elements
#' @examples
#' x <- list("p1", nl(2), "p2", block("list1"), block("list2"))
#' add_nl_around_md_blocks(x)
#' # list("p1", nl(2), "p2", nl(1), block("list1"), nl(1), block("list2"))
#' #                           ^                      ^
#'
add_nl_around_md_blocks <- function(x) {
  x_is_nl <- vlapply(x, is_nl)
  x_is_block <- vlapply(x, is_block)
  n <- length(x_is_block)

  # find beginnings of markdown blocks
  before_block <- logical(n)
  before_block[-n] <- x_is_block[-1] & !x_is_nl[-1]

  # find endings of markdown blocks
  after_block <- logical(n)
  after_block[-n] <- x_is_block[-n] & !x_is_nl[-n]

  # determine whether any newlines will be added (return if we can)
  new_nl_after <- (before_block | after_block) & !x_is_nl
  new_n <- n + sum(new_nl_after)
  if (new_n == n) return(x)

  # find indices where nl should be inserted
  new_nl_loc <- seq_along(x) + cumsum(new_nl_after)
  new_nl_loc <- new_nl_loc[new_nl_after]

  # inject new newlines so that there is a newline before and after each block
  length(x) <- new_n
  x[-new_nl_loc] <- x[1:n]
  x[new_nl_loc] <- list(nl(2))

  x
}
