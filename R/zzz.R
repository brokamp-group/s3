# global reference to boto (will be initialized in .onLoad)
boto <- NULL

.onLoad <- function(libname, pkgname) {
  boto <<- reticulate::import("boto3", delay_load = TRUE)
  # boto <<- reticulate::import("boto3", delay_load = TRUE)
}

# call this in functions before using boto for informative error messages
stop_if_no_boto <- function() {
  if (!reticulate::py_module_available("boto3")) {
    cli::cli_alert_danger("The boto3 python module is required for this functionality, but is not available")
    cli::cli_alert_info("install boto3 python module from R by running {.code reticulate::py_install('boto3')}")
    stop(call. = FALSE)
  }
}


ui_confirm <- function() {
    if (!interactive()) {
        cli::cli_alert_warning("User input requested, but session is not interactive.")
        cli::cli_alert_info("Assuming this is okay.")
        return(TRUE)
    }

    ans <- readline("Is this okay (y/n)? ")
    if (!ans %in% c("", "y", "Y")) stop("aborted", call. = FALSE)
    return(invisible(TRUE))
}

check_for_aws_env_vars <- function() {
  aws_access_key_id <- Sys.getenv("AWS_ACCESS_KEY_ID")
  aws_secret_access_key <- Sys.getenv("AWS_SECRET_ACCESS_KEY")

  if (!aws_access_key_id == "" & !aws_secret_access_key == "") {
    cli::cli_alert_success(c(
      "using {.env AWS_SECRET_ACCESS_KEY}",
      " associated with ",
      "{.env AWS_ACCESS_KEY_ID}: {aws_access_key_id}"
    ))
  }

  if (aws_access_key_id == "" | aws_secret_access_key == "") {
    cli::cli_alert_danger("{.env AWS_SECRET_ACCESS_KEY} and/or {.env AWS_ACCESS_KEY_ID} are unset")
    cli::cli_alert_info("Non-public S3 files will not be available")
  }
}