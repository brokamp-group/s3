test_that("s3_file_size returns the right value", {
  skip_if_offline(host = "r-project.org")
  skip_if_no_boto()
  skip_if_no_aws_credentials()
  expect_equal(
    s3_file_size("s3://geomarker/testing_downloads/mtcars.rds"),
    1225
  )
})

test_that("s3_file_size invisibly and silently returns a value", {
  skip_if_offline(host = "r-project.org")
  skip_if_no_boto()
  skip_if_no_aws_credentials()
  expect_invisible(s3_file_size("s3://geomarker/testing_downloads/mtcars.rds"))
  expect_silent(s3_file_size("s3://geomarker/testing_downloads/mtcars.rds"))
})