test_that("s3_get downloads a public file without aws credentials", {
  skip_if_offline(host = "r-project.org")
  delete_test_download_folder()
  withr::with_envvar(new = c(
    "AWS_ACCESS_KEY_ID" = NA,
    "AWS_SECRET_ACCESS_KEY" = NA
  ), {
    expect_identical(
      readRDS(s3_get("s3://geomarker/testing_downloads/mtcars.rds")),
      mtcars
    )
  })
  delete_test_download_folder()
})

test_that("s3_get downloads a private file", {
  skip_if_no_aws_credentials()
  skip_if_offline(host = "r-project.org")
  delete_test_download_folder()
  expect_identical(
    readRDS(s3_get(s3_uri = "s3://geomarker/testing_downloads/mtcars_private.rds")),
    mtcars
  )
  delete_test_download_folder()
})

test_that("s3_get downloads a private file from a different region", {
  skip_if_no_aws_credentials()
  skip_if_offline(host = "r-project.org")
  delete_test_download_folder()
  expect_identical(
    readRDS(s3_get("s3://geomarker-us-west-2/testing_downloads/mtcars_private.rds", region = "us-west-2")),
    mtcars
  )
  delete_test_download_folder()
})

test_that("s3_get does not download a file if it already exists ", {
  skip_if_offline(host = "r-project.org")
  delete_test_download_folder()
  s3_get(s3_uri = "s3://geomarker/testing_downloads/mtcars.rds")
  expect_message(
    s3_get("s3://geomarker/testing_downloads/mtcars.rds"),
    "already exists at"
  )
  delete_test_download_folder()
})


test_that("s3_get does not download private file with no credentials", {
  skip_if_offline(host = "r-project.org")
  delete_test_download_folder()
  withr::with_envvar(new = c(
    "AWS_ACCESS_KEY_ID" = NA,
    "AWS_SECRET_ACCESS_KEY" = NA
  ), {
    expect_error(
      readRDS(s3_get("s3://geomarker/testing_downloads/mtcars_private.rds")),
      ""
    )
  })
  delete_test_download_folder()
})

test_that("s3_get does not download a private file with incorrect aws credentials", {
  skip_if_offline(host = "r-project.org")
  delete_test_download_folder()
  withr::with_envvar(new = c(
    "AWS_ACCESS_KEY_ID" = 'thisisfake',
    "AWS_SECRET_ACCESS_KEY" = 'thisisfaketoo'
  ), {
    expect_error(
      readRDS(s3_get("s3://geomarker/testing_downloads/mtcars_private.rds")),
      ""
    )
  })
  delete_test_download_folder()
})

test_that("s3_get force public download with aws creds", {
  skip_if_offline(host = "r-project.org")
  delete_test_download_folder()
  withr::with_envvar(new = c(
    "AWS_ACCESS_KEY_ID" = "thisisfake",
    "AWS_SECRET_ACCESS_KEY" = "thisisfaketoo"
  ), {
    expect_identical(
      readRDS(s3_get("s3://geomarker/testing_downloads/mtcars.rds", public = TRUE)),
      mtcars
    )
  })
  delete_test_download_folder()
})
