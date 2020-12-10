#' download several s3 files
#'
#' @export
#' @param s3_uri vector of S3 object URIs
#' @param download_folder location to download S3 objects
#' @param progress show download progress for each individual file? (currently only for public objects)
#' @param force force download to overwrite existing S3 objects
#' @param confirm ask user to interactively confirm downloads? (only possible when session is interactive)
#' @return tibble with s3_uris and corresponding file paths to downloaded files (invisibly)
#' @examples
#' \dontrun{
#' s3_get_files(c(
#'     "s3://geomarker/testing_downloads/mtcars.rds",
#'     "s3://geomarker/testing_downloads/mtcars.fst"
#' ))
#' 
#' dl_results <- s3_get_files(c(
#'     "s3://geomarker/testing_downloads/mtcars.rds",
#'     "s3://geomarker/testing_downloads/mtcars_again.rds"
#' ))
#' lapply(dl_results$file_path, readRDS)
#' 
#' # download some larger files
#' s3_get_files(s3_uri = c(
#'     "s3://geomarker/testing_downloads/zctas_2000_contig_us_5072.rds",
#'     "s3://geomarker/testing_downloads/county_fips_contig_us_5072.rds"
#' ))
#' }
#' @details
#' Progress messages for downloading several S3 objects at once cannot be silenced.
#'
#' Like s3_get, S3 objects that already exists within the download_folder will not be re downloaded
#'
#' Invisibly returning the S3 object file paths allows for further usage of files without hard coding.
#' (See example)


# TODO: add in checking for each file up front, so we can report an accurate total download size only actually for the files that will be downloaded

s3_get_files <- function(s3_uri,
                         download_folder = getOption("s3.download_folder", fs::path_wd("s3_downloads")),
                         progress = FALSE,
                         force = FALSE,
                         confirm = TRUE) {

    n_files <- length(s3_uri)

    out <- tibble::tibble(s3_uri = s3_uri)

    files_size <- Reduce(f = `+`, x = lapply(s3_uri, s3_file_size))

    cli::cli_alert_info("{n_files} file{?s} totaling {prettyunits::pretty_bytes(files_size)} will be downloaded to {download_folder} ")
    if (interactive() & confirm) ui_confirm()

    download_files_with_progress <- function(...) {
        sb <- cli::cli_status("{cli::symbol$arrow_right} Downloading {n_files} files.")

        file_paths <- vector("list", length = n_files)

        for (i in n_files:1) {
            cli::cli_status_update(
                id = sb,
                "{cli::symbol$arrow_right} Got {n_files - i} file{?s}, downloading {i}"
            )
            file_paths[i] <- s3_get(out[i, "s3_uri"], ...)
        }
        cli::cli_status_clear(id = sb)
        return(file_paths)
    }

    download_time <- system.time({
        out$file_path <- download_files_with_progress(download_folder = download_folder, quiet = TRUE, force = force, progress = progress)
    })["elapsed"]

    cli::cli_alert_success("Downloaded {n_files} file{?s} in {prettyunits::pretty_sec(download_time)}.")

    return(invisible(out))
}
