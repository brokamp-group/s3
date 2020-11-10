# download s3 file if not already present
# invisibly returns destination file path
s3_get <- function(s3_uri, local_s3_folder = getwd(), quiet = FALSE, force = FALSE) {

    parsed_uri <- s3_parse_uri(s3_uri)

    dest_folder <-
        fs::path_join(c(
            local_s3_folder,
            "s3",
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
            "{.file {s3_uri}} is {.strong {print(s3_file_size(s3_uri))}}",
            "; downloading to {.file dest_file}"
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

# this could be included in a script independent of user assuming that all files are in working directory
# how could we allow for setting of a custom local_s3_folder without changing the code??  user option?

# To use environment variables, do the following:

# $ export AWS_ACCESS_KEY_ID=<access_key>
# $ export AWS_SECRET_ACCESS_KEY=<secret_key>

# should we do this too??
s3_put <- function() {}

