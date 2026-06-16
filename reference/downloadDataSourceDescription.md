# Download data source descriptions

Downloads specific data source descriptions from the
oxford-pharmacoepi/DataSourceDescriptionsLibrary GitHub repository and
saves them to a local directory.

## Usage

``` r
downloadDataSourceDescription(names, path)
```

## Arguments

- names:

  A character vector of data source names to download. You can use
  [`availableDataSourceDescriptions()`](https://oxford-pharmacoepi.github.io/DataSourceDescriptions/reference/availableDataSourceDescriptions.md)
  to find available descriptions. If NULL, all descriptions will be
  saved

- path:

  A character string specifying the local directory where the files
  should be saved.

## Value

Invisible `NULL`. Called for its side effect of downloading files.

## Examples

``` r
if (FALSE) { # \dontrun{
# Assuming you have a folder named "data_sources" in your project directory
downloadDataSourceDescription(
  names = c("CPRD_AURUM"),
  path = here::here("data_sources")
)
} # }
```
