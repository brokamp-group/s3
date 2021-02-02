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

s3_get_files <- function(s3_uri,
                         download_folder = getOption("s3.download_folder", fs::path_wd("s3_downloads")),
                         progress = FALSE,
                         force = FALSE,
                         confirm = TRUE) {

    out <- tibble::tibble(s3_uri = s3_uri)

    out$parsed_uri <- purrr::map(out$s3_uri, s3_parse_uri)
    out$dest_folder <- purrr::map_chr(out$parsed_uri,
                             ~ fs::path_join(c(
                                 download_folder,
                                 .x$bucket,
                                 .x$folder)))
    out$dest_file <- purrr::map2_chr(out$dest_folder,
                                     out$parsed_uri,
                                     ~ fs::path_join(c(.x, .y$file_name)))
    out$s3_check_result <- purrr::map2_chr(out$dest_file,
                                       out$parsed_uri,
                                       ~s3_check_file(.x, .y,
                                                      has_aws_env_vars = suppressMessages(check_for_aws_env_vars())))

    # if file exists in download_folder, alert user and do not download again
    exists_already <- out[out$s3_check_result == 'already exists',]
    n_exists_already <- nrow(exists_already)

    if (n_exists_already > 0 & !force) {
        exists_already$file_path <- exists_already$dest_file
        cli::cli_alert_info("{n_exists_already} file{?s} already exist in {download_folder}")
        print(exists_already$dest_file)
    }

    # if user does not have access or file does not exist, remove from files to be downloaded
    no_access <- out[out$s3_check_result == 'access denied',]
    n_no_access <- nrow(no_access)

    if (n_no_access > 0) {
        cli::cli_alert_danger("You do not have access to {n_no_access} file{?s} or they do not exist.
                              These files will not be downloaded.")
        print(no_access$dest_file)
    }

    # if file does not exist in download_folder and user has access, download now
    need_to_download <- out[out$s3_check_result == 'proceed',]
    n_files <- nrow(need_to_download)

    if (n_files < 1) {
        cli::cli_alert_warning('no files were downloaded')
       if (n_exists_already > 0) return(invisible(exists_already[,c('s3_uri', 'file_path')]))
        else return()
    }

    files_size <- Reduce(f = `+`, x = lapply(need_to_download$s3_uri, s3_file_size))

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
            file_paths[i] <- s3_get(need_to_download[i, "s3_uri"], ...)
        }

        cli::cli_status_clear(id = sb)
        return(file_paths)
    }

    download_time <- system.time({
        need_to_download$file_path <- download_files_with_progress(download_folder = download_folder, quiet = TRUE, force = force, progress = progress)
    })["elapsed"]

    cli::cli_alert_success("Downloaded {n_files} file{?s} in {prettyunits::pretty_sec(download_time)}.")

    # return all file paths (for files that already existed and those that were downloaded)
    out <- rbind(exists_already, need_to_download)[,c('s3_uri', 'file_path')]
    out$file_path <- unlist(out$file_path)

    return(invisible(out))
}
