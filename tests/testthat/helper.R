skip_if_no_aws_credentials <- function() {
  have_aws_credentials <- check_for_aws_env_vars()
  if (!have_aws_credentials) skip("aws credentials not available for testing")
}

delete_test_download_folder <- function() {
  download_folder <- getOption("s3.download_folder", fs::path_wd("s3_downloads"))
  if (fs::dir_exists(download_folder)) {
    fs::dir_delete(download_folder)
    cli::cli_alert_success("Deleted {download_folder}")
  }
}
