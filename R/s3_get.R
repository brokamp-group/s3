#' download s3 file
#'
#' @export
#' @param s3_uri URI for an S3 object
#' @param download_folder location to download S3 object
#' @param quiet suppress messages?
#' @param force force download to overwrite existing S3 object
#' @param progress show download progress? (currently only for public objects)
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
                   force = FALSE) {

    parsed_uri <- s3_parse_uri(s3_uri)

    if (progress) {
        progress <- httr::progress()
    } else {
        progress <- NULL
    }

    dest_folder <-
        fs::path_join(c(
            download_folder,
            parsed_uri$bucket,
            parsed_uri$folder
        ))
    fs::dir_create(dest_folder)

    dest_file <- fs::path_join(c(dest_folder, parsed_uri$file_name))

    has_aws_env_vars <- suppressMessages(check_for_aws_env_vars())
    s3_check_result <- s3_check_file(dest_file, parsed_uri, has_aws_env_vars)

    if (s3_check_result == 'already exists' & !force) {
        if (!quiet) cli::cli_alert_info("{.file {s3_uri}} already exists at {.file {dest_file}}")
        return(invisible(dest_file))
    }

    if (s3_check_result == 'access denied') {
        cli::cli_alert_warning('You do not have access to {.file {s3_uri}} or it does not exist')
        stop()
    }

    if (!quiet) {
        cli::cli_alert_info(c(
            "{.file {s3_uri}} is {.strong {prettyunits::pretty_bytes(s3_file_size(s3_uri))}}",
            "; downloading to {.file {dest_file}}"
        ))
    }

    if (has_aws_env_vars) {
    stop_if_no_boto()
        boto$client("s3")$download_file(
            Bucket = parsed_uri$bucket,
            Key = parsed_uri$key,
            Filename = dest_file
        )
    }

    if (!has_aws_env_vars) {
        gets <- httr::GET(
            parsed_uri$url,
            httr::write_disk(dest_file, overwrite = TRUE),
            progress
        )
    }

    return(invisible(dest_file))
}
