#' Build a list of documentation files rendered out to markdown
#'
#' @details
#' The function provides a vectorized way of extracting multiple documentation
#' objects at once based on paths to the .Rd files sources. The file path will
#' be truncated with \code{\link[base]{basename}}, and used as a name for the
#' output list. Use \code{fragments} parameter whenever you want to limit
#' extracted documentation only to some parts.
#'
#' @param rdfilepaths A character vector of Rd documentation file paths.
#' @inheritParams rd2markdown
#'
#' @return A named list of character vectors of length one with the markdown content.
#' The names are dervied from the paths, see the details for more information.
#'
#' @export
#'
#' @examples
#'
#' rd_file_example <- system.file("examples", "rd_file_sample.Rd", package = "rd2markdown")
#' rd_file_example_2 <- system.file("examples", "rd_file_sample_2.Rd", package = "rd2markdown")
#'
#' # Extract full documentation for two files
#' rd2markdown::documentation_to_markdown(c(rd_file_example, rd_file_example_2))
#'
#' # Limit to particular sections
#' rd2markdown::documentation_to_markdown(c(rd_file_example, rd_file_example_2),
#'   fragments = c("details"))
#'
#' @seealso \code{\link[rd2markdown]{rd2markdown}} \code{\link[rd2markdown]{get_rd}}
documentation_to_markdown <- function(
    rdfilepaths,
    fragments = c("title", "usage", "description", "details")) {

  rds <- mapply(get_rd, file = rdfilepaths, SIMPLIFY = FALSE)
  max_n <- nchar(length(rdfilepaths))
  docmds <- lapply(rds, rd2markdown, fragments = fragments)
  names(docmds) <- basename(rdfilepaths)

  docmds
}
