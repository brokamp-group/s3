s3_check_for_file_local <- function(s3_uri, quiet = FALSE, data_dir = tools::R_user_dir("s3", "data")) {

  s3_uri_parsed <- s3_parse_uri(s3_uri)

  dest_file <-
    fs::path_join(c(
      data_dir,
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

s3_check_for_file_s3 <- function(s3_uri, region = "us-east-2", public = FALSE, data_dir = tools::R_user_dir("s3", "data")) {

  s3_uri_parsed <- s3_parse_uri(s3_uri)

  dest_file <-
    fs::path_join(c(
      data_dir,
      s3_uri_parsed$bucket,
      s3_uri_parsed$folder,
      s3_uri_parsed$file_name
    ))

  has_aws_env_vars <- suppressMessages(check_for_aws_env_vars())
  if (public) has_aws_env_vars <- FALSE

  url_get <- s3_uri_parsed$url

  if (has_aws_env_vars) {
    url_get <- s3_get_signed_url(s3_uri, region = region, verb = "HEAD")
  }

  s3_response <-
    httr::HEAD(url_get) |>
    httr::status_code()

  if (s3_response == 200) return(invisible(TRUE))

  if (s3_response %in% c(403, 404)) {
    stop("file not found, check the URI; do you need AWS credentials for this file?")
  }
}
