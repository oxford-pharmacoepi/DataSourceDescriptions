test_that("data source description constructor works", {
  expect_no_error(description <- newDataSourceDescription(
    sampleDataSourceDescription()
  ))
  expect_true(inherits(description, "data_source_description"))
  expect_identical(names(description), "EDS")
  expect_identical(
    description$EDS$administrative_details$data_source_website,
    NA_character_
  )
  expect_no_error(print(description))

  descriptions <- list(
    sampleDataSourceDescription("ZDS"),
    sampleDataSourceDescription("ADS")
  )
  expect_no_error(descriptions <- newDataSourceDescription(descriptions))
  expect_identical(names(descriptions), c("ADS", "ZDS"))
  expect_true(inherits(descriptions["ADS"], "data_source_description"))

  expect_no_error(empty <- emptyDataSourceDescription())
  expect_true(inherits(empty, "data_source_description"))
  expect_identical(length(empty), 0L)
})

test_that("data source description constructor validates required structure", {
  description <- sampleDataSourceDescription()
  description$administrative_details$name_of_data_source <- NULL
  expect_error(newDataSourceDescription(description))

  description <- sampleDataSourceDescription()
  description$data_collection$geography <- NULL
  expect_error(newDataSourceDescription(description))

  description <- sampleDataSourceDescription()
  description$data_collection$unexpected <- "not allowed"
  expect_error(newDataSourceDescription(description))

  description <- sampleDataSourceDescription()
  description$unexpected <- list()
  expect_error(newDataSourceDescription(description))

  descriptions <- list(
    sampleDataSourceDescription("EDS"),
    sampleDataSourceDescription("EDS")
  )
  expect_error(newDataSourceDescription(descriptions))

  expect_error(newDataSourceDescription(list(EDS = "not a list")))
  expect_error(newDataSourceDescription(list("not a list")))

  description <- sampleDataSourceDescription()
  description$data_collection <- "not a list"
  expect_error(newDataSourceDescription(description))

  description <- sampleDataSourceDescription()
  description$data_collection <- c(
    list(geography = NULL),
    description$data_collection[setdiff(names(description$data_collection), "geography")]
  )
  expect_error(newDataSourceDescription(description))
})

test_that("data source descriptions can be combined", {
  description1 <- newDataSourceDescription(sampleDataSourceDescription("EDS"))
  description2 <- newDataSourceDescription(sampleDataSourceDescription("ADS"))

  expect_no_error(descriptions <- c(description1, description2))
  expect_identical(names(descriptions), c("ADS", "EDS"))
  expect_identical(bind(description1, description2), descriptions)
  expect_identical(c(description1, emptyDataSourceDescription()), description1)
})

test_that("print data source description truncates long lists", {
  descriptions <- purrr::map(paste0("DS", 1:7), sampleDataSourceDescription) |>
    newDataSourceDescription()

  expect_output(print(descriptions), "along with 1 more data source descriptions")
})
