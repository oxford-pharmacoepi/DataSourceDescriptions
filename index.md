# DataSourceDescriptions

DataSourceDescriptions provides utilities for creating, validating,
importing, and exporting structured descriptions of OMOP data sources. A
data source description records administrative details, data collection
characteristics, and OMOP standardisation notes in a predictable JSON-
and CSV-friendly format.

## Installation

You can install the development version of DataSourceDescriptions from
[GitHub](https://github.com/) with:

``` r

# install.packages("pak")
pak::pak("oxford-pharmacoepi/DataSourceDescriptions")
```

## Example

Create a data source description from a named list. Required fields are
checked, optional fields are filled with `NA`, and descriptions are
named by data source acronym.

``` r

library(DataSourceDescriptions)

description <- newDataSourceDescription(list(
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
))

description
#> 
#> ── 1 data source description ───────────────────────────────────────────────────
#> 
#> - EDS: Example data source
```

Descriptions can be written to JSON or CSV and imported again.

``` r

path <- tempfile("data-source-descriptions-")
dir.create(path = path)

exportDataSourceDescription(x = description, path = path, type = "json")

imported <- importDataSourceDescription(path = path)
#> 1 data source description imported.

imported
#> 
#> ── 1 data source description ───────────────────────────────────────────────────
#> 
#> - EDS: Example data source
```

The package can also import bundled descriptions:

``` r

path <- system.file("descriptions", package = "DataSourceDescriptions")
descriptions <- importDataSourceDescription(path = path)
descriptions
```
