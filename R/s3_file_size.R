# get size of s3 file (number of bytes)
s3_file_size <- function(s3_uri) {

    stop_if_no_boto()

    parsed_uri <- s3_parse_uri(s3_uri)

# note that the head of private objects can be retrieved without aws credentials
    head_object <-
        boto$client("s3")$head_object(
            Bucket = parsed_uri$bucket,
            Key = parsed_uri$key
        )

    file_size <- head_object$ContentLength
    return(invisible(file_size))
}
