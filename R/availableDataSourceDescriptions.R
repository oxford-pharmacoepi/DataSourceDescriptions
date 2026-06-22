#' Get available data source descriptions
#'
#' @description
#' Provides a list of all available data source descriptions stored in the
#' oxford-pharmacoepi/DataSourceDescriptionsLibrary GitHub repository.
#'
#' @return A character vector with names of available data sources.
#' @export
#'
#' @examples
#' \dontrun{
#' library(dataSourceDescriptions)
#'
#' availableDataSourceDescriptions()
#' }
availableDataSourceDescriptions <- function() {
  descriptions <- purrr::map_chr(getRepoTree()$tree, "path") |>
    stringr::str_subset("(?i)\\.json$") |>
    basename() |>
    stringr::str_remove("(?i)\\.json$")

  return(descriptions)
}

getOpt <- function(key, default) {
  keyEnv <- paste0("DATA_SOURCE_DESCRIPTION_", toupper(key))
  res <- Sys.getenv(x = keyEnv, unset = "")
  if (res == "") {
    keyOpt <- paste0("data_source_description.", key)
    res <- getOption(x = keyOpt, default = default)
  }
  return(res)
}
dsdOwner <- function() {
  getOpt(key = "owner", default = "oxford-pharmacoepi")
}
dsdRepo <- function() {
  getOpt(key = "repo", default = "DataSourceDescriptionsLibrary")
}
dsdBranch <- function() {
  getOpt(key = "branch", default = "main")
}
dsdToken <- function() {
  getOpt(key = "token", default = NULL)
}
dsdPath <- function() {
  paste(
    "https://github.com", dsdOwner(), dsdRepo(), "tree", dsdBranch(), sep = "/"
  )
}
getRepoTree <- function() {
  gh::gh(
    "GET /repos/{owner}/{repo}/git/trees/{branch}",
    owner = dsdOwner(),
    repo = dsdRepo(),
    branch = dsdBranch(),
    recursive = 1,
    .token = dsdToken()
  )
}
