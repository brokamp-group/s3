skip_if_no_boto <- function() {
  have_boto <- reticulate::py_module_available("boto3")
  if (!have_boto)
    skip("boto not available for testing")
}

delete_test_download_folder <- function() {
  download_folder <- getOption("s3.download_folder", fs::path_wd("s3_downloads"))
  if (fs::dir_exists(download_folder)) fs::dir_delete(download_folder)
}
