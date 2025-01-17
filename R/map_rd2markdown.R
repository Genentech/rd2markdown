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
  out <- clean_text_whitespace(out)
  if (!is.null(collapse)) out <- paste0(out, collapse = collapse)
  out
}



#' Process whitespace between elements
#'
#' `TEXT` `Rd_tag` newlines are discarded, unless they are standalone `TEXT`
#' tags with only a single newline character (and possible non-newline
#' whitespace) and both preceeded and followed by `TEXT` tags (or no tag).
#'
#' @param x `list` of Rd tags
#' @keywords internal
#'
clean_text_newlines <- function(x) {
  x <- add_nl_around_md_blocks(x)

  n <- length(x)
  # No tag at all is in fact a text
  is_text <- vlapply(x, function(y) {
    is_tag(y, "TEXT") | is.null(attr(y, "Rd_tag"))
  })
  # convert TEXT to carriage returns if only whitespace with >=1 newline
  is_nl <- logical(n)
  is_nl[is_text] <- grepl("^\\s*\n\\s*$", x[is_text])
  # The first and the last elements cannot be proceeded by TEXT tag 
  is_nl[c(1, length(is_nl))] <- FALSE
  is_nl[is_nl] <- (is_text[which(is_nl) - 1] & is_text[which(is_nl) + 1])
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



#' Clean whitespace between text elements
#'
#' Within a series of text segments, the first text should have no leading
#' whitespace, and all but the last element should end with at most one space
#' character.
#'
#' @param x `list` of Rd tags
#'
#' @examples
#' \dontrun{
#' x <- list(" a ", "`b`", " c ", block(), " d   \n", "e   \n", "f")
#' clean_text_whitespace(x)
#' # list("a ", "`b`", " c ", block(), "d ", "e ", "f")
#'
#' x <- list(block(), " a ", "`b`", " c ", block(), " d ", "e ", "f", block())
#' clean_text_whitespace(x)
#' # list(block(), "a ", "`b`", " c ", block(), "d ", "e ", "f", block())
#' }
#'
#' @keywords internal
#'
clean_text_whitespace <- function(x) {
  x <- merge_text_spaces(x)
  n <- length(x)
  if (n < 1) return(x)

  # x is text
  x_is_text <- !(vlapply(x, is_block) | vlapply(x, is_nl))

  # x is the last text element in a non-block region
  x_is_text_end <- logical(n)
  x_is_text_end[n] <- x_is_text[n]
  x_is_text_end[-n] <- x_is_text[-n] & !x_is_text[-1]

  # x needs to be followed by a space if it ends in whitespace or if the next
  # element is text and begins with a space
  x_needs_space <- logical(n)
  x_needs_space[-n][x_is_text[-1]] <- grepl("^\\s", x[-1][x_is_text[-1]])
  x_needs_space[x_is_text] <- x_needs_space[x_is_text] | grepl("\\s$", x[x_is_text])
  x_needs_space <- x_is_text & x_needs_space & !x_is_text_end

  # for all text, retain at most one leading or trailing space character
  x[x_is_text] <- trimws(x[x_is_text])
  x[x_needs_space] <- paste0(x[x_needs_space], " ")

  x
}

#' Merge whitespace between text elements
#'
#' Within a series of text segments, there should be no separate text elements,
#' which are spaces only. These should be merged together and to the next 
#' non-space element if possible.
#' 
#' @param x `list` of Rd tags
#'
#' @examples
#' \dontrun{
#' x <- list(" a ", "`b`", " ", "  ", " c ", block(), "\n", "e   \n", "f")
#' merge_text_spaces(x)
#' # list(" a ", "`b`   ", " c ", block(), "\n", "e   \n", "f")
#'
#' x <- list(block(), " a ", "`b`", " c ", " ", block(), "   ",  " d ", "e ", "f", block())
#' merge_text_spaces(x)
#' # list(block(), "a ", "`b`", " c  ", block(), "    d ", "e ", "f", block())
#' }
#'
#' @keywords internal
merge_text_spaces <- function(x) {
  if (length(x) == 0) return(x)
  
  # assumes length x > 0
  spaces <- grepl("^ *$", x, perl = TRUE)
  is_text <- !spaces
  blocks <- vlapply(x, is_block)
  lag_blocks <- c(FALSE, blocks[-length(x)])
  
  # find cells within each block that follow at least one non-space element
  block_text_start <- cumsum(is_text) * blocks
  block_text_index <- cumsum(is_text) - cumsum(block_text_start)
  is_block_first_text <- block_text_index <= 1
  
  # determine which spans of elements need to be flattened
  groups <- cumsum(is_text & !is_block_first_text | blocks | lag_blocks)
  
  # collapse non-block groups, maintain first-in-group's attributes
  unname(lapply(split(x, groups), function(group) {
    if (is_block(group[[1]])) {
      group[[1]]
    } else  {
      atts <- attributes(group[[1]])
      result <- paste(group, collapse = "")
      attributes(result) <- atts
      result
    }
  }))
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
#' \dontrun{
#' x <- list("p1", nl(2), "p2", block("list1"), block("list2"))
#' add_nl_around_md_blocks(x)
#' # list("p1", nl(2), "p2", nl(1), block("list1"), nl(1), block("list2"))
#' #                           ^                      ^
#' }
#'
#' @keywords internal
#'
add_nl_around_md_blocks <- function(x) {
  n <- length(x)
  if (n < 1) return(x)

  x_is_nl <- vlapply(x, is_nl)
  x_is_block <- vlapply(x, is_block)

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
