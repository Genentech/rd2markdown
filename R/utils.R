vlapply <- function(..., FUN.VALUE = logical(1L)) {
  vapply(..., FUN.VALUE = FUN.VALUE)
}

vcapply <- function(..., FUN.VALUE = character(1L)) {
  vapply(..., FUN.VALUE = FUN.VALUE)
}

triml <- function(x, ..., which = "left") {
  trimws(x, ...)
}

find_package_root <- function(file, depth = 3) {
  if (depth == 0) {
    ""
  } else if (!file.exists(file.path(dirname(file), "DESCRIPTION"))) {
    find_package_root(dirname(file), depth - 1)
  } else {
    dirname(file)
  }
}
