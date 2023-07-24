#' download several s3 files
#' 
#' Progress messages for downloading several S3 objects at once cannot be silenced.
#' Like s3_get, S3 objects that have already been downloaded will not be re downloaded
#' @param s3_uri vector of S3 object URIs
#' @param region AWS region for bucket containing the file (defaults to "us-east-2", but only required for private files)
#' @param progress show download progress for each individual file? (currently only for public objects)
#' @param force force download to overwrite existing S3 objects
#' @param confirm ask user to interactively confirm downloads? (only possible when session is interactive)
#' @param public defaults to FALSE; if TRUE, ignore any environment
#'                    variables specifying AWS credentials and
#'                    attempt to download the file as publicly available
#' @return data.frame (or tibble) with s3_uris and corresponding file paths to downloaded files (invisibly)
#' @examples
#' \donttest{
#' Sys.setenv("R_USER_DATA_DIR" = tempdir())
#' the_files <- s3_get_files(c(
#'     "s3://geomarker/testing_downloads/mtcars.rds",
#'     "s3://geomarker/testing_downloads/mtcars.fst"
#' ))
#' unlink(the_files$file_path)
#' }
#' @export
s3_get_files <-
  function(s3_uri,
           region = "us-east-2",
           progress = FALSE,
           force = FALSE,
           confirm = TRUE,
           public = FALSE) {

  out <-
    purrr::map(s3_uri, s3_parse_uri) |>
    dplyr::bind_rows() |>
    dplyr::mutate(exists_already = purrr::map_lgl(uri,
      s3_check_for_file_local,
      quiet = TRUE
    ))

  out <-
    out |>
    dplyr::rowwise() |>
    dplyr::mutate(
      file_path =
        fs::path_join(c(
          tools::R_user_dir("s3", "data"),
          bucket,
          folder,
          file_name
        ))
    )

    n_exist <- sum(out$exists_already)
    n_to_dl <- sum(!out$exists_already)

    if (n_to_dl == 0 & !force) {
      cli::cli_alert_info("all files already exist")
      return(invisible(dplyr::select(out, uri, file_path)))
    }

    if (n_exist > 0 & !force) {
      cli::cli_alert_info("{n_exist} file{?s} already exis{?ts/t}")
    }

    if (force) out$exists_already <- TRUE

    need_to_download <- dplyr::filter(out, !exists_already)

    files_size <- Reduce(f = `+`, x = lapply(need_to_download$uri, s3_file_size, region = region, public = public))

    cli::cli_alert_info("{n_to_dl} file{?s} totaling {prettyunits::pretty_bytes(files_size)} will be downloaded to {tools::R_user_dir('s3', 'data')}")
    if (interactive() & confirm) ui_confirm()

    download_files_with_progress <- function(...) {
        sb <- cli::cli_status("{cli::symbol$arrow_right} Downloading {n_to_dl} file{?s}.")

        file_paths <- vector("list", length = n_to_dl)

        for (i in n_to_dl:1) {
            cli::cli_status_update(
                id = sb,
                "{cli::symbol$arrow_right} Got {n_to_dl - i} file{?s}, downloading {i}"
            )
            file_paths[i] <- s3_get(need_to_download[i, "uri"], ...)
        }

        cli::cli_status_clear(id = sb)
        return(file_paths)
    }

    download_time <- system.time({
      download_files_with_progress(
        region = region,
        quiet = TRUE,
        force = TRUE,
        public = public,
        progress = progress
      )
    })["elapsed"]

    cli::cli_alert_success("Downloaded {n_to_dl} file{?s} in {prettyunits::pretty_sec(download_time)}.")

    # return all file paths (for files that already existed and those that were downloaded)
    return(invisible(dplyr::select(out, uri, file_path)))
}
