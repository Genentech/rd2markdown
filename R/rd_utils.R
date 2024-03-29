#' Filter an Rd object for fragments by Rd_tag
#'
#' @param x An Rd object, as produced by `tools::parse_Rd`
#' @param fragments A `character` vector of fragment tags to filter on
#' @keywords internal
#'
rd_filter_fragments <- function(x, fragments = c()) {
  fragments <- paste0("\\", tolower(fragments))
  tags <- lapply(x, attr, "Rd_tag")
  x[tags %in% fragments]
}


#' Convert markdown headers to hash-style
#'
#' @param md A markdown-formatted character value or vector to convert.
#'
#' @keywords internal
#'
convert_markdown_headers_to_hash <- function(md) {
  md <- gsub("(?m)(^|\n)([^\n]*)\\s*\n\\s{0,3}---+(\\s*\n|$)", "\\1# \\2\\3", md, perl = TRUE)
  md <- gsub("(?m)(^|\n)([^\n]*)\\s*\n\\s{0,3}===+(\\s*\n|$)", "\\1## \\2\\3", md, perl = TRUE)
  md
}


#' Split a list of Rd fragments at fragments with a specified Rd_tag
#'
#' Some Rd structures, such as enumerated lists and tables are separated by
#' placeholder Rd_tags. This function is a convenience function for splitting
#' those lists into components at the indices of fragments with the provided
#' tag.
#'
#' @param frags a list of Rd fragments to split
#' @param tag the Rd_tag value upon which the list of Rd fragments should be
#'   split
#'
#' @family rd2markdown
#' @keywords internal
#'
splitRdtag <- function(frags, tag) {
  istag <- lapply(frags, attr, "Rd_tag") == tag
  frags <- frags[!istag]
  istag <- cumsum(istag)[!istag]
  unname(split(frags, istag))
}

escape_html_tags <- function(str) {
  gsub("(<|>)", "\\\\\\1", str)
}

#' Trim non-meaningful markdown newlines
#'
#' Markdown does not render single newline character just like it does not
#' render more than two newline characters. Therefore we strip those unnecessary
#' newline characters to make them display in a cleaner way.
#'
#' @param x `character` vector to process
#'
#' @keywords internal
#'
trim_extra_newlines <- function(x) {
  # non-newline whitespace
  ws <- "[^\\S\r\n]"
  re1 <- paste0(ws, "+", "(\n\\b)?")
  re2 <- paste0("(\n", ws, "*){2,}")
  gsub(re1, " ", gsub(re2, "\n\n", x, perl = TRUE), perl = TRUE)
}


indent_newlines <- function(x, indent = 2) {
  paste0(
    strsplit(x, "\n")[[1]],
    collapse = paste0("\n", strrep(" ", indent))
  )
}


with_md_title <- function(md, title, level, ...) {
  if (is.null(title)) return(block(I(md)))
  title <- paste0(strrep("#", level), " ", title)
  map_rd2markdown(list(block(I(title)), block(I(md))), ..., collapse = "")
}
