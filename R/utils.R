vlapply <- function(..., FUN.VALUE = logical(1L)) {
  vapply(..., FUN.VALUE = FUN.VALUE)
}

vcapply <- function(..., FUN.VALUE = character(1L)) {
  vapply(..., FUN.VALUE = FUN.VALUE)
}

triml <- function(x, ..., which = "left") {
  trimws(x, ...)
}
