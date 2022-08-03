#' Rd sampler title
#'
#' @description
#'
#' Rd sampler description with [Rd sampler link](https://cran.r-project.org/), `Rd sampler
#' in-line code`. And `r var <- "Rd dynamic content"; var`, _italics text_,
#' *emphasis text*.
#'
#' @details
#'
#' Rd sampler details
#'
#' Rd sampler enumerated list
#' 1. One
#' 2. Two
#' 3. Three
#'
#' Rd sampler itemized list
#' * One
#' * Two
#' * Three
#'
#' | Rd | Sampler | Table |
#' |----|---------|-------|
#' | rd | sampler | table |
#'
#' ```
#' preformatted code
#' ```
#'
#' \eqn{Rd + sampler + inline + equation}
#'
#' \deqn{Rd * sampler * block * equation}
#'
#' # Rd sampler subsection
#'
#' Rd sampler subsection text
#'
#' ## Rd sampler sub-subsection
#'
#' Rd sampler sub-subsection text
#'
#' @note Rd sampler note
#'
#' @param x Rd object
#' @param fragments Rd fragments
#' @param ... Rd sampler ellipsis param
#'
#' @return Rd sampler return
#'
#' @examples
#' print("Hello, World")
#'
#' @family rd_samplers
#' @seealso base::print
#'
#' @references
#' R.D. Sampler. (1999)
#'
#' @author R.D. Sampler.
#'
#' @rdname rd_sampler
#' @name rd_sampler
#'
#' @importFrom utils help
#' @keywords internal
rd_sampler <- function(x, fragments, ...) {
  utils::help("rd_sampler", package = packageName())
}
