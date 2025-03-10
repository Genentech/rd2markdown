#' Render a Rd object out to a markdown file
#'
#' @param x An Rd object, list, help topic or Rd tag to convert into
#'   markdown-formatted help.
#' @param fragments An optional vector of fragment tag names (such as
#'   "description", "details" or "title") to filter the Rd object tags.
#' @param ... Additional arguments used by specific methods.
#' @param level Level (number of #') of the root section (title). Defaults to 1L
#'
#' @details
#' rd2markdown is the core function of the package. can work in various types.
#' It accepts .Rd objects extracted with \code{\link[rd2markdown]{get_rd}}
#' option but also can directly fetch documentation topics based on the file
#' path or the package. Due to the design, it follows, \code{rd2markdown}
#' function has high flexibility.  It is worth pointing out that the actual
#' output of \code{rd2markdown} function is a character vector of length one
#' that uses special signs to format the document. Use
#' \code{\link[base]{writeLines}} function to create an actual markdown file
#' using this output.  The \code{rd2markdown} function parses documentation
#' object based on an innovative idea of treating each .Rd tag as a separate
#' class and implementing methods for those classes. Thanks to that the package
#' is easily extensible and clear to understand. To see the list of currently
#' supported tags please see the Usage section.
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
rd2markdown.Rd <- function(x, fragments = c(), ..., level = 1L) {
  tag <- attr(x, "Rd_tag")
  if (is.null(tag)) map_rd2markdown(x, fragments = fragments, collapse = "", ..., level = level)
  else rd2markdown.list(x, fragments = fragments, ..., level = level)
}

#' @exportS3Method
#' @rdname rd2markdown
#' @method rd2markdown list
rd2markdown.list <- function(x, fragments = c(), ..., level = 1L) {
  fragname <- gsub("^\\\\", "", attr(x, "Rd_tag"))
  if (length(fragname) == 0) {
    map_rd2markdown(x, collapse = "", level = level)
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
rd2markdown.AsIs <- function(x, fragments = c(), ...) {
  # for tags that have already been processed, use I() to differentiate them
  # from unknown Rd tags
  x
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

#' @exportS3Method
#' @rdname rd2markdown
rd2markdown.concept <- rd2markdown.NULL

#' @export
#' @rdname rd2markdown
rd2markdown.USERMACRO <- rd2markdown.NULL

#' @exportS3Method
#' @rdname rd2markdown
rd2markdown.code <- function(x, fragments = c(), ...) {
  opts <- list(code_quote = FALSE)
  code <- capture.output(tools::Rd2txt(list(x), fragment = TRUE, options = opts))
  code <- paste0(code, collapse = "")

  # safely handle zero-length code tags
  if (length(code) == 0 || sum(nchar(code)) == 0)
    return("` `")

  max_cons_backticks <- max(nchar(strsplit(gsub("[^`]+", " ", code), "\\s+")[[1]]))
  structure(
    sprintf("%2$s%1$s%2$s", code, strrep("`", max_cons_backticks + 1)),
    Rd_tag = "code_TEXT"
  )
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
rd2markdown.env <- rd2markdown.code

#' @exportS3Method
#' @rdname rd2markdown
rd2markdown.default <- function(x, fragments = c(), ...) {
  if (!is.list(x)) x <- list(x)
  txt <- capture.output(tools::Rd2txt(x, fragment = TRUE))
  paste0(paste0(escape_html_tags(txt), collapse = ""), " ")
}

#' @exportS3Method
#' @rdname rd2markdown
rd2markdown.title <- function(x, fragments = c(), ..., level = 1L) {
  block(paste0(strrep("#", level), " ", trimws(map_rd2markdown(x, ..., collapse = "", level = level))))
}

#' @param title optional section title
#'
#' @exportS3Method
#' @rdname rd2markdown
rd2markdown.description <- function(x, fragments = c(), ..., title = "Description", level = 1L) {
  # Increment level as in the rd object descriptions and title are on the same
  # level whereas in md they shouldn't be
  level <- level + 1
  out <- map_rd2markdown(x, ..., collapse = "", level = level)
  out <- gsub("\n{1,}$", "", out)
  out <- gsub("\n*\\\\lifecycle\\{(.*)\\}\n*", "\n\nLifecycle: *\\1*\n\n", out)
  # We need to make sure that sections are separated with new lines signs.
  # As markdown ignores extra new line signs when rendering documents. We are
  # safe to do it greedily
  block(with_md_title(out, title, level, ...))
}

#' @exportS3Method
#' @rdname rd2markdown
rd2markdown.author <- function(x, fragments = c(), ..., level = 1L) {
  rd2markdown.description(x, fragments = fragments, ..., title = "Author(s)", level = level)
}

#' @exportS3Method
#' @rdname rd2markdown
rd2markdown.format <- function(x, fragments = c(), ..., level = 1L) {
  rd2markdown.description(x, fragments = fragments, ..., title = "Format", level = level)
}

#' @exportS3Method
#' @rdname rd2markdown
rd2markdown.details <- function(x, fragments = c(), ..., level = 1L) {
  rd2markdown.description(x, fragments = fragments, ..., title = "Details", level = level)
}

#' @exportS3Method
#' @rdname rd2markdown
rd2markdown.note <- function(x, fragments = c(), ..., level = 1L) {
  rd2markdown.description(x, fragments = fragments, ..., title = "Note", level = level)
}

#' @exportS3Method
#' @rdname rd2markdown
rd2markdown.source <- function(x, fragments = c(), ..., level = 1L) {
  rd2markdown.description(x, fragments = fragments, ..., title = "Source", level = level)
}

#' @exportS3Method
#' @rdname rd2markdown
rd2markdown.value <- function(x, fragments = c(), ..., level = 1L) {
  rd2markdown.description(x, fragments = fragments, ..., title = "Returns", level = level)
}

#' @exportS3Method
#' @rdname rd2markdown
rd2markdown.section <- function(x, fragments = c(), ..., level = 1L) {
  title <- map_rd2markdown(x[[1]], collapse = "")
  rd2markdown.description(x[[2]], fragments = fragments, ..., title = title, level = level)
}

#' @exportS3Method
#' @rdname rd2markdown
rd2markdown.subsection <- function(x, fragments = c(), ..., level = 1L) {
  rd2markdown.section(x, fragments, ..., level = level)
}

#' @exportS3Method
#' @rdname rd2markdown
rd2markdown.examples <- function(x, fragments = c(), ..., level = 1L) {
  rd2markdown.usage(x, fragments = fragments, ..., title = "Examples", level = level)
}

#' @exportS3Method
#' @rdname rd2markdown
rd2markdown.usage <- function(..., level = 1L) {
  block(rd2markdown.preformatted(..., language = "r", level = level))
}

#' @param title optional section title
#' @param language language to use as code fence syntax highlighter
#'
#' @exportS3Method
#' @rdname rd2markdown
rd2markdown.preformatted <- function(x, fragments = c(), ..., title = NULL, language = "", level = 1L) {
  level <- level + 1
  code <- capture.output(tools::Rd2txt(list(x), fragment = TRUE))
  code <- tail(code, -1L)  # remove "usage" title
  code <- gsub("^\\n?\\s{5}", "", code)  # remove leading white space
  code <- sprintf("```%s\n%s\n```", language, trimws(paste0(code, collapse = "\n")))
  with_md_title(code, title, level, ...)
}

#' @exportS3Method
#' @rdname rd2markdown
rd2markdown.references <- function(x, fragments = c(), ..., level = 1L) {
  rd2markdown.description(x, fragments = fragments, ..., title = "References", level = level)
}

#' @exportS3Method
#' @rdname rd2markdown
rd2markdown.seealso <- function(x, fragments = c(), ..., level = 1L) {
  rd2markdown.description(x, fragments = fragments, ..., title = "See Also", level = level)
}

#' @exportS3Method
#' @rdname rd2markdown
rd2markdown.arguments <- function(x, fragments = c(), ..., level = 1L) {
  # ignore whitespace text tags
  x <- x[!vlapply(x, is_ws)]

  # \\arguments permits mixing text and \\item, process groups individually
  is_item_tag <- vcapply(x, attr, "Rd_tag") == "\\item"
  split_idx <- ifelse(is_item_tag, cumsum(!is_item_tag), -seq_along(x))
  split_idx <- cumsum(!duplicated(split_idx))

  # restructure groups of \\item into custom \\itemize blocks for formatting
  new_x <- mapply(function(xi, is_item_tag, ...) {
      # if not a sequence of \\item tags, retain existing tag
      if (!is_item_tag) return(block(I(map_rd2markdown(xi[1], ..., collapse = ""))))

      # process groups of \\item, converting to md block string
      block(I(map_rd2markdown(
        xi,
        fragments = fragments,
        ...,
        item_style = "`",
        collapse = "\n"
      )))
    },
    xi = split(x, split_idx),
    is_item_tag = is_item_tag[!duplicated(split_idx)],
    SIMPLIFY = FALSE
  )

  # Content of the arguments consists of other fragments, therefore we
  # overwrite fragments param so they can be included
  level <- level + 1
  paste0(strrep("#", level), " Arguments\n\n", map_rd2markdown(new_x, ..., collapse = "", level = level))
}

#' @exportS3Method
#' @rdname rd2markdown
rd2markdown.dots <- function(x, fragments = c(), ...) {
  "`...`"
}

#' @exportS3Method
#' @rdname rd2markdown
rd2markdown.TEXT <- function(x, fragments = c(), ...) {
  trim_extra_newlines(x)
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


  if (!missing(x) && !is.null(attr(x, "Rd_tag"))) {
    # if we've ended up here as part of the tree, defer to list-style dispatch
    return(rd2markdown.list(x, fragments = fragments, ...))
  } else if (!missing(x)) {
    stop("x does not have Rd_tag attribiute. If you are trying to fetch ",
         "documentation directly please use topic and package or file parameters")
  }

  # otherwise, this is serving as a user-facing interface as topic search
  if (!is.null(topic) && is.null(package) && exists(topic, envir = envir))
    package <- getNamespaceName(environment(get(topic, envir = envir)))

  rd <- get_rd(topic = topic, package = package, file = file, macros = macros)

  if (inherits(rd, "error")) {
    stop("Rd topic was not found. Please check whether topic and package or ",
         "file parameters were set correctly.")
  }

  rd2markdown(
    rd,
    ...,
    fragments = fragments
  )
}

#' @exportS3Method
#' @rdname rd2markdown
rd2markdown.emph <- function(x, fragments = c(), ...) {
  sprintf("**%s**", map_rd2markdown(x, fragments = fragments, ..., collapse = ""))
}

#' @param item_style Used for two-part `\\item` tags, `item_style` defines the
#'   fencing characters to use for the item name. Defaults to `"**"`, which will
#'   format item names using bold-face markdown syntax.
#'
#' @exportS3Method
#' @rdname rd2markdown
rd2markdown.item <- function(x, fragments = c(), ..., item_style = "**") {
  if (length(x) == 0) return("")
  itemname <- map_rd2markdown(x[[1]], fragments = fragments, ..., collapse = "")
  itemval <- map_rd2markdown(x[[2]], fragments = fragments, ..., collapse = "")
  itemval <- paste(strsplit(itemval, "\n")[[1]], collapse = "\n    ")
  sprintf("- %1$s%2$s%1$s: %3$s", item_style, itemname, itemval)
}

#' @exportS3Method
#' @rdname rd2markdown
rd2markdown.enumerate <- function(x, fragments = c(), ...) {
  is_item <- lapply(x, attr, "Rd_tag") == "\\item"
  x <- x[cumsum(is_item) > 0L & !is_item]
  is_item <- cumsum(is_item)[cumsum(is_item) > 0L & !is_item]
  items <- lapply(split(x, is_item), map_rd2markdown, collapse = "")
  items <- lapply(items, function(xi) indent_newlines(trimws(xi), 3))
  res <- escape_html_tags(paste0(seq_along(items), ". ", items, collapse = "\n"))
  block(res)
}

#' @exportS3Method
#' @rdname rd2markdown
rd2markdown.itemize <- function(x, fragments = c(), ...) {
  items <- splitRdtag(x, "\\item")
  items <- vapply(items, map_rd2markdown, character(1L), ..., collapse = "")
  items <- Filter(nchar, trimws(items))
  items <- lapply(items, function(xi) indent_newlines(trimws(xi), 3))
  res <- escape_html_tags(paste0(" * ", items, collapse = "\n"))
  block(res)
}

#' @exportS3Method
#' @rdname rd2markdown
rd2markdown.describe <- function(x, fragments = c(), ...) {
  items <- x[vlapply(x, is_tag, "\\item")]
  items <- vcapply(items, rd2markdown, ...)
  items <- vcapply(items, function(xi) indent_newlines(trimws(xi), 3))
  res <- paste0(items, collapse = "\n")
  block(res)
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
  strbody <- vapply(
    strbody,
    function(i) paste0("|", paste0(i, collapse = "|"), "|"),
    character(1L)
  )

  block(sprintf(
    "%s\n%s\n%s",
    strheader,
    strjustline,
    paste0(strbody, collapse = "\n")
  ))
}

#' @exportS3Method
#' @rdname rd2markdown
rd2markdown.tab <- function(x, fragments = c(), ...){
  structure("|", tag = "tab")
}

#' @exportS3Method
#' @rdname rd2markdown
rd2markdown.cr <- function(x, fragments = c(), ...) {
  nl(2)
}

#' @exportS3Method
#' @rdname rd2markdown
rd2markdown.href <- function(x, fragments = c(), ...) {
  text <- rd2markdown(x[[1]])
  sprintf("[%s](%s)", x[[2]], trimws(text))
}

#' @exportS3Method
#' @rdname rd2markdown
rd2markdown.url <- function(x, fragments = c(), ...) {
  sprintf("[%1$s](%1$s)", x[[1]])
}

#' @exportS3Method
#' @rdname rd2markdown
rd2markdown.eqn <- function(x, fragments = c(), ...) {
  # TODO:
  #   provide global option to choose between LaTeX $ brackets or backticks
  #   as not all markdown renderers will render LaTeX
  sprintf("`%s`", if (length(x) > 1) x[[2]] else x[[1]])
}

#' @exportS3Method
#' @rdname rd2markdown
rd2markdown.deqn <- function(x, fragments = c(), ...) {
  sprintf("`%s`", if (length(x) > 1) x[[2]] else x[[1]])
}
