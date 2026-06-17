test_that("export data source description json", {
  skip_if_not_installed("jsonlite")

  description_path <- tempDescriptionPath()
  description <- newDataSourceDescription(list(
    sampleDataSourceDescription("EDS"),
    sampleDataSourceDescription("ADS")
  ))

  expect_no_error(exportDataSourceDescription(
    x = description,
    path = description_path
  ))
  expect_true("ADS.json" %in% list.files(description_path))
  expect_true("EDS.json" %in% list.files(description_path))
  exported <- jsonlite::read_json(file.path(description_path, "EDS.json"))
  expect_true("data_source_website" %in% names(exported$administrative_details))
  expect_null(exported$administrative_details$data_source_website)

  description$EDS$administrative_details$data_source_website <- "https://example.com"
  exportDataSourceDescription(x = description["EDS"], path = description_path)
  exported <- jsonlite::read_json(file.path(description_path, "EDS.json"))
  expect_identical(
    exported$administrative_details$data_source_website,
    "https://example.com"
  )

  expect_error(exportDataSourceDescription(
    x = "not a description",
    path = description_path
  ))
  expect_error(exportDataSourceDescription(
    x = description,
    path = "not a path"
  ))

  unlink(description_path, recursive = TRUE)
})

test_that("export data source description csv", {
  skip_if_not_installed("readr")

  description_path <- tempDescriptionPath()
  description <- newDataSourceDescription(list(
    sampleDataSourceDescription("EDS"),
    sampleDataSourceDescription("ADS")
  ))

  expect_no_error(exportDataSourceDescription(
    x = description,
    path = description_path,
    type = "csv"
  ))
  expect_true("ADS.csv" %in% list.files(description_path))
  expect_true("EDS.csv" %in% list.files(description_path))

  exported <- readr::read_csv(
    file.path(description_path, "EDS.csv"),
    show_col_types = FALSE
  )
  expect_true(all(c("section", "field", "value") %in% colnames(exported)))
  expect_true("data_source_website" %in% exported$field)

  expect_error(exportDataSourceDescription(
    x = description,
    path = description_path,
    type = "not a type"
  ))

  unlink(description_path, recursive = TRUE)
})
