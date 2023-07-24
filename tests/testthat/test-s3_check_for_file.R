test_that("s3_check_for_file_local returns FALSE if file does not exist locally", {
  skip_if_offline(host = "r-project.org")
  Sys.setenv("R_USER_DATA_DIR" = tempdir())
  expect_false(
    s3_check_for_file_local("s3://geomarker/testing_downloads/mtcars.rds")
  )
})

test_that("s3_check_for_file_local returns TRUE if file exists locally", {
  skip_if_offline(host = "r-project.org")
  Sys.setenv("R_USER_DATA_DIR" = tempdir())
  the_file <- s3_get("s3://geomarker/testing_downloads/mtcars.rds")
  expect_true(
    s3_check_for_file_local("s3://geomarker/testing_downloads/mtcars.rds")
  )
  unlink(the_file)
})

test_that("s3_check_for_file_s3 returns error if file doesn't exist in S3", {
  skip_if_offline(host = "r-project.org")
  expect_error(
    s3_check_for_file_s3(s3_uri = "s3://geomarker/testing_downloads/foo-foo.rds")
  )
})

test_that("s3_check_for_file_s3 returns TRUE for private file with aws credentials", {
  skip_if_offline(host = "r-project.org")
  skip_if_no_aws_credentials()
  Sys.setenv("R_USER_DATA_DIR" = tempdir())
  expect_true(
    s3_check_for_file_s3("s3://geomarker/testing_downloads/mtcars_private.rds")
  )
})

test_that("s3_check_for_file_s3 returns error for private file without aws credentials", {
  skip_if_offline(host = "r-project.org")
  withr::with_envvar(new = c(
    "AWS_ACCESS_KEY_ID" = NA,
    "AWS_SECRET_ACCESS_KEY" = NA
  ), {
    expect_error(
      s3_check_for_file_s3("s3://geomarker/testing_downloads/mtcars_private.rds")
    )}
  )
})

test_that("s3_check_for_file_s3 errors if public file is available but aws credentials are invalid", {
  skip_if_offline(host = "r-project.org")
  withr::with_envvar(new = c(
    "AWS_ACCESS_KEY_ID" = "thisisfake",
    "AWS_SECRET_ACCESS_KEY" = "thisisfaketoo"
  ), {
    expect_error(
      s3_check_for_file_s3(s3_uri = "s3://geomarker/testing_downloads/mtcars.rds")
    )}
  )
})

test_that("s3_check_for_file_s3 returns TRUE if public file is available without aws credentials", {
  skip_if_offline(host = "r-project.org")
  withr::with_envvar(new = c(
    "AWS_ACCESS_KEY_ID" = NA,
    "AWS_SECRET_ACCESS_KEY" = NA
  ), {
    expect_true(
      s3_check_for_file_s3("s3://geomarker/testing_downloads/mtcars.rds")
    )}
  )
})

