skip_if_no_aws_credentials <- function() {
  have_aws_credentials <- check_for_aws_env_vars()
  if (!have_aws_credentials) skip("aws credentials not available for testing")
}
