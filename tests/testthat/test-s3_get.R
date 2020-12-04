test_that("s3_get downloads a public file without aws credentials", {
  skip_if_no_boto()
  skip_if_no_aws_credentials()
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

test_that("s3_get does not downloads a file if it already exists ", {
  skip_if_no_boto()
  skip_if_offline(host = "r-project.org")
  delete_test_download_folder()
  s3_get("s3://geomarker/testing_downloads/mtcars.rds")
  expect_message(
    s3_get("s3://geomarker/testing_downloads/mtcars.rds"),
    "already exists at"
  )
  delete_test_download_folder()
})

test_that("s3_get_files downloads public files without aws credentials", {
  skip_if_no_boto()
  skip_if_offline(host = "r-project.org")
  delete_test_download_folder()
  withr::with_envvar(new = c(
    "AWS_ACCESS_KEY_ID" = NA,
    "AWS_SECRET_ACCESS_KEY" = NA
  ), {
    expect_identical(
      {
        dl_results <- s3_get_files(c(
          "s3://geomarker/testing_downloads/mtcars.rds",
          "s3://geomarker/testing_downloads/mtcars_again.rds"
        ), confirm = FALSE)
        lapply(dl_results$file_path, readRDS)
      },
      list(mtcars, mtcars)
    )
  })
  delete_test_download_folder()
})