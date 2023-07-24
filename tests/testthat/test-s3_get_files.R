test_that("s3_get_files downloads public files", {
  skip_if_offline(host = "r-project.org")
  Sys.setenv("R_USER_DATA_DIR" = tempdir())
  dl_results <- s3_get_files(s3_uri = c(
    "s3://geomarker/testing_downloads/mtcars.rds",
    "s3://geomarker/testing_downloads/mtcars_again.rds"
  ), confirm = FALSE)
  expect_identical(lapply(dl_results$file_path, readRDS), list(mtcars, mtcars))
  unlink(dl_results$file_path)
})

test_that("s3_get_files downloads private files", {
  skip_if_offline(host = "r-project.org")
  skip_if_no_aws_credentials()
  Sys.setenv("R_USER_DATA_DIR" = tempdir())
  dl_results <- s3_get_files(s3_uri = c(
    "s3://geomarker/testing_downloads/mtcars_private.rds",
    "s3://geomarker/testing_downloads/mtcars_private.rds"
  ), confirm = FALSE)
  expect_identical(lapply(dl_results$file_path, readRDS), list(mtcars, mtcars))
  unlink(dl_results$file_path)
})

test_that("s3_get_files downloads public files without aws credentials", {
  skip_if_offline(host = "r-project.org")
  Sys.setenv("R_USER_DATA_DIR" = tempdir())
  withr::with_envvar(new = c(
    "AWS_ACCESS_KEY_ID" = NA,
    "AWS_SECRET_ACCESS_KEY" = NA
  ), {
  dl_results <- s3_get_files(s3_uri = c(
    "s3://geomarker/testing_downloads/mtcars.rds",
    "s3://geomarker/testing_downloads/mtcars_again.rds"
  ), confirm = FALSE)
  expect_identical(lapply(dl_results$file_path, readRDS), list(mtcars, mtcars))
  unlink(dl_results$file_path)
  })
})

test_that("s3_get_files downloads public files overriding credentials", {
  skip_if_offline(host = "r-project.org")
  Sys.setenv("R_USER_DATA_DIR" = tempdir())
  withr::with_envvar(new = c(
    "AWS_ACCESS_KEY_ID" = "thisisfake",
    "AWS_SECRET_ACCESS_KEY" = NA
  ), {
  dl_results <- s3_get_files(s3_uri = c(
    "s3://geomarker/testing_downloads/mtcars.rds",
    "s3://geomarker/testing_downloads/mtcars_again.rds"
  ), confirm = FALSE, public = TRUE)
  expect_identical(lapply(dl_results$file_path, readRDS), list(mtcars, mtcars))
  unlink(dl_results$file_path)
  })
})

test_that("s3_get_files doesn't download files that already exist", {
  skip_if_offline(host = "r-project.org")
  Sys.setenv("R_USER_DATA_DIR" = tempdir())
  the_files <- s3_get_files(c(
    "s3://geomarker/testing_downloads/mtcars.rds",
    "s3://geomarker/testing_downloads/mtcars_again.rds"
  ), confirm = FALSE)
  expect_message(
    {
      s3_get_files(c(
        "s3://geomarker/testing_downloads/mtcars.rds",
        "s3://geomarker/testing_downloads/mtcars_again.rds"
      ), confirm = FALSE)
    },
    "all files already exist"
  )
  unlink(the_files$file_path)
  })
