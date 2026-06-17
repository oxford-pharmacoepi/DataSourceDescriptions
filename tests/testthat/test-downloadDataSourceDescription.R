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

test_that("acronym must match filename", {

  ds_dir <- file.path(tempdir(), "ds")
  dir.create(ds_dir, showWarnings = FALSE)

 working_dsd <- list(
    administrative_details = list(
      name_of_data_source = "Example data source",
      data_source_acronym = "example_ds"
    ),
    data_collection = list(
      geography = "United Kingdom",
      population = "Adults registered in participating practices",
      healthcare_setting_type_of_data = "Electronic health records",
      data_collection_process = "Data are captured during routine care.",
      general_representativeness = "Representative of participating practices.",
      data_source_coding = "Clinical events are recorded using source codes.",
      source_quality_control = "Source data are checked before release.",
      linkage = "No external linkage is included.",
      mortality = "Deaths are captured from primary care records.",
      source_limitations = "Information recorded outside participating practices may be incomplete."
    ),
    omop_standardisation = list(
      omop_mapping = "Source data are mapped to the OMOP CDM.",
      omop_quality_control = "Mapped data are checked using OMOP quality checks."
    )
  )

  exportDataSourceDescription(working_dsd, ds_dir)
  file.rename(from = list.files(ds_dir, full.names = TRUE),
              to = stringr::str_replace_all(list.files(ds_dir, full.names = TRUE), "example", "abc"))
  expect_error(importDataSourceDescription(ds_dir))

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
