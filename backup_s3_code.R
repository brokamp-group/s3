# Call s3 and get object size for one file
get_fl_size <- function(s3_fl_url) {
  x <- aws.s3::head_object(s3_fl_url)
  size_mb <- round(as.numeric(attr(x = x, which = "content-length"))*0.000001, 1)
  return(tibble::tibble(file_name = s3_fl_url, size_mb = size_mb))
}

# sum file sizes for all requested downloads
get_total_fl_size <- function(fls) {
  purrr::map_dfr(fls, get_fl_size) %>%
    summarize(total_size = sum(size_mb)) %>%
    mutate(total_size = ifelse(total_size > 999,
                               paste0(total_size/1000, " GB"),
                               paste0(total_size, " MB"))) %>%
    .$total_size
}

# check if file is already present in specified local directory
check_local_fls_exist <- function(fl_names, s3_folder_url, download_dir) {
  t <- tibble::tibble(local_file_name = fl_names) %>%
    mutate(exists = purrr::map_lgl(fl_names, ~file.exists(fs::path(download_dir, .x))))

  fls_to_download <- t %>%
    dplyr::filter(exists == FALSE) %>%
    .$local_file_name

  if (length(fls_to_download) > 0) {
    fls_to_download_s3_url <- paste0(s3_folder_url, fls_to_download)
  } else {
    fls_to_download_s3_url <- vector()
  }

  return(fls_to_download_s3_url)
}

# download file from s3
download_s3 <- function(fl_names, s3_folder_url, download_dir) {
  # check if file exists in s3
  s3_exists <- purrr::map_lgl(paste0(s3_folder_url, fl_names), ~suppressMessages(aws.s3::head_object(.x)))
  if(length(s3_exists[s3_exists]) != length(s3_exists)) {
    stop("One or more requested files do not exist in the specified s3 folder.", call. = FALSE)
  }

  fls <- check_local_fls_exist(fl_names, s3_folder_url, download_dir)

  if(length(fls) > 0) {
    total_size <- get_total_fl_size(fls)
    message(length(fls), " of ", length(fl_names), " file(s) were not found in ", download_dir)
    message("The total size of the download is ", total_size)
    ans <- readline("Do you want to download now (Y/n)? ")
    if (!ans %in% c("", "y", "Y")) stop("aborted", call. = FALSE)

    purrr::walk2(fls, fl_names,
                 ~aws.s3::save_object(object = .x,
                       file = paste0(download_dir, '/', .y)))
    message('Download complete.')
  }

  if(length(fls) < 1) {
    message('All files are present in ', download_dir)
  }
}
