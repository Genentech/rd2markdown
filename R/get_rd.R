# constants
DEFAULT_R_MACROS <- file.path(R.home("share"), "Rd", "macros", "system.Rd")

#' Safely retrieve help documentation objects
#'
#' The function is using function provided by utils package, to retrieve a R
#' documentation object.  It retrieve documentation either directly form the
#' source .Rd file, or extract it using \code{\link[utils]{help}} function. See
#' Arguments section to get to know more about when each mode is called.
#'
#' @inheritParams utils::help
#' @inheritParams tools::parse_Rd
#' @param file Alternatively, provide a \code{.Rd} filepath. When \code{file} is
#'   provided, other arguments are ignored.
#'   
#' @details 
#' \code{macros} and \code{file} parameters are used directly by the 
#' \code{tools::parse_Rd} function. Please refer to details of this 
#' function to get to know more about their usage. The \code{rd2markdown}
#' package adds an additional behavior to the original \code{macros}. If it is
#' \code{NA} then \code{get_rd} will try to find macros directory
#' associated with passed file and pass it to \code{tools::parse_Rd}.
#'
#' @examples
#' # Retrieve documentation directly form the .Rd file
#' rd_file_example <- system.file("examples", "rd_file_sample.Rd", package = "rd2markdown")
#' rd2markdown::get_rd(file = rd_file_example)
#'
#' # Retrieve documentation from an installed package
#' rd2markdown::get_rd(topic = "rnorm", package = "stats")
#' 
#' # Auto discover macros
#' rd2markdown::get_rd(file = rd_file_example, macros = NA)
#'   
#' @export
get_rd <- function(
    topic,
    package,
    file = NULL,
    # Deafult R macros location defined in R documentation
    macros = NULL) {
  if (!is.null(file)) {
    macros <- if (is.null(macros) && (root <- find_package_root(file)) != "") {
      tools::loadPkgRdMacros(root)
    } else if (is.null(macros)) {
      tools::loadRdMacros(DEFAULT_R_MACROS)
    } else if (!is.null(macros) && is.character(macros)) {
      tools::loadRdMacros(macros)
    } else {
      macros
    }
    
    rd <- tools::parse_Rd(file = file, permissive = TRUE, macros = macros)
    .tools$processRdSexprs(
      rd,
      stage = "render",
      macros = tools::loadRdMacros(DEFAULT_R_MACROS, macros = macros)
    )
  } else {
    tryCatch({
      h <- do.call(help, list(topic = topic, package = package))
      rd <- .utils$.getHelpFile(h[[1]])
      .tools$processRdSexprs(
        rd,
        stage = "render",
        macros = tools::loadRdMacros(DEFAULT_R_MACROS)
      )
    }, error = function(e) {
      e
    })
  }
}
