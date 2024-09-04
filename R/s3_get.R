#' download s3 file
#' 
#' Files are downloaded to the R user data directory (i.e., `tools::R_user_dir("s3", "data")`) so they
#' can be cached across all of an R user's sessions and projects.
#' Specify an alternative download location by setting the `R_USER_DATA_DIR` environment variable
#' (see `?tools::R_user_dir`) or by using the `data_dir` argument.
#' @param s3_uri URI for an S3 object
#' @param region AWS region for bucket containing the file
#' (defaults to "us-east-2", but only required for private files)
#' @param quiet suppress messages?
#' @param force force download to overwrite existing S3 object
#' @param progress show download progress? (currently only for public objects)
#' @param public defaults to FALSE; if TRUE, ignore any environment
#'                    variables specifying AWS credentials and
#'                    attempt to download the file as publicly available
#' @param data_dir root directory for downloaded files (defaults to `tools::R_user_dir("s3", "data")`)
#' @return a character string that is the file path to the downloaded file (invisibly)
#' @importFrom prettyunits pretty_bytes
#' @importFrom prettyunits pretty_sec
#' @examples
#' \donttest{
#' Sys.setenv("R_USER_DATA_DIR" = tempdir())
#' the_file <- s3_get(s3_uri = "s3://geomarker/testing_downloads/mtcars.rds")
#' s3_get("s3://geomarker/testing_downloads/mtcars.rds") |>
#'     readRDS()
#' unlink(the_file)
#' }
#' @export
s3_get <- function(s3_uri,
                   region = "us-east-2",
                   quiet = FALSE,
                   progress = FALSE,
                   force = FALSE,
                   public = FALSE,
                   data_dir = tools::R_user_dir("s3", "data")) {

  s3_uri_parsed <- s3_parse_uri(s3_uri)

  dest_file <-
    fs::path_join(c(
      data_dir,
      s3_uri_parsed$bucket,
      s3_uri_parsed$folder,
      s3_uri_parsed$file_name
    ))

  if (!force & s3_check_for_file_local(s3_uri, quiet = quiet, data_dir = data_dir)) {
    return(invisible(dest_file))
  }

  s3_check_for_file_s3(s3_uri, region, public, data_dir = data_dir)

  fs::dir_create(fs::path_dir(dest_file))

  has_aws_env_vars <- suppressMessages(check_for_aws_env_vars())
  if (public) has_aws_env_vars <- FALSE

  url_get <- s3_uri_parsed$url

  if (has_aws_env_vars) {
    url_get <- s3_get_signed_url(s3_uri, region)
  }

  if (progress) {
    progress <- httr::progress()
  } else {
    progress <- NULL
  }

  gets <- httr::GET(
    url_get,
    httr::write_disk(dest_file, overwrite = TRUE),
    progress
  )

  return(invisible(dest_file))
}
