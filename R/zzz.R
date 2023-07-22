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

utils::globalVariables(c("uri", "bucket", "folder", "file_name", "file_path", "exists_already"))
