
<!-- README.md is generated from README.Rmd. Please edit that file -->

# DataSourceDescriptions

<!-- badges: start -->

[![R-CMD-check](https://github.com/oxford-pharmacoepi/DataSourceDescriptions/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/oxford-pharmacoepi/DataSourceDescriptions/actions/workflows/R-CMD-check.yaml)
[![CRAN
status](https://www.r-pkg.org/badges/version/DataSourceDescriptions)](https://CRAN.R-project.org/package=DataSourceDescriptions)
[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
<!-- badges: end -->

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

### Create data source description

Create a data source description from a named list. Required fields are
checked, optional fields are filled with `NA`, and descriptions are
named by data source acronym.

``` r
library(DataSourceDescriptions)

description <- newDataSourceDescription(list(source1 = list(
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
)))

description
#> 
#> ── 1 data source description ───────────────────────────────────────────────────
#> 
#> - EDS: Example data source
```

### Export and Import data source descriptions

Descriptions can be written to JSON or CSV and imported again.

``` r
path <- tempfile("data-source-descriptions-")
dir.create(path = path)

exportDataSourceDescription(x = description, path = path, type = "json")

list.files(path = path)
#> [1] "EDS.json"

imported <- importDataSourceDescription(path = path)
#> 1 data source description imported.

imported
#> 
#> ── 1 data source description ───────────────────────────────────────────────────
#> 
#> - EDS: Example data source
```

### Download a data source descriptions

The package also allows you to download descriptions from a github
repository By default the following repository is used:
<https://github.com/oxford-pharmacoepi/DataSourceDescriptionsLibrary>.

For example you can download “CPRD GOLD” description as:

``` r
path <- file.path(tempdir(), "test")
dir.create(path = path)
downloadDataSourceDescription(dataSourceName = "CPRD GOLD", path = path)
#> ✔ Downloaded and validated description for "CPRD GOLD" saved in '/var/folders/pl/k11lm9710hlgl02nvzx4z9wr0000gp/T//RtmpRKKnHQ/test/CPRD GOLD.json'
descriptions <- importDataSourceDescription(path = path)
#> 1 data source description imported.
descriptions
#> 
#> ── 1 data source description ───────────────────────────────────────────────────
#> 
#> - CPRD GOLD: Clinical Practice Research Datalink GOLD
```

#### Customise repository to download

You can customise the source to download data sources using either
environmental variables:

    DATA_SOURCE_DESCRIPTION_OWNER="oxford-pharmacoepi"
    DATA_SOURCE_DESCRIPTION_REPO="DataSourceDescriptionsLibrary"
    DATA_SOURCE_DESCRIPTION_BRANCH="main"
    DATA_SOURCE_DESCRIPTION_TOKEN="..."

or using options:

``` r
options(data_source_description.owner = "oxford-pharmacoepi")
options(data_source_description.repo = "DataSourceDescriptionsLibrary")
options(data_source_description.branch = "main")
options(data_source_description.token = "...")
```
