test_that("import data source description json", {
  skip_if_not_installed("jsonlite")

  description_path <- tempDescriptionPath()
  description <- newDataSourceDescription(sampleDataSourceDescription())

  expect_no_error(exportDataSourceDescription(
    x = description,
    path = description_path
  ))
  expect_true(stringr::str_detect(list.files(description_path), names(description)))

  imported <- importDataSourceDescription(path = description_path)
  expect_identical(description, imported)

  unlink(description_path, recursive = TRUE)
})

test_that("import data source description detects supported file types", {
  skip_if_not_installed("jsonlite")
  skip_if_not_installed("readr")

  description_path <- tempDescriptionPath()
  description <- newDataSourceDescription(list(
    sampleDataSourceDescription("EDS"),
    sampleDataSourceDescription("ADS")
  ))

  exportDataSourceDescription(
    x = description["EDS"],
    path = description_path
  )
  exportDataSourceDescription(
    x = description["ADS"],
    path = description_path,
    type = "csv"
  )
  expect_true(all(stringr::str_detect(list.files(description_path), names(description))))

  imported <- importDataSourceDescription(path = description_path)
  expect_identical(description, imported)

  imported <- importDataSourceDescription(
    path = file.path(description_path, "ADS.csv")
  )
  expect_identical(description["ADS"], imported)

  unlink(description_path, recursive = TRUE)
})

test_that("import data source description csv", {
  skip_if_not_installed("readr")

  description_path <- tempDescriptionPath()
  description <- newDataSourceDescription(sampleDataSourceDescription())

  expect_no_error(exportDataSourceDescription(
    x = description,
    path = description_path,
    type = "csv"
  ))
  expect_true(stringr::str_detect(list.files(description_path), names(description)))

  imported <- importDataSourceDescription(
    path = file.path(description_path, "EDS.csv"),
    type = "csv"
  )
  expect_identical(description, imported)

  imported <- importDataSourceDescription(
    path = description_path,
    type = "csv"
  )
  expect_identical(description, imported)

  unlink(description_path, recursive = TRUE)
})

test_that("import data source description skips invalid json", {
  skip_if_not_installed("jsonlite")

  description_path <- tempDescriptionPath()
  description <- newDataSourceDescription(sampleDataSourceDescription())
  exportDataSourceDescription(x = description, path = description_path)
  jsonlite::write_json(list(not_a_description = TRUE), file.path(
    description_path, "not_a_description.json"
  ))

  expect_error(imported <- importDataSourceDescription(path = description_path))

  unlink(description_path, recursive = TRUE)
})

test_that("import data source description error invalid csv", {
  skip_if_not_installed("readr")

  description_path <- tempDescriptionPath()
  invalid <- dplyr::tibble(not_section = "administrative_details")
  readr::write_csv(
    invalid,
    file = file.path(description_path, "not_a_description.csv")
  )

  expect_error(imported <- importDataSourceDescription(
    path = description_path,
    type = "csv"
  ))

  unlink(description_path, recursive = TRUE)
})

test_that("import data source description handles directories with no supported files", {
  skip_if_not_installed("jsonlite")

  description_path <- tempDescriptionPath()

  expect_no_error(imported <- importDataSourceDescription(path = description_path))
  expect_identical(imported, emptyDataSourceDescription())

  unlink(description_path, recursive = TRUE)
})

test_that("import data source description handles directories with no csv", {
  skip_if_not_installed("readr")

  description_path <- tempDescriptionPath()

  expect_no_error(imported <- importDataSourceDescription(
    path = description_path,
    type = "csv"
  ))
  expect_identical(imported, emptyDataSourceDescription())

  unlink(description_path, recursive = TRUE)
})

test_that("bundled data source descriptions can be imported", {
  skip_if_not_installed("jsonlite")

  description_path <- system.file("descriptions", package = "DataSourceDescriptions")

  expect_no_error(descriptions <- importDataSourceDescription(description_path))
  expect_true(inherits(descriptions, "data_source_description"))
  expect_true("cprd_gold" %in% names(descriptions))
})
