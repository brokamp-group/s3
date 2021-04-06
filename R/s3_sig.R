# credentials

# https://gist.github.com/sada1993/055f6d3c546cb97ea9d3b11f9a92e91e#file-generate_s3_signed_url-r

get_aws_signed_url <- function(s3_uri, timeout_seconds = 30, region = "us-east-2"){

  parsed_uri <- s3_parse_uri(s3_uri)

  bucket <- parsed_uri$bucket
  file <- parsed_uri$key
  key <- Sys.getenv("AWS_ACCESS_KEY_ID")
  secret <- Sys.getenv("AWS_SECRET_ACCESS_KEY")

  time <- Sys.time()
  date_time <- format(time, "%Y%m%dT%H%M%SZ", tz = "UTC")
  
  # Build query parameters
  date <- glue::glue("/{format(time,'%Y%m%d', tz = 'UTC')}/")
  region_encoded <- glue::glue("{region}/")
  
  body_hash <- tolower(digest::digest("", algo = "sha256", serialize = FALSE))
  
  sig <-
    aws.signature::signature_v4_auth(
      datetime = date_time,
      region = region,
      service = "s3",
      verb = "GET",
      action = glue::glue("/{bucket}/{file}"),
      key = key,
      secret = secret,
      request_body = "",
      query_args = list(
        `X-Amz-Algorithm` = "AWS4-HMAC-SHA256",
        `X-Amz-Credential` = glue::glue("{key}{date}{region_encoded}s3/aws4_request"),
        `X-Amz-Date` = date_time,
        `X-Amz-Expires` = timeout_seconds,
        `X-Amz-SignedHeaders` = "host",
        `x-amz-content-sha256` = body_hash
      ),
      algorithm = "AWS4-HMAC-SHA256",
      canonical_headers = list(host = glue::glue("s3-{region}.amazonaws.com"))
    )

  return(
    glue::glue(
      "https://s3-{region}.amazonaws.com",
      "/{bucket}",
      "/{file}",
      "?X-Amz-Algorithm={sig$Query$`X-Amz-Algorithm`}",
      "&X-Amz-Credential={sig$Query$`X-Amz-Credential`}",
      "&X-Amz-Date={sig$Query$`X-Amz-Date`}",
      "&X-Amz-Expires={sig$Query$`X-Amz-Expires`}",
      "&x-amz-content-sha256={sig$Query$`x-amz-content-sha256`}",
      "&X-Amz-SignedHeaders={sig$Query$`X-Amz-SignedHeaders`}",
      "&X-Amz-Signature={sig$Signature}"))

}

get_aws_signed_url("s3://geomarker/testing_downloads/mtcars_private.rds")



## https://docs.aws.amazon.com/AmazonS3/latest/API/sigv4-auth-using-authorization-header.html

make_headers <- function(s3_uri) {

  parsed_uri <- s3_parse_uri(s3_uri)

  headers <- list()
  date_time <- format(Sys.time(), "%Y%m%dT%H%M%SZ", tz = "UTC")
  headers[["x-amz-date"]] <- date_time
  headers[["x-amz-content-sha256"]] <- tolower(digest::digest("", algo = "sha256", serialize = FALSE))
  headers[["host"]] <- glue::glue("{parsed_uri$bucket}.s3.amazonaws.com")

  sig <-
    aws.signature::signature_v4_auth(
      datetime = date_time,
      region = "us-east-2",
      service = "s3",
      verb = "GET",
      action = glue::glue("/{parsed_uri$bucket}/{parsed_uri$key}"),
      algorithm = "AWS4-HMAC-SHA256",
      canonical_headers = headers,
      request_body = "",
      key = Sys.getenv("AWS_ACCESS_KEY_ID"),
      secret = Sys.getenv("AWS_SECRET_ACCESS_KEY")
    )
  
  headers[["Authorization"]] <- sig[["SignatureHeader"]]

  return(headers)
}

make_headers("s3://geomarker/testing_downloads/mtcars_private.rds")

httr::GET(
  s3_parse_uri("s3://geomarker/testing_downloads/mtcars_private.rds")$url,
  do.call(httr::add_headers, make_headers("s3://geomarker/testing_downloads/mtcars_private.rds")),
  httr::write_disk("testing.rds", overwrite = TRUE)
)
