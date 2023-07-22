#' download s3 file
#'
#' s3_get will reuse, rather than redownload, an S3 object if it already exists within the `download_folder`.
#' @param s3_uri URI for an S3 object
#' @param region AWS region for bucket containing the file (defaults to "us-east-2", but only required for private files)
#' @param download_folder location to download S3 object
#' @param quiet suppress messages?
#' @param force force download to overwrite existing S3 object
#' @param progress show download progress? (currently only for public objects)
#' @param public defaults to FALSE; if TRUE, ignore any environment
#'                    variables specifying AWS credentials and
#'                    attempt to download the file as publicly available
#' @return a character string that is the file path to the downloaded file (invisibly)
#' @importFrom prettyunits pretty_bytes
#' @importFrom prettyunits pretty_sec
#' @examples
#' \donttest{
#' s3_get(s3_uri = "s3://geomarker/testing_downloads/mtcars.rds", download_folder = tempdir())
#' s3_get("s3://geomarker/testing_downloads/mtcars.rds") |>
#'     readRDS()
#' }
#' @export
s3_get <- function(s3_uri,
                   region = "us-east-2",
                   download_folder = getOption("s3.download_folder", fs::path_wd("s3_downloads")),
                   quiet = FALSE,
                   progress = FALSE,
                   force = FALSE,
                   public = FALSE) {

  s3_uri_parsed <- s3_parse_uri(s3_uri)

  dest_file <-
    fs::path_join(c(
      download_folder,
      s3_uri_parsed$bucket,
      s3_uri_parsed$folder,
      s3_uri_parsed$file_name
    ))

  if (!force & s3_check_for_file_local(s3_uri, download_folder, quiet = quiet)) {
    return(invisible(dest_file))
  }

  s3_check_for_file_s3(s3_uri, region, public, download_folder)

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
