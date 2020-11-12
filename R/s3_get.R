#' download s3 file
#' 
#' @export
#' @param s3_uri URI for an S3 object
#' @param download_folder location to download S3 object
#' @param quiet suppress messages?
#' @param force force download to overwrite existing S3 object
#' @return file path to downloaded file (invisibly)
#' @examples
#' s3_get("s3://geomarker/testing_downloads/mtcars.rds")
#' s3_get("s3://geomarker/testing_downloads/mtcars.rds") %>%
#'     readRDS()
#' @details 
#' s3_get will politely refuse to download an S3 object if it already exists within the download_folder.
#' 
#' Invisibly returning the S3 object file path allows for further usage of file without hard coding.
#' (See example)

s3_get <- function(s3_uri,
                   download_folder = getOption("s3.download_folder", fs::path_wd("s3_downloads")),
                   quiet = FALSE,
                   force = FALSE) {
    parsed_uri <- s3_parse_uri(s3_uri)

    dest_folder <-
        fs::path_join(c(
            download_folder,
            parsed_uri$bucket,
            parsed_uri$folder
        ))
    fs::dir_create(dest_folder)

    dest_file <- fs::path_join(c(dest_folder, parsed_uri$file_name))

    if (fs::file_exists(dest_file) & !force) {
        if (!quiet) cli::cli_alert_info("{.file {s3_uri}} already exists at {.file {dest_file}}")
        return(invisible(dest_file))
    }

    stop_if_no_boto()

    if (!quiet) {
        cli::cli_alert_info(c(
            "{.file {s3_uri}} is {.strong {prettyunits::pretty_bytes(s3_file_size(s3_uri))}}",
            "; downloading to {.file {dest_file}}"
        ))
    }


    boto$download_file(
        Bucket = parsed_uri$bucket,
        Key = parsed_uri$key,
        Filename = dest_file
    )

    return(invisible(dest_file))
}
