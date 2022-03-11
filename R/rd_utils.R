#' Filter an Rd object for fragments by Rd_tag
#'
#' @param x An Rd object, as produced by `tools::parse_Rd`
#' @param fragments A `character` vector of fragment tags to filter on
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
#' @note This functionality has been moved upstream into \code{autovalidate}. It
#'   is liable to being removed.
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
