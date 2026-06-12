
#' Export data source descriptions
#'
#' @param x A data source description.
#' @param path Directory where files will be written.
#' @param type File type to export. Supported values are `"json"` and `"csv"`.
#'
#' @return Invisibly returns the exported file paths.
#' @export
exportDataSourceDescription <- function(x, path, type = "json") {
  omopgenerics::assertChoice(type, choices = c("json", "csv"))
  omopgenerics::assertCharacter(path, length = 1)
  if (!dir.exists(path)) {
    cli::cli_abort(c("x" = "Given path does not exist"))
  }
  x <- newDataSourceDescription(x)

  files <- writeDataSourceDescription(x, path, type)

  return(invisible(files))
}

writeDataSourceDescription <- function(x, path, type) {
  purrr::imap_chr(x, \(description, nm) {
    file <- file.path(path, paste0(omopgenerics::toSnakeCase(nm), ".", type))
    if (type == "json") {
      rlang::check_installed("jsonlite")
      jsonlite::write_json(
        description,
        path = file,
        pretty = TRUE,
        auto_unbox = TRUE,
        na = "null"
      )
    } else if (type == "csv") {
      rlang::check_installed("readr")
      readr::write_csv(
        dataSourceDescriptionToTable(description),
        file = file,
        na = ""
      )
    }
    return(file)
  })
}

dataSourceDescriptionToTable <- function(description) {
  spec <- dataSourceDescriptionFields()
  purrr::imap_dfr(spec, \(fields, sectionName) {
    fieldNames <- c(fields$required, fields$optional)
    purrr::map_dfr(fieldNames, \(fieldName) {
      dplyr::tibble(
        section = sectionName,
        field = fieldName,
        value = description[[sectionName]][[fieldName]] %||% NA_character_
      )
    })
  })
}
