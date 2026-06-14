# Avoid repeated testthat warnings when the outer test process sets LC_ALL.
Sys.unsetenv("LC_ALL")

sampleDataSourceDescription <- function(acronym = "EDS") {
  list(
    administrative_details = list(
      name_of_data_source = paste("Example data source", acronym),
      data_source_acronym = acronym
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
}

tempDescriptionPath <- function() {
  path <- tempfile("data-source-description-")
  dir.create(path)
  path
}
