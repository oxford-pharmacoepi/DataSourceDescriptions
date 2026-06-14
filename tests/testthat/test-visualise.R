test_that("data source descriptions can be visualised", {
  view <- visualiseDataSourceDescription("CPRD GOLD")

  expect_true(inherits(view, "bslib_fragment"))

  html <- htmltools::renderTags(view)$html
  expect_match(html, "data-value=\"CPRD GOLD\"", fixed = TRUE)
  expect_match(html, "Clinical Practice Research Datalink GOLD", fixed = TRUE)
  expect_match(html, "Administrative details", fixed = TRUE)
  expect_match(html, "Data collection", fixed = TRUE)
  expect_match(html, "OMOP standardisation", fixed = TRUE)
  expect_match(html, "<a href=\"https://www.cprd.com", fixed = TRUE)
  expect_false(grepl("&lt;h3", html, fixed = TRUE))

  # error if not existing
  expect_error(visualiseDataSourceDescription("unknown"))

  # with missing fields
  description <- newDataSourceDescription(sampleDataSourceDescription())
  expect_no_error(dataSourceSectionMarkdown(
    title = "Administrative details",
    section = "administrative_details",
    fields = description$EDS$administrative_details
  ))
  expect_identical(
    description$EDS$administrative_details$data_source_website,
    NA_character_
  )
  missingOptional <- dataSourceSectionMarkdown(
    title = "Administrative details",
    section = "administrative_details",
    fields = description$EDS$administrative_details
  )
  expect_match(
    missingOptional,
    "*Not available*",
    fixed = TRUE
  )

  # cprd gold fields
  description <- dataSources()[["CPRD GOLD"]]
  markdown <- dataSourceMarkdown(description)
  expect_match(markdown, "### Administrative details", fixed = TRUE)
  expect_match(markdown, "### Data collection", fixed = TRUE)
  expect_match(markdown, "### OMOP standardisation", fixed = TRUE)
  expect_match(markdown, "**Name of Data Source**:", fixed = TRUE)
  expect_match(
    markdown,
    "<https://www.cprd.com/data/primary-care-data/cprd-gold>",
    fixed = TRUE
  )
})
