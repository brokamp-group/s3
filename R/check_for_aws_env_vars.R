check_for_aws_env_vars <- function() {
  aws_access_key_id <- Sys.getenv("AWS_ACCESS_KEY_ID")
  aws_secret_access_key <- Sys.getenv("AWS_SECRET_ACCESS_KEY")

  if (!aws_access_key_id == "" & !aws_secret_access_key == "") {
    cli::cli_alert_success(c(
      "using {.env AWS_SECRET_ACCESS_KEY}",
      " associated with ",
      "{.env AWS_ACCESS_KEY_ID}: {aws_access_key_id}"
    ))
    return(invisible(TRUE))
  }

  if (aws_access_key_id == "" | aws_secret_access_key == "") {
    cli::cli_alert_danger("{.env AWS_SECRET_ACCESS_KEY} and/or {.env AWS_ACCESS_KEY_ID} are unset")
    cli::cli_alert_info("Non-public S3 files will not be available")
    return(invisible(FALSE))
  }
}
