# download s3 file if not already present
# invisibly returns destination file path
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

    if (!quiet) {
        cli::cli_alert_info(c(
            "{.file {s3_uri}} is {.strong {prettyunits::pretty_bytes(s3_file_size(s3_uri))}}",
            "; downloading to {.file {dest_file}}"
        ))
    }

    stop_if_no_boto()

    boto$download_file(
        Bucket = parsed_uri$bucket,
        Key = parsed_uri$key,
        Filename = dest_file
    )

    return(invisible(dest_file))
}
