s3_check_file <- function(dest_file, parsed_uri) {
  # 1. check if exists in download_folder

      # yes, skip, print
  if (fs::file_exists(dest_file)) return('already exists')
      # no, move on

  # 2. check if exists in s3/user has access to file

      # no, skip, print
  s3_response <- httr::HEAD(parsed_uri$url)
  if (httr::status_code(s3_response) == 403) return('access denied')
      # yes, download
  else return('proceed')
}
