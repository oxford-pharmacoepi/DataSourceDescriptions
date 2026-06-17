
#' Import data source descriptions
#'
#' @param path A file path or directory path. When a directory is supplied,
#' matching files are imported from the directory.
#' @param type File type to import. Supported values are `"json"` and `"csv"`.
#' If `NULL`, both supported file types are detected from file extensions.
#' @param recursive Whether to search directories recursively.
#'
#' @return A `data_source_description` object.
#' @export
importDataSourceDescription <- function(path, type = NULL, recursive = FALSE) {
  omopgenerics::assertChoice(type, choices = c("json", "csv"), length = 1, null = TRUE)
  files <- findFiles(
    path = path,
    type = type,
    recursive = recursive
  )

  descriptions <- files |>
    purrr::map(\(x) readDataSourceDescription(x, type)) |>
    purrr::compact() |>
    purrr::map(unclass)

  if (length(descriptions) == 0) {
    descriptions <- list()
  } else {
    descriptions <- do.call(c, descriptions)
  }

  descriptions <- newDataSourceDescription(descriptions)

  cli::cli_inform("{.strong {length(descriptions)}} data source description{?s} imported.")

  return(descriptions)
}

findFiles <- function(path, type, recursive, call = parent.frame()) {
  omopgenerics::assertCharacter(path, call = call)
  omopgenerics::assertLogical(recursive, length = 1, call = call)

  if (is.null(type)) {
    type <- c("json", "csv")
  }
  pattern <- paste0("\\.", type, "$", collapse = "|")

  path <- path |>
    purrr::map(\(x) {
      if (!file.exists(x)) {
        cli::cli_warn(c("x" = "directory {.path {x}} does not exist"))
        return(list())
      }
      if (file.info(x)$isdir) {
        x <- list.files(path = x, full.names = TRUE, pattern = pattern, recursive = recursive)
      }
      return(x)
    }) |>
    unlist() |>
    as.character()
  names(path) <- tools::file_path_sans_ext(basename(path))
  as.list(path)
}

readDataSourceDescription <- function(file, type) {

    if (is.null(type)) {
      type <- tolower(tools::file_ext(file))
    }
    if (type == "json") {
      rlang::check_installed("jsonlite")
      description <- jsonlite::read_json(file)
    } else if (type == "csv") {
      rlang::check_installed("readr")
      description <- readr::read_csv(file = file, show_col_types = FALSE) |>
        dataSourceDescriptionFromTable()
    }
    description |>
      newDataSourceDescription()

}

dataSourceDescriptionFromTable <- function(x, call = parent.frame()) {
  x <- dplyr::as_tibble(x)
  colnames(x) <- omopgenerics::toSnakeCase(colnames(x))

  omopgenerics::assertTable(
    x = x,
    columns = c("section", "field", "value"),
    class = "data.frame",
    call = call
  )

  x |>
    dplyr::mutate(dplyr::across(
      dplyr::all_of(c("section", "field", "value")),
      as.character
    )) |>
    dplyr::filter(!is.na(.data$section), !is.na(.data$field)) |>
    dplyr::group_by(.data$section) |>
    dplyr::group_split() |>
    purrr::map(\(section) {
      values <- section$value
      names(values) <- section$field
      as.list(values)
    }) |>
    rlang::set_names(
      x |>
        dplyr::filter(!is.na(.data$section), !is.na(.data$field)) |>
        dplyr::pull(.data$section) |>
        unique()
    )
}
