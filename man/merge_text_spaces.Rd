% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/map_rd2markdown.R
\name{merge_text_spaces}
\alias{merge_text_spaces}
\title{Merge whitespace between text elements}
\usage{
merge_text_spaces(x)
}
\arguments{
\item{x}{\code{list} of Rd tags}
}
\description{
Within a series of text segments, there should be no separate text elements,
which are spaces only. These should be merged together and to the next
non-space element if possible.
}
\examples{
\dontrun{
x <- list(" a ", "`b`", " ", "  ", " c ", block(), "\n", "e   \n", "f")
merge_text_spaces(x)
# list(" a ", "`b`   ", " c ", block(), "\n", "e   \n", "f")

x <- list(block(), " a ", "`b`", " c ", " ", block(), "   ",  " d ", "e ", "f", block())
merge_text_spaces(x)
# list(block(), "a ", "`b`", " c  ", block(), "    d ", "e ", "f", block())
}

}
\keyword{internal}
