# Import data source descriptions

Import data source descriptions

## Usage

``` r
importDataSourceDescription(path, type = NULL, recursive = FALSE)
```

## Arguments

- path:

  A file path or directory path. When a directory is supplied, matching
  files are imported from the directory.

- type:

  File type to import. Supported values are `"json"` and `"csv"`. If
  `NULL`, both supported file types are detected from file extensions.

- recursive:

  Whether to search directories recursively.

## Value

A `data_source_description` object.
