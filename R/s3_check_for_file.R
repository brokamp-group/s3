s3_check_for_file_local <- function(s3_uri,
                                    quiet = FALSE,
                                    download_folder = getOption("s3.download_folder",
                                                                fs::path_wd("s3_downloads"))) {

  s3_uri_parsed <- s3_parse_uri(s3_uri)

  dest_file <-
    fs::path_join(c(
      download_folder,
      s3_uri_parsed$bucket,
      s3_uri_parsed$folder,
      s3_uri_parsed$file_name
    ))

  if (fs::file_exists(dest_file)) {
    if (!quiet) cli::cli_alert_info("{.file {s3_uri}} already exists at {.file {dest_file}}")
    return(TRUE)
  } else {
    return(FALSE)
  }

}

s3_check_for_file_s3 <- function(s3_uri,
                                 public = FALSE,
                                 download_folder = getOption("s3.download_folder", fs::path_wd("s3_downloads"))) {

  s3_uri_parsed <- s3_parse_uri(s3_uri)

  dest_file <-
    fs::path_join(c(
      download_folder,
      s3_uri_parsed$bucket,
      s3_uri_parsed$folder,
      s3_uri_parsed$file_name
    ))

  has_aws_env_vars <- suppressMessages(check_for_aws_env_vars())
  if (public) has_aws_env_vars <- FALSE

  if (!has_aws_env_vars) {
    s3_response <-
      httr::HEAD(s3_uri_parsed$url) %>%
      httr::status_code()
  }

  if (has_aws_env_vars) {
    s3_head <-
      boto$client("s3")$head_object(
        Bucket = s3_uri_parsed$bucket,
        Key = s3_uri_parsed$key)
    s3_response <- s3_head[['ResponseMetadata']][['HTTPStatusCode']]
  }

  if (s3_response == 200) return(invisible(TRUE))

  if (s3_response == 403) {
    stop("file not found, check the URI; do you need AWS credentials for this file?")
  }
}
