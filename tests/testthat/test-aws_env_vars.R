test_that("check_for_aws_env_vars returns true if credentials set", {
  skip_if_no_aws_credentials()
  expect_true(check_for_aws_env_vars())
})

test_that("check_for_aws_env_vars returns false if credentials unset", {
  withr::with_envvar(new = c(
    "AWS_ACCESS_KEY_ID" = NA,
    "AWS_SECRET_ACCESS_KEY" = NA
  ), {
    expect_false(check_for_aws_env_vars())
  })
})

test_that("s3_get downloads a private file", {
  skip_if_no_boto()
  skip_if_no_aws_credentials()
  skip_if_offline(host = "r-project.org")
  delete_test_download_folder()

  expect_identical(
    readRDS(s3_get("s3://geomarker/testing_downloads/mtcars_private.rds")),
    mtcars
  )

  delete_test_download_folder()
})