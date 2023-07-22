skip_if_no_aws_credentials <- function() {
  have_aws_credentials <- check_for_aws_env_vars()
  if (!have_aws_credentials) skip("aws credentials not available for testing")
}

# TODO this still misses geomarker-us-west-2, for private files (or region specified)
# how can a per test download folder (rather than per session folder) be used?
delete_test_download_folder <- function() {
  download_folder <- fs::path(tools::R_user_dir("s3", "data"), "geomarker", "testing_downloads")
  if (fs::dir_exists(download_folder)) {
    fs::dir_delete(download_folder)
    cli::cli_alert_success("Deleted {download_folder}")
  }
}
