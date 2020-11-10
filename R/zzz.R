# global reference to boto (will be initialized in .onLoad)
boto <- NULL

.onLoad <- function(libname, pkgname) {
  # use superassignment to update global reference to scipy
  boto <<- reticulate::import("boto3", delay_load = TRUE)$client("s3")
}

# call this in functions before using boto for informative error messages
stop_if_no_boto <- function() {
  if (!reticulate::py_module_available("boto3")) {
    cli::cli_alert_danger("The boto3 python module is required for this functionality, but is not available")
    cli::cli_alert_info("install boto3 python module from R by running {.code reticulate::py_install('boto3')}")
    stop()
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
