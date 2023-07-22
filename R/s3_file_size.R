s3_file_size <- function(s3_uri, region = "us-east-2", public = FALSE) {

  s3_uri_parsed <- s3_parse_uri(s3_uri)

  has_aws_env_vars <- suppressMessages(check_for_aws_env_vars())
  if (public) has_aws_env_vars <- FALSE

  url_get <- s3_uri_parsed$url

  if (has_aws_env_vars) {
    url_get <- s3_get_signed_url(s3_uri, region = region, verb = "HEAD")
  }

  s3_response <- httr::HEAD(url_get)
  file_size <- httr::headers(s3_response)[["Content-Length"]] |>
    as.numeric()

    return(invisible(file_size))
}
