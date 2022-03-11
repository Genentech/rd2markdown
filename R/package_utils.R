#' Loading unexported helpers from tools
#'
#' @import tools
#' @keywords internal
#' 
.tools <- as.list(getNamespace("tools"), all.names = TRUE)[c(
  "compareDependsPkgVersion",
  "processRdSexprs",
  "initialRdMacros",
  ".Rd_get_metadata"
)]

#' Loading unexported helpers from utils
#'
#' @import utils
#' @keywords internal
#' 
.utils <- as.list(getNamespace("utils"), all.names = TRUE)[c(
  ".make_dependency_list",
  ".getHelpFile",
  "isBasePkg"
)]
