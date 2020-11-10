skip_if_no_boto <- function() {
  have_boto <- reticulate::py_module_available("boto3")
  if (!have_boto)
    skip("boto not available for testing")
}
