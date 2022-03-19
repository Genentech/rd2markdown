
``` r
markdown_output <- function(x, ...) {
  res <- paste("> ", strsplit(x, "\n")[[1L]], collapse = "\n")
  knitr::asis_output(res)
}
```

``` r
dummy_print = function(x, ...) {
  cat("I do not know what to print!")
  # this function implicitly returns an invisible NULL
}
```

# rd2markdown

[![CRAN_Status_Badge](http://www.r-pkg.org/badges/version/rd2markdown)](https://cran.r-project.org/package=rd2markdown)
[![R build
status](https://github.com/Genentech/rd2markdown/workflows/R-CMD-check/badge.svg)](https://github.com/Genentech/rd2markdown/actions?query=workflow%3AR-CMD-check)
[![Codecov test
coverage](https://codecov.io/gh/Genentech/rd2markdown/branch/main/graph/badge.svg)](https://app.codecov.io/gh/Genentech/rd2markdown?branch=main)
[![Total
Downloads](http://cranlogs.r-pkg.org/badges/grand-total/rd2markdown?color=orange)](http://cranlogs.r-pkg.org/badges/grand-total/rd2markdown)

# Overview

The `rd2markdown` package provides a way to conveniently convert .Rd
package documentation files into markdown files. Documentation can be
acquired in various ways, for instance using the documentation page of
an already installed package, or by fetching it directly from the source
file. The package aims to help other developers in presenting their
work, by converting documentation of their packages to markdown files
that later can be funneled into a report, README, and any others.
Therefore there are countless different scenarios where this tool might
be useful. We plan to drive the development of `rd2markdown` in a way it
will address the needs of the R community.

The core logic behind the whole conversion is treating each rd tag as a
separate class. We take the documentation object and parse it layer by
layer like an onion. Thanks to that, each tag receives a dedicated
treatment so it can be presented basically according to the demand. On
top of that, it makes the package way more extensible, as adding the
support of a new tag is essentially just implementing another method.

# Installation

Install the development version from GitHub:

``` r
remotes::install_github("Genentech/rd2markdown")
```

or latest CRAN version

``` r
install.packages("rd2markdown")
```

# Examples

Below are some basic examples that show the core functionalities of the
`rd2markdown`, its strong sides and possibilities it provides for the R
community.

## Rendering from file path

``` r
rd_example <- system.file("examples", "rd_file_sample.Rd", package = "rd2markdown")
rd <- rd2markdown::get_rd(file = rd_example)
rd2markdown::rd2markdown(rd, fragments = c("title", "description", "details"))
```

> # Rd sampler title
>
> Rd sampler description with , `Rd sampler in-line code`. And Rd
> dynamic content, **italics text**, **emphasis text**.
>
> ## Details
>
> Rd sampler details Rd sampler enumerated list
>
> 1.  One
>
> 2.  Two
>
> 3.  Three
>
> Rd sampler itemized list
>
> -   One
>
> -   Two
>
> -   Three
>
> |     |         |       |
> |:----|:--------|:------|
> | Rd  | Sampler | Table |
> | rd  | sampler | table |

## Rendering from help alias

``` r
rd2markdown::rd2markdown(
  topic = "rnorm",
  package = "stats",
  fragments = c("title", "description", "usage")
)
```

> # The Normal Distribution
>
> Density, distribution function, quantile function and random
> generation for the normal distribution with mean equal to `'mean'` and
> standard deviation equal to `'sd'`.
>
> ``` r
> dnorm(x, mean = 0, sd = 1, log = FALSE)
> pnorm(q, mean = 0, sd = 1, lower.tail = TRUE, log.p = FALSE)
> qnorm(p, mean = 0, sd = 1, lower.tail = TRUE, log.p = FALSE)
> rnorm(n, mean = 0, sd = 1)
> ```

To see the examples showing the complexity of the package, please take a
look at the vignette attached in this package
`The rd2markdown package intro`. You will find there not only examples
for all exported functions with various combinations of parameters, but
also the rationale for this package, why it was created, and what logic
it follows.

# Plans for the future development

Below is the list of our plans for the nearest future\`;

1.  Implement a mechanism that discoverers custom functions that are not
    stored as tags like `\pkgfun{}`.
2.  Publish to CRAN
3.  Bug fixes
