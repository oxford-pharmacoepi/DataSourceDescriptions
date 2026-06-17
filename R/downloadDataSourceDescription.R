#' Download data source descriptions
#'
#' @description
#' Downloads specific data source descriptions from the
#' oxford-pharmacoepi/DataSourceDescriptionsLibrary GitHub repository and saves
#' them to a local directory.
#'
#' @param names A character vector of data source names to download. You can use
#' `availableDataSourceDescriptions()` to find available descriptions. If
#' NULL, all descriptions will be saved
#' @param path A character string specifying the local directory where the
#'   files should be saved.
#'
#' @return Invisible `NULL`. Called for its side effect of downloading files.
#' @export
#'
#' @examples
#' \dontrun{
#' # Assuming you have a folder named "data_sources" in your project directory
#' downloadDataSourceDescription(
#'   names = c("CPRD_AURUM"),
#'   path = here::here("data_sources")
#' )
#' }
downloadDataSourceDescription <- function(names, path) {

  if (!dir.exists(path)) {
    cli::cli_abort("The directory {.path {path}} does not exist. Please create it.")
  }

  if(is.null(names)){
    names <- availableDataSourceDescriptions()
  }
  if(inherits(names, "summarised_result")){
    if(nrow(names) == 0){
      cli::cli_warn("Empty result, no data source descriptions to return")
      return(invisible(NA_character_))
    } else {
    names <- names |>
      dplyr::select("cdm_name") |>
      dplyr::distinct() |>
      dplyr::pull()
    cli::cli_inform("Results from the following data sources: {names}")
    }
  }
  omopgenerics::assertCharacter(names)

  owner <- "oxford-pharmacoepi"
  repo <- "DataSourceDescriptionsLibrary"
  working_branch <- "main"
  working_token <- NULL

  repo_info <- gh::gh("GET /repos/{owner}/{repo}",
                      owner = owner,
                      repo = repo,
                      .token = working_token)

  tree_data <- gh::gh(
    "GET /repos/{owner}/{repo}/git/trees/{branch}",
    owner = owner,
    repo = repo,
    branch = working_branch,
    recursive = 1,
    .token = working_token
  )

  all_paths <- purrr::map_chr(tree_data$tree, "path")
  json_paths <- stringr::str_subset(all_paths, "(?i)\\.json$")
  clean_names <- basename(json_paths) |> stringr::str_remove("(?i)\\.json$")

  purrr::walk(names, function(name) {
    match_idx <- which(clean_names == name)

    if (length(match_idx) == 0) {
      cli::cli_alert_warning("Data source {.val {name}} not found in the library.")
      return()
    }

    repo_path <- json_paths[match_idx[1]]
    dest_path <- file.path(path, paste0(name, ".json"))

      gh::gh(
        "GET /repos/{owner}/{repo}/contents/{path}",
        owner = owner,
        repo = repo,
        path = repo_path,
        .token = working_token,
        .destfile = dest_path,
        .send_headers = c(Accept = "application/vnd.github.v3.raw")
      )

      tryCatch(
        expr = {
          importDataSourceDescription(dest_path)
        },
        error = function(e) {
          cli::cli_alert_danger("Error caught: {conditionMessage(e)}")

          # Check if the file exists, and delete it if it does
          if (file.exists(dest_path)) {
            file.remove(dest_path)
            cli::cli_alert_info("Cleaned up file: {dest_path}")
          }
          return(NULL)
        }
      )

      cli::cli_alert_success("Downloaded and validated description for {.val {name}} saved as {.path {dest_path}}")

  })

  invisible(names)
}
