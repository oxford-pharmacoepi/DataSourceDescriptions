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
#' availableDataSourceDescriptions()
#' }
availableDataSourceDescriptions <- function() {

  owner <- "oxford-pharmacoepi"
  repo <- "DataSourceDescriptionsLibrary"
  working_branch <- "main"
  working_token <- NULL

  tree_data <- gh::gh(
    "GET /repos/{owner}/{repo}/git/trees/{branch}",
    owner = owner,
    repo = repo,
    branch = working_branch,
    recursive = 1,
    .token = working_token
  )

  descriptions <- purrr::map_chr(tree_data$tree, "path") |>
    stringr::str_subset("(?i)\\.json$") |>
    basename() |>
    stringr::str_remove("(?i)\\.json$")

  return(descriptions)
}
