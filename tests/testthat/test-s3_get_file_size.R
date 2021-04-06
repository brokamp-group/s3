test_that("s3_file_size works for public file", {
  skip_if_offline(host = "r-project.org")
  withr::with_envvar(new = c(
    "AWS_ACCESS_KEY_ID" = NA,
    "AWS_SECRET_ACCESS_KEY" = NA
  ), {
    expect_equal(
      s3_file_size("s3://geomarker/testing_downloads/mtcars.rds"),
      1225
    )
  })
})

test_that("s3_file_size works for private file", {
  skip_if_offline(host = "r-project.org")
  skip_if_no_aws_credentials()
    expect_equal(
      s3_file_size(s3_uri = "s3://geomarker/testing_downloads/mtcars_private.rds", region = "us-east-2"),
      1225
    )
})

test_that("s3_file_size invisibly and silently returns a value", {
  skip_if_offline(host = "r-project.org")
  expect_invisible(s3_file_size("s3://geomarker/testing_downloads/mtcars.rds"))
  expect_silent(s3_file_size("s3://geomarker/testing_downloads/mtcars.rds"))
})
