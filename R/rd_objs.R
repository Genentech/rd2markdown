is_tag <- function(x, tag) {
  !is.null(xtag <- attr(x, "Rd_tag")) && xtag == tag
}

is_ws <- function(x, tag) {
  is_tag(x, "TEXT") && regexec("^\\s*$", x) > 0
}



#' Single newline
#'
#' @keywords internal
#'
nl <- function(n = 1) {
  structure(strrep("\n", n), n = n, md_tag = "nl")
}

is_nl <- function(x) {
  !is.null(tag <- attr(x, "md_tag")) && tag == "nl"
}



#' Tag a section as a "block"
#'
#' Markdown blocks are sections of markdown which should not be re-wrapped. This
#' includes things like enumerated lists, itemized lists and tables. Their
#' individual items might be wrapped, but the block element should always be
#' surrounded by newlines.
#'
#' @keywords internal
#'
block <- function(x = "") {
  structure(x, md_tag = "block")
}

is_block <- function(x) {
  !is.null(tag <- attr(x, "md_tag")) && tag == "block"
}
