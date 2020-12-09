# get size of s3 file (number of bytes)
s3_file_size <- function(s3_uri) {

    parsed_uri <- s3_parse_uri(s3_uri)

    has_aws_env_vars <- suppressMessages(check_for_aws_env_vars())

    if (has_aws_env_vars) {
        stop_if_no_boto()
        head_object <-
            boto$client("s3")$head_object(
                Bucket = parsed_uri$bucket,
                Key <- parsed_uri$key
            )
        file_size <- head_object$ContentLength
    }

    if (!has_aws_env_vars) {
        s3_response <- httr::HEAD(parsed_uri$url)
        file_size <- httr::headers(s3_response)[["Content-Length"]] %>%
            as.numeric()
    }

    return(invisible(file_size))
}
