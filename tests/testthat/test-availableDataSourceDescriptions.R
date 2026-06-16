test_that("basic tests", {

  expect_no_error(ds <- availableDataSourceDescriptions())
  expect_true(any(stringr::str_detect(tolower(ds), "cprd")))

})
