# Print a data source description

Print a data source description

## Usage

``` r
# S3 method for class 'data_source_description'
print(x, ...)
```

## Arguments

- x:

  A data source description.

- ...:

  Included for compatibility with generic. Not used.

## Value

Invisibly returns the input.

## Examples

``` r
description <- list(
  administrative_details = list(
    name_of_data_source = "Example data source",
    data_source_acronym = "EDS"
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
description <- newDataSourceDescription(description)
description
#> 
#> ── 1 data source description ───────────────────────────────────────────────────
#> 
#> - EDS: Example data source
```
