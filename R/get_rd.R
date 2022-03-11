#' Safely retrieve help documentation objects
#' 
#' The function is using function provided by utils package, to retrieve a R documentation object.
#' It retrieve documentation either directly form the source .Rd file, or extract it using
#' \code{\link[utils]{help}} function. See Arguments section to get to know more about when each mode
#' is called.
#'
#' @inheritParams utils::help
#' @param file Alternatively, provide a \code{.Rd} filepath. When \code{file} is
#'   provided, other arguments are ignored.
#'
#' @examples 
#' # Retrieve documentation directly form the .Rd file
#' rd_file_example <- system.file("examples", "rd_file_sample.Rd", package = "rd2markdown")
#' rd2markdown::get_rd(file = rd_file_example)
#' 
#' # Retrieve documentation from an installed package
#' rd2markdown::get_rd(topic = "rnorm", package = "stats")
#'   
#' @export
get_rd <- function(topic, package, file = NULL) {
  if (!is.null(file)) {
    rd <- tools::parse_Rd(file = file, permissive = TRUE)
    rd <- .tools$processRdSexprs(rd,
                                 stage = "render",
                                 macros = .tools$initialRdMacros())
  } else {
    tryCatch({
      h <- do.call(help, list(topic = topic, package = package))
      rd <- .utils$.getHelpFile(h[[1]])
      .tools$processRdSexprs(rd,
                             stage = "render",
                             macros = .tools$initialRdMacros())
    }, error = function(e) {
      e
    })
  }
}
