s3_parse_uri <- function(s3_uri) {

    if (!grepl("^(s3://)", s3_uri)) {
        stop(s3_uri, " does not begin with s3://", call. = FALSE)
    }

    file_name <- fs::path_file(s3_uri)
    file_path_parts <- fs::path_split(s3_uri)[[1]]
    bucket <- file_path_parts[2]
    folder <-
      file_path_parts[3:(length(file_path_parts) - 1)] |>
      fs::path_join() |>
        as.character()

  # check for files in root of bucket
  if (length(file_path_parts) == 3) {
    folder <- ""
    key <- file_name
  }
  else {
    key <-
      fs::path_join(c(folder, file_name)) |>
      as.character()
  }

    s3_url <- glue::glue("https://{bucket}.s3.amazonaws.com/{key}")

    return(
        list(
            uri = s3_uri,
            bucket = bucket,
            key = key,
            folder = folder,
            file_name = file_name,
            url = as.character(s3_url)
        )
    )
}
