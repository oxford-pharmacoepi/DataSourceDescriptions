
#' `data_source_description` object constructor
#'
#' @param x A data source description, or a named list of data source
#' descriptions.
#'
#' @return A `data_source_description` object.
#'
#' @export
#'
newDataSourceDescription <- function(x) {
  x <- constructDataSourceDescription(x)
  x <- validateDataSourceDescription(x)

  return(x)
}

constructDataSourceDescription <- function(x) {
  if (inherits(x, "data_source_description")) {
    x <- unclass(x)
  }

  if (isDataSourceDescription(x)) {
    x <- list(x)
  }

  x |>
    addClass("data_source_description")
}

isDataSourceDescription <- function(x) {
  is.list(x) &&
    any(c(
      "administrative_details", "data_collection", "omop_standardisation"
    ) %in% names(x))
}

validateDataSourceDescription <- function(x,
                                          call = parent.frame()) {
  omopgenerics::assertList(x, call = call)

  if (length(x) == 0) {
    return(structure(.Data = list(), class = "data_source_description"))
  }

  x <- x |>
    purrr::imap(\(description, nm) {
      validateSingleDataSourceDescription(description, nm, call = call)
    })

  nms <- x |>
    purrr::map_chr(\(description) {
      description$administrative_details$data_source_acronym
    })

  if (length(nms) != length(unique(nms))) {
    cli::cli_abort(c(x = "Data source acronyms must be unique."), call = call)
  }

  names(x) <- nms
  x <- x[order(names(x))]

  x |>
    addClass("data_source_description")
}

validateSingleDataSourceDescription <- function(description,
                                                nm,
                                                call = parent.frame()) {
  if (!is.list(description)) {
    cli::cli_abort(c(x = "Data source description {.pkg {nm}} is not a list."), call = call)
  }

  if (!is.character(nm) || is.na(nm) || !nzchar(nm)) {
    nm <- description$administrative_details$data_source_acronym %||% "unknown"
  }

  spec <- dataSourceDescriptionFields()
  missingSections <- setdiff(names(spec), names(description))
  extraSections <- setdiff(names(description), names(spec))

  if (length(missingSections) > 0) {
    cli::cli_abort(c(x = "Missing section in data source {.pkg {nm}}: {.var {missingSections}}."), call = call)
  }
  if (length(extraSections) > 0) {
    cli::cli_abort(c(x = "Unexpected section in data source {.pkg {nm}}: {.var {extraSections}}."), call = call)
  }

  description <- description[names(spec)]

  for (section in names(spec)) {
    description[[section]] <- validateDataSourceDescriptionSection(
      nm = nm,
      section = description[[section]],
      sectionName = section,
      required = spec[[section]]$required,
      optional = spec[[section]]$optional,
      call = call
    )
  }

  return(description)
}

validateDataSourceDescriptionSection <- function(nm,
                                                 section,
                                                 sectionName,
                                                 required,
                                                 optional,
                                                 call = parent.frame()) {
  if (!is.list(section)) {
    cli::cli_abort(c(x = "Section {.var {sectionName}} of {.pkg {nm}} must be a list."), call = call)
  }

  expectedFields <- c(required, optional)
  missingFields <- setdiff(required, names(section))
  extraFields <- setdiff(names(section), expectedFields)

  if (length(missingFields) > 0) {
    cli::cli_abort(
      "Missing field in {.var {sectionName}} of {.pkg {nm}}: {.var {missingFields}}.",
      call = call
    )
  }
  if (length(extraFields) > 0) {
    cli::cli_abort(
      "Unexpected field in {.var {sectionName}} of {.pkg {nm}}: {.var {extraFields}}.",
      call = call
    )
  }

  for (field in expectedFields) {
    fieldName <- paste0(nm, "$", sectionName, "$", field)
    value <- section[[field]]
    fieldIsOptional <- field %in% optional

    if (is.null(value)) {
      if (fieldIsOptional) {
        value <- NA_character_
      } else {
        cli::cli_abort(c(x = "{.var {fieldName}} of {.pkg {nm}} must not be NULL."), call = call)
      }
    }

    omopgenerics::assertCharacter(
      value,
      length = 1,
      na = fieldIsOptional,
      minNumCharacter = dataSourceDescriptionMinCharacters(field),
      #nm = fieldName,
      call = call
    )
    section[[field]] <- value
  }

  return(section[expectedFields])
}

dataSourceDescriptionMinCharacters <- function(field) {
  if (field %in% c("name_of_data_source", "data_source_acronym")) {
    return(1)
  }
  return(0)
}

dataSourceDescriptionFields <- function() {
  list(
    administrative_details = list(
      required = c("name_of_data_source", "data_source_acronym"),
      optional = c(
        "data_source_website", "hma_ema_catalogue", "main_references"
      )
    ),
    data_collection = list(
      required = c(
        "geography", "population", "healthcare_setting_type_of_data",
        "data_collection_process", "general_representativeness",
        "data_source_coding", "source_quality_control", "linkage",
        "mortality", "source_limitations"
      ),
      optional = character()
    ),
    omop_standardisation = list(
      required = c("omop_mapping", "omop_quality_control"),
      optional = character()
    )
  )
}

#' Print a data source description
#'
#' @param x A data source description.
#' @param ... Included for compatibility with generic. Not used.
#'
#' @return Invisibly returns the input.
#' @export
#'
#' @examples
#' description <- list(
#'   administrative_details = list(
#'     name_of_data_source = "Example data source",
#'     data_source_acronym = "EDS"
#'   ),
#'   data_collection = list(
#'     geography = "United Kingdom",
#'     population = "Adults registered in participating practices",
#'     healthcare_setting_type_of_data = "Electronic health records",
#'     data_collection_process = "Data are captured during routine care.",
#'     general_representativeness = "Representative of participating practices.",
#'     data_source_coding = "Clinical events are recorded using source codes.",
#'     source_quality_control = "Source data are checked before release.",
#'     linkage = "No external linkage is included.",
#'     mortality = "Deaths are captured from primary care records.",
#'     source_limitations = "Information recorded outside participating practices may be incomplete."
#'   ),
#'   omop_standardisation = list(
#'     omop_mapping = "Source data are mapped to the OMOP CDM.",
#'     omop_quality_control = "Mapped data are checked using OMOP quality checks."
#'   )
#' )
#' description <- newDataSourceDescription(description)
#' description
#'
print.data_source_description <- function(x, ...) {
  cli::cli_h1("{length(x)} data source description{?s}")
  cli::cat_line("")
  disp <- 6
  len <- min(length(x), disp)
  if (len > 0) {
    for (i in seq_len(len)) {
      cli::cat_line(paste0(
        "- ", names(x)[i], ": ",
        x[[i]]$administrative_details$name_of_data_source
      ))
    }
  }
  if (length(x) > disp) {
    cli::cat_line(paste0(
      "along with ", length(x) - disp,
      " more data source descriptions"
    ))
  }
  invisible(x)
}

#' @export
`[.data_source_description` <- function(x, i) {
  cl <- class(x)
  obj <- NextMethod()
  class(obj) <- cl
  return(obj)
}

#' @export
bind.data_source_description <- function(...) {
  c(...)
}

#' @export
c.data_source_description <- function(...) {
  NextMethod() |>
    newDataSourceDescription()
}

#' Create an empty `data_source_description` object
#'
#' @return An empty `data_source_description` object.
#' @export
#'
#' @examples
#' emptyDataSourceDescription()
#'
emptyDataSourceDescription <- function() {
  newDataSourceDescription(x = list())
}

addClass <- function(x, value) {
  if (any(value %in% class(x))) {
    x <- removeClass(x, value)
  }
  base::class(x) <- c(value, base::class(x))
  return(x)
}

removeClass <- function(x, value) {
  base::class(x) <- base::class(x)[!(base::class(x) %in% value)]
  return(x)
}
