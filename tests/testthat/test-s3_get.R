
test_that("s3_get downloads a public file", {
  skip_if_no_boto()
  skip_if_offline(host = "r-project.org")

  expect_identical(
    readRDS(s3_get("s3://geomarker/testing_downloads/mtcars.rds")),
    mtcars
  )
  delete_test_download_folder()
})

test_that("s3_get downloads a private file", {
  skip_if_no_boto()
  skip_if_offline(host = "r-project.org")
  delete_test_download_folder()

  expect_identical(
    readRDS(s3_get("s3://geomarker/testing_downloads/mtcars_private.rds")),
    mtcars
  )

  delete_test_download_folder()
})

test_that("s3_get_files downloads all files (forcing no user confirmation)", {
  skip_if_no_boto()
  skip_if_offline(host = "r-project.org")

  expect_success({
    s3_get_files(s3_uri = c(
      "s3://geomarker/testing_downloads/mtcars.rds",
      "s3://geomarker/testing_downloads/mtcars.fst"
    ), confirm = FALSE)
  })
  delete_test_download_folder()
})

test_that("check_for_aws_env_vars succeeds", {
  check_for_aws_env_vars()
})