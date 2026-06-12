#' Visualise bundled data source descriptions
#'
#' Creates an HTML view of one or more bundled data source descriptions. The
#' returned object is a `bslib` tabset that displays in the RStudio Viewer when
#' printed interactively.
#'
#' @param dataSourceName Character vector of data source acronyms to visualise.
#' If `NULL`, all bundled data source descriptions are shown.
#'
#' @return A `bslib` tabset.
#' @export
#'
#' @examples
#' \dontrun{
#' visualiseDataSourceDescription("CPRD GOLD")
#' }
#'
visualiseDataSourceDescription <- function(dataSourceName = NULL) {
  sources <- dataSources()
  dataSourceName <- validateDataSourceName(dataSourceName, names(sources))
  sources <- sources[dataSourceName]

  panels <- purrr::map(unname(sources), \(description) {
    bslib::nav_panel(
      title = description$administrative_details$data_source_acronym,
      dataSourceMarkdownHtml(description)
    )
  })

  do.call(bslib::navset_card_tab, args = panels)
}

validateDataSourceName <- function(dataSourceName,
                                   choices,
                                   call = parent.frame()) {
  if (is.null(dataSourceName)) {
    return(choices)
  }

  omopgenerics::assertChoice(
    x = dataSourceName,
    choices = choices,
    unique = TRUE,
    call = call
  )

  return(dataSourceName)
}

dataSources <- function() {
  path <- system.file("descriptions", package = "DataSourceDescriptions")
  importDataSourceDescription(path = path, type = "json") |>
    suppressMessages()
}

dataSourceMarkdownHtml <- function(description) {
  dataSourceMarkdown(description) |>
    commonmark::markdown_html() |>
    htmltools::HTML() |>
    shiny::tagList()
}

dataSourceMarkdown <- function(description) {
  c(
    dataSourceSectionMarkdown(
      title = "Administrative details",
      section = "administrative_details",
      fields = description$administrative_details
    ),
    dataSourceSectionMarkdown(
      title = "Data collection",
      section = "data_collection",
      fields = description$data_collection
    ),
    dataSourceSectionMarkdown(
      title = "OMOP standardisation",
      section = "omop_standardisation",
      fields = description$omop_standardisation
    )
  ) |>
    paste(collapse = "\n\n")
}

dataSourceSectionMarkdown <- function(title, section, fields) {
  fieldNames <- dataSourceDescriptionFields()[[section]]
  fieldNames <- c(fieldNames$required, fieldNames$optional)

  c(
    paste0("### ", title),
    purrr::map_chr(fieldNames, \(field) {
      dataSourceFieldMarkdown(field, fields[[field]])
    })
  ) |>
    paste(collapse = "\n\n")
}

dataSourceFieldMarkdown <- function(field, value) {
  paste0(
    "**", prettyDataSourceField(field), "**: ",
    ifelse(is.na(value), "*Not available*", linkMarkdownUrls(value))
  )
}

prettyDataSourceField <- function(field) {
  field |>
    stringr::str_replace_all("_", " ") |>
    stringr::str_to_title() |>
    stringr::str_replace_all(c(
      "\\bOf\\b" = "of",
      "\\bOmop\\b" = "OMOP",
      "\\bHma Ema\\b" = "HMA-EMA"
    ))
}

linkMarkdownUrls <- function(value) {
  value <- as.character(value)
  gsub(
    "(?<!<)(https?://[^[:space:]<>]+)(?!>)",
    "<\\1>",
    value,
    perl = TRUE
  )
}
