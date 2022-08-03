#' Render a Rd object out to a markdown file
#'
#' @param x An Rd object, list, help topic or Rd tag to convert into
#'   markdown-formatted help.
#' @param fragments An optional vector of fragment tag names (such as
#'   "description", "details" or "title") to filter the Rd object tags.
#' @param ... Additional arguments used by specific methods.
#'
#' @details
#' rd2markdown is the core function of the package. can work in various types. It accepts .Rd objects
#' extracted with \code{\link[rd2markdown]{get_rd}} option but also can directly fetch documentation
#' topics based on the file path or the package. Due to the design, it follows, \code{rd2markdown} function has high flexibility.
#' It is worth pointing out that the actual output of \code{rd2markdown} function is a character vector of length one
#' that uses special signs to format the document. Use \code{\link[base]{writeLines}} function to create an actual markdown file using this output.
#' The \code{rd2markdown} function parses documentation object based on an innovative idea of treating each .Rd tag as a separate class
#' and implementing methods for those classes. Thanks to that the package is easily extensible and clear to understand. To see the list of currently supported
#' tags please see the Usage section.
#'
#' @export
#'
#' @examples
#'
#' # Using get_rd
#' rd_file_example <- system.file("examples", "rd_file_sample.Rd", package = "rd2markdown")
#' rd <- rd2markdown::get_rd(file = rd_file_example)
#' cat(rd2markdown::rd2markdown(rd))
#'
#' # Limit to particular sections
#' rd <- rd2markdown::get_rd(file = rd_file_example)
#' cat(rd2markdown::rd2markdown(rd, fragments = c("description", "usage")))
#'
#' # Use file parameter
#' cat(rd2markdown::rd2markdown(file = rd_file_example))
#'
#' # Use topic and package parameters
#' cat(
#'   rd2markdown::rd2markdown(
#'     topic = "rnorm",
#'     package = "stats",
#'     fragments = c("description", "usage")
#'   )
#' )
#'
#' @seealso \code{\link[rd2markdown]{get_rd}} \code{\link[rd2markdown]{documentation_to_markdown}}
rd2markdown <- function(x, fragments = c(), ...) {
  if (missing(x)) return(rd2markdown.character(x = x, fragments = fragments, ...))
  UseMethod("rd2markdown", x)
}

#' @exportS3Method
#' @rdname rd2markdown
rd2markdown.Rd <- function(x, fragments = c(), ...) {
  tag <- attr(x, "Rd_tag")
  if (is.null(tag)) map_rd2markdown(x, fragments = fragments, collapse = "", ...)
  else rd2markdown.list(x, fragments = fragments, ...)
}

#' @exportS3Method
#' @rdname rd2markdown
#' @method rd2markdown list
rd2markdown.list <- function(x, fragments = c(), ...) {
  fragname <- gsub("^\\\\", "", attr(x, "Rd_tag"))
  if (length(fragname) == 0) {
    map_rd2markdown(x, collapse = "")
  } else if (length(fragments) != 0 && !fragname %in% fragments) {
    NULL
  } else {
    UseMethod("rd2markdown", structure(0L, class = fragname))
  }
}

#' @exportS3Method
#' @rdname rd2markdown
rd2markdown.NULL <- function(x, fragments = c(), ...) {
  NULL
}

#' @exportS3Method
#' @rdname rd2markdown
rd2markdown.name <- rd2markdown.NULL

#' @exportS3Method
#' @rdname rd2markdown
rd2markdown.alias <- rd2markdown.NULL

#' @exportS3Method
#' @rdname rd2markdown
rd2markdown.keyword <- rd2markdown.NULL

#' @export
#' @rdname rd2markdown
rd2markdown.USERMACRO <- rd2markdown.NULL

#' @exportS3Method
#' @rdname rd2markdown
rd2markdown.code <- function(x, fragments = c(), ...) {
  sprintf("`%s`", paste0(capture.output(tools::Rd2txt(list(x), fragment = TRUE)), collapse = ""))
}

#' @exportS3Method
#' @rdname rd2markdown
rd2markdown.RCODE <- rd2markdown.code

#' @exportS3Method
#' @rdname rd2markdown
rd2markdown.verb <- rd2markdown.code

#' @exportS3Method
#' @rdname rd2markdown
rd2markdown.pkg <- rd2markdown.code

#' @exportS3Method
#' @rdname rd2markdown
rd2markdown.default <- function(x, fragments = c(), ...) {
  if (!is.list(x)) x <- list(x)
  txt <- capture.output(tools::Rd2txt(x, fragment = TRUE))
  paste0(paste0(escape_html_tags(txt), collapse = ""), " ")
}

#' @exportS3Method
#' @rdname rd2markdown
rd2markdown.title <- function(x, fragments = c(), ...) {
  sprintf("# %s\n", trimws(map_rd2markdown(x, ..., collapse = "")))
}

#' @param title optional section title
#'
#' @exportS3Method
#' @rdname rd2markdown
rd2markdown.description <- function(x, fragments = c(), ..., title = NULL) {
  out <- paste0("\n", map_rd2markdown(x, ..., collapse = ""), "\n")
  if (!is.null(title)) out <- sprintf("## %s\n%s\n", title, out)
  out <- gsub("\n{1,}$", "\n\n", out)
  out <- gsub("\n*\\\\lifecycle\\{(.*)\\}\n*", "\n\nLifecycle: *\\1*\n\n", out)
  out
}

#' @exportS3Method
#' @rdname rd2markdown
rd2markdown.author <- function(x, fragments = c(), ...) {
  rd2markdown.description(x, fragments = fragments, ..., title = "Author(s)")
}

#' @exportS3Method
#' @rdname rd2markdown
rd2markdown.format <- function(x, fragments = c(), ...) {
  rd2markdown.description(x, fragments = fragments, ..., title = "Format")
}

#' @exportS3Method
#' @rdname rd2markdown
rd2markdown.describe <- function(x, fragments = c(), ...) {
  rd2markdown.description(x, fragments = fragments, ...)
}

#' @exportS3Method
#' @rdname rd2markdown
rd2markdown.details <- function(x, fragments = c(), ...) {
  rd2markdown.description(x, fragments = fragments, ..., title = "Details")
}

#' @exportS3Method
#' @rdname rd2markdown
rd2markdown.note <- function(x, fragments = c(), ...) {
  rd2markdown.description(x, fragments = fragments, ..., title = "Note")
}

#' @exportS3Method
#' @rdname rd2markdown
rd2markdown.source <- function(x, fragments = c(), ...) {
  rd2markdown.description(x, fragments = fragments, ..., title = "Source")
}

#' @exportS3Method
#' @rdname rd2markdown
rd2markdown.value <- function(x, fragments = c(), ...) {
  rd2markdown.description(x, fragments = fragments, ..., title = "Returns")
}

#' @exportS3Method
#' @rdname rd2markdown
rd2markdown.section <- function(x, fragments = c(), ...) {
  title <- map_rd2markdown(x[[1]], collapse = "")
  rd2markdown.description(x[[2]], fragments = fragments, ..., title = title)
}

#' @exportS3Method
#' @rdname rd2markdown
rd2markdown.examples <- function(x, fragments = c(), ...) {
  rd2markdown.usage(x, fragments = fragments, ..., title = "Examples")
}

#' @exportS3Method
#' @rdname rd2markdown
rd2markdown.usage <- function(...) {
  rd2markdown.preformatted(..., language = "r")
}

#' @param title optional section title
#' @param language language to use as code fence syntax highlighter
#'
#' @exportS3Method
#' @rdname rd2markdown
rd2markdown.preformatted <- function(x, fragments = c(), ..., title = NULL, language = "") {
  code <- capture.output(tools::Rd2txt(list(x), fragment = TRUE))
  code <- tail(code, -1L)  # remove "usage" title
  code <- gsub("^\\n?\\s{5}", "", code)  # remove leading white space
  code <- sprintf("\n```%s\n%s\n```\n\n", language, trimws(paste0(code, collapse = "\n")))
  if (!is.null(title)) code <- sprintf("## %s\n%s", title, code)
  code
}

#' @exportS3Method
#' @rdname rd2markdown
rd2markdown.references <- function(x, fragments = c(), ...) {
  rd2markdown.description(x, fragments = fragments, ..., title = "References")
}

#' @exportS3Method
#' @rdname rd2markdown
rd2markdown.seealso <- function(x, fragments = c(), ...) {
  rd2markdown.description(x, fragments = fragments, ..., title = "See Also")
}

#' @exportS3Method
#' @rdname rd2markdown
rd2markdown.arguments <- function(x, fragments = c(), ...) {
  sprintf("## Arguments\n%s\n", map_rd2markdown(x, fragments = fragments, ..., collapse = ""))
}

#' @exportS3Method
#' @rdname rd2markdown
rd2markdown.dots <- function(x, fragments = c(), ...) {
  "`...`"
}

#' @exportS3Method
#' @rdname rd2markdown
rd2markdown.TEXT <- function(x, fragments = c(), ...) {
  gsub("\\s+", " ", gsub("\n", " ", x))
}

#' @exportS3Method
#' @rdname rd2markdown
rd2markdown.COMMENT <- function(x, fragments = c(), ...) {
  NULL
}

#' @param envir An optional environment in which to search for the help topic
#' @inheritParams get_rd
#'
#' @exportS3Method
#' @rdname rd2markdown
rd2markdown.character <- function(x = NULL, fragments = c(), ...,
  topic = NULL, package = NULL, file = NULL, macros = NULL, envir = parent.frame()) {

  # if we've ended up here as part of the tree, defer to list-style dispatch
  if (!missing(x) && !is.null(attr(x, "Rd_tag")))
    return(rd2markdown.list(x, fragments = fragments, ...))

  # otherwise, this is serving as a user-facing interface as topic search
  if (!missing(x) && is.null(package) && !is.null(x) && exists(x, envir = envir))
    package <- getNamespaceName(environment(get(x, envir = envir)))

  rd2markdown(
    get_rd(topic = topic, package = package, file = file, macros = macros),
    ...,
    fragments = fragments
  )
}

#' @exportS3Method
#' @rdname rd2markdown
rd2markdown.emph <- function(x, fragments = c(), ...) {
  sprintf("**%s**", map_rd2markdown(x, fragments = fragments, ..., collapse = ""))
}

#' @exportS3Method
#' @rdname rd2markdown
rd2markdown.item <- function(x, fragments = c(), ...) {
  itemname <- map_rd2markdown(x[[1]], fragments = fragments, ..., collapse = "")
  itemval <- map_rd2markdown(x[[2]], fragments = fragments, ..., collapse = "")
  itemval <- paste(strsplit(itemval, "\n")[[1]], collapse = "\n    ")
  sprintf("\n- **%s**: %s\n", itemname, itemval)
}

#' @exportS3Method
#' @rdname rd2markdown
rd2markdown.enumerate <- function(x, fragments = c(), ...) {
  is_item <- lapply(x, attr, "Rd_tag") == "\\item"
  x <- x[cumsum(is_item) > 0L & !is_item]
  is_item <- cumsum(is_item)[cumsum(is_item) > 0L & !is_item]
  items <- lapply(split(x, is_item), map_rd2markdown, collapse = "")
  items <- lapply(items, trimws)
  paste0("\n", paste0(sprintf("\n%s. %s\n", seq_along(items), items), collapse = ""), "\n", collapse = "")
}

#' @exportS3Method
#' @rdname rd2markdown
rd2markdown.itemize <- function(x, fragments = c(), ...) {
  items <- splitRdtag(x, "\\item")
  items <- vapply(items, map_rd2markdown, character(1L), ..., collapse = "")
  items <- Filter(nchar, trimws(items))
  items <- lapply(items, function(i) paste0(strsplit(i, "\n")[[1]], collapse = "\n    "))
  paste0("\n", paste0("\n * ", items, "\n", collapse = ""), "\n", collapse = "")
}

#' `LIST` Rd tags are produced with an unnamed infotex function call. Whereas
#' normal infotex syntax follows a \code{\\name\{arg\}} convention, naked
#' \code{{arg}} will be captured as a `LIST`. This syntax has been adopted as a
#' convention for package names. The desired rendering of this element is often
#' ambiguous. To try to accommodate as many cases as possible, it is rendered as
#' plain text.
#'
#' @exportS3Method
#' @rdname rd2markdown
rd2markdown.LIST <- function(x, fragments = c(), ...) {
  map_rd2markdown(x, fragments = fragments, ..., collapse = "")
}

#' @exportS3Method
#' @rdname rd2markdown
rd2markdown.tabular <- function(x, fragments = c(), ...) {
  just <- strsplit(x[[1]][[1]], "")[[1]]
  strheader <- paste(strrep("|", length(just) + 1L), collapse = " ")
  strjustline <- paste0("|", paste0(
    ifelse(
      just == "r", "--:", ifelse(
      just == "l", ":--", ifelse(
      just == "c", ":-:", ifelse(
      "---")))),
    collapse = "|"), "|")

  # split cells into nested lists of rows
  strbody <- splitRdtag(x[[2]], "\\cr")
  strbody <- lapply(strbody, splitRdtag, "\\tab")

  # render table cells individually, filter rows without cells
  strbody <- lapply(strbody, function(li, ...) {
    lapply(li, function(lli, ...) {
      cells <- map_rd2markdown(lli, fragments = fragments, ..., collapse = " ")
      trimws(gsub("\\|", "\\\\|", cells))
    })
  }, ...)

  # filter trailing empty lines
  last_line_with_content <- Position(
    function(line) sum(nchar(trimws(line))),
    strbody,
    right = TRUE,
    nomatch = 0L
  )

  strbody <- head(strbody, last_line_with_content)

  strbody <- vapply(strbody, function(i) paste0("|", paste0(i, collapse = "|"), "|"), character(1L))
  sprintf("\n%s\n%s\n%s\n",
    strheader,
    strjustline,
    paste0(strbody, collapse = "\n"))
}

#' @exportS3Method
#' @rdname rd2markdown
rd2markdown.tab <- function(x, fragments = c(), ...){
  structure("|", tag = "tab")
}

#' @exportS3Method
#' @rdname rd2markdown
rd2markdown.cr <- function(x, fragments = c(), ...) {
  structure("\n\n", tag = "cr")
}
