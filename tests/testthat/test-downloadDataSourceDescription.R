test_that("basic functionality", {

  # ds_dir <- file.path(tempdir(), "ds1")
  # dir.create(ds_dir, showWarnings = FALSE)
  # to_dl <- availableDataSourceDescriptions()[1]
  # expect_no_error(downloadDataSourceDescription(names = to_dl,
  #                                               ds_dir))
  # expect_true(paste0(to_dl, ".json") %in% list.files(ds_dir))
  # unlink(ds_dir)
  #
  # # download all
  # ds_dir <- file.path(tempdir(), "ds2")
  # dir.create(ds_dir, showWarnings = FALSE)
  # expect_no_error(downloadDataSourceDescription(names = NULL,
  #                                               ds_dir))
  # expect_true(all(paste0(availableDataSourceDescriptions(), ".json") %in%
  #                   list.files(ds_dir)))
  # unlink(ds_dir)

})

test_that("summarised result input", {

  # empty result
  ds_dir <- file.path(tempdir(), "ds1")
  dir.create(ds_dir, showWarnings = FALSE)
  res <- omopgenerics::emptySummarisedResult()
  expect_warning(downloadDataSourceDescription(names = res,
                                                ds_dir))

  # data sources not in library
  res <- omopgenerics::newSummarisedResult(
    dplyr::tibble(
                  result_id = 1L,
                  cdm_name = "unknown",
                  group_name = "overall",
                  group_level = "overall",
                  strata_name = "overall",
                  strata_level = "overall",
                  variable_name = "overall",
                  variable_level = "overall",
                  estimate_name = "overall",
                  estimate_type = "numeric",
                  estimate_value = "overall",
                  additional_name = "overall",
                  additional_level = "overall",
                  )
  )
  expect_no_error(downloadDataSourceDescription(names = res,
                                                ds_dir))

  # data sources not in library
  res <- omopgenerics::newSummarisedResult(
    dplyr::tibble(
      result_id = 1L,
      cdm_name = c("CPRD GOLD"),
      group_name = "overall",
      group_level = "overall",
      strata_name = "overall",
      strata_level = "overall",
      variable_name = "overall",
      variable_level = "overall",
      estimate_name = "overall",
      estimate_type = "numeric",
      estimate_value = "overall",
      additional_name = "overall",
      additional_level = "overall",
    )
  )
  expect_no_error(downloadDataSourceDescription(names = res,
                                                ds_dir))



})
