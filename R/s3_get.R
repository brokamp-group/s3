#' download s3 file
#'
#' @export
#' @param s3_uri URI for an S3 object
#' @param download_folder location to download S3 object
#' @param quiet suppress messages?
#' @param force force download to overwrite existing S3 object
#' @param progress show download progress? (currently only for public objects)
#' @param public defaults to FALSE; if TRUE, ignore any environment
#'                    variables specifying AWS credentials and
#'                    attempt to download the file as publicly available
#' @return file path to downloaded file (invisibly)
#' @importFrom prettyunits pretty_bytes
#' @importFrom prettyunits pretty_sec
#' @examples
#' \dontrun{
#' s3_get(s3_uri = "s3://geomarker/testing_downloads/mtcars.rds")
#' s3_get("s3://geomarker/testing_downloads/mtcars.rds") %>%
#'     readRDS()
#' }
#' @details
#' s3_get will politely refuse to download an S3 object if it already exists within the download_folder.
#'
#' Invisibly returning the S3 object file path allows for further usage of file without hard coding.
#' (See example)

s3_get <- function(s3_uri,
                   download_folder = getOption("s3.download_folder", fs::path_wd("s3_downloads")),
                   quiet = FALSE,
                   progress = FALSE,
                   force = FALSE,
                   public = FALSE) {

  parsed_uri <- s3_parse_uri(s3_uri)

  dest_file <-
    fs::path_join(c(
      download_folder,
      parsed_uri$bucket,
      parsed_uri$folder,
      parsed_uri$file_name
    ))

  if (!force & s3_check_for_file_local(s3_uri, download_folder, quiet = quiet)) {
    return(invisible(dest_file))
  }

  s3_check_for_file_s3(s3_uri, public, download_folder)

  fs::dir_create(fs::path_dir(dest_file))

  has_aws_env_vars <- suppressMessages(check_for_aws_env_vars())
  if (public) has_aws_env_vars <- FALSE

  url_get <- parsed_uri$url

  if (has_aws_env_vars) {
    url_get <- get_signed_url(s3_uri)
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
