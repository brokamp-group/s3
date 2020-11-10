library(cli)
library(reticulate)
library(magrittr)

# install pip modules if needed
if (!reticulate::py_module_available("boto3")) {
    reticulate::py_install("boto3", method = method, conda = conda)
}

# import pip modules into R
# awscli <- reticulate::import("awscli")
boto <- reticulate::import("boto3")$client("s3")

# function that converts an s3 uri to the components needed
s3_parse_uri <- function(s3_uri) {
    if (!grepl("^(s3://)", s3_uri)) {
        stop(s3_uri, " does not begin with s3://", call. = FALSE)
    }

    file_name <- fs::path_file(s3_uri)
    file_path_parts <- fs::path_split(s3_uri)[[1]]
    bucket <- file_path_parts[2]
    folder <-
        file_path_parts[3:(length(file_path_parts) - 1)] %>%
        fs::path_join() %>%
        as.character()
    key <-
        fs::path_join(c(folder, file_name)) %>%
        as.character()

    return(
        list(
            uri = s3_uri,
            bucket = bucket,
            key = key,
            folder = folder,
            file_name = file_name
        )
    )
}

s3_parse_uri("s3://geomarker/testing_downloads/mtcars.rds")
s3_parse_uri("s3://geomarker/mtcars.rds")
s3_parse_uri("s3://geomarker/schwartz/pm25/ver_1/mtcars.rds")

# get size of s3 file (number of bytes)
s3_file_size <- function(s3_uri) {
    parsed_uri <- s3_parse_uri(s3_uri)

    head_object <-
        boto$head_object(
            Bucket = parsed_uri$bucket,
            Key = parsed_uri$key
        )

    file_size <- head_object$ContentLength
    class(file_size) <- c("fl_sz", class(file_size))
    return(file_size)
}


# pretty print the file sizes
print.fl_sz <- function(file_size) {
    print(prettyunits::pretty_bytes(file_size))
}

# printing shows files size in human-readable units
s3_file_size("s3://geomarker/testing_downloads/mtcars.rds")
# but underlying value is number of bytes allowing for further processing
message(s3_file_size("s3://geomarker/testing_downloads/mtcars.rds"))

# download s3 file is not already present
# invisibly returns destination file path
s3_get <- function(s3_uri, local_s3_folder = getwd(), verbose = TRUE, force_download = FALSE) {
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

    if (fs::file_exists(dest_file) & !force_download) {
        if (verbose) cli_alert_info("{.file {s3_uri}} already exists at {.file {dest_file}}")
        return(invisible(dest_file))
    }

    if (verbose) {
        cli_alert_info(c(
            "{.file {s3_uri}} is {.strong {print(s3_file_size(s3_uri))}}",
            "; downloading to {.file dest_file}"
        ))
    }

    boto$download_file(
        Bucket = parsed_uri$bucket,
        Key = parsed_uri$key,
        Filename = dest_file
    )

    return(invisible(dest_file))
}

# this could be included in a script independent of user assuming that all files are in working directory
# how could we allow for setting of a custom local_s3_folder without changing the code??  user option?
s3_get("s3://geomarker/testing_downloads/mtcars.rds") %>%
    readRDS()

# To use environment variables, do the following:

# $ export AWS_ACCESS_KEY_ID=<access_key>
# $ export AWS_SECRET_ACCESS_KEY=<secret_key>

# should we do this too??
s3_put <- function() {}


ui_confirm <- function() {
    if (!interactive()) {
        cli_alert_warning("User input requested, but session is not interactive.")
        cli_alert_info("Assuming this is okay.")
        return(TRUE)
    }

    ans <- readline("Is this okay (y/n)? ")
    if (!ans %in% c("", "y", "Y")) stop("aborted", call. = FALSE)
    return(invisible(TRUE))
}

s3_get_files <- function(s3_uri, local_s3_folder = getwd()) {

    # TODO: add in checking for each file up front, so we can report an accurate total download size only actually for the files that will be downloaded

    n_files <- length(s3_uri)


    files_size <-
        purrr::map(s3_uri, s3_file_size) %>%
        purrr::reduce(`+`)

    cli_alert_info("{n_files} file{?s} totaling {print(files_size)} will be downloaded to {local_s3_folder} ")
    ui_confirm()

    f <- function() {
        cli_alert_info("Now downloading {n_files} file{?s}, {print(files_size)} in total size")
        sb <- cli_status("{symbol$arrow_right} Downloading {n_files} files.")

        for (i in n_files:1) {
            s3_get(s3_uri[i], verbose = FALSE)
            cli_status_update(
                id = sb,
                "{symbol$arrow_right} Got {n_files - i} file{?s}, downloading {i}"
            )
        }
        cli_status_clear(id = sb)
    }


    download_time <- system.time(f())["elapsed"]

    cli_alert_success("Downloaded {n_files} file{?s} in {prettyunits::pretty_sec(download_time)}.")

    return(invisible(NULL))
}

s3_get_files(s3_uri = c(
    "s3://geomarker/testing_downloads/mtcars.rds",
    "s3://geomarker/testing_downloads/mtcars.fst"
))
