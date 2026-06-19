#' Download data source descriptions
#'
#' @description
#' Downloads specific data source descriptions from the
#' oxford-pharmacoepi/DataSourceDescriptionsLibrary GitHub repository and saves
#' them to a local directory.
#'
#' @param dataSourceName A character vector of data source names to download.
#' You can use `availableDataSourceDescriptions()` to find available
#' descriptions. If `NULL`, all descriptions will be saved.
#' @param path A character string specifying the local directory where the
#' files should be saved.
#'
#' @return Invisible dataSourceName. The `json` files will be downloaded in path.
#' @export
#'
#' @examples
#' \dontrun{
#' library(dataSourceDescriptions)
#'
#' # Assuming you have a folder named "data_sources" in your project directory
#' downloadDataSourceDescription(
#'   dataSourceName = c("CPRD_AURUM"),
#'   path = here::here("data_sources")
#' )
#' }
downloadDataSourceDescription <- function(dataSourceName, path = getwd()) {
  opts <- availableDataSourceDescriptions()
  if (is.null(dataSourceName)) {
    dataSourceName <- opts
  } else {
    if (inherits(dataSourceName, "summarised_result")) {
      dataSourceName <- unique(dataSourceName$cdm_name)
      notPresent <- dataSourceName[!dataSourceName %in% opts]
      if (length(notPresent) > 0) {
        dataSourceName <- dataSourceName[dataSourceName %in% opts]
        cli::cli_inform(c(x = "The following {.pkg dataSources}: {.var {notPresent}} were not found in {.url {dsdPath()}}"))
      }
    }
    omopgenerics::assertChoice(dataSourceName, opts)
  }
  omopgenerics::assertCharacter(path, length = 1)
  if (!dir.exists(path)) {
    cli::cli_abort(c(x = "The directory {.path {path}} does not exist. Please create it."))
  }
  dataSourceName <- unique(dataSourceName)

  if (length(dataSourceName) == 0) {
    cli::cli_inform(c("!" = "No data source to download."))
    return(dataSourceName)
  }

  filePaths <- purrr::map_chr(getRepoTree()$tree, "path") |>
    stringr::str_subset("(?i)\\.json$")
  clean_names <- basename(filePaths) |>
    stringr::str_remove("(?i)\\.json$")

  purrr::walk(dataSourceName, function(name) {
    match_idx <- which(clean_names == name)

    repo_path <- filePaths[match_idx[1]]
    dest_path <- file.path(path, paste0(name, ".json"))

    gh::gh(
      "GET /repos/{owner}/{repo}/contents/{path}",
      owner = dsdOwner(),
      repo = dsdRepo(),
      branch = dsdBranch(),
      path = repo_path,
      .token = dsdToken(),
      .destfile = dest_path,
      .send_headers = c(Accept = "application/vnd.github.v3.raw")
    )

    out <- tryCatch(
      expr = {
        importDataSourceDescription(dest_path) |>
          suppressMessages()
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

    if (inherits(out, "data_source_description") & name %in% names(out)) {
      cli::cli_alert_success("Downloaded and validated description for {.val {name}} saved in {.path {dest_path}}")
    }

  })

  invisible(dataSourceName)
}
