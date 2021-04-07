test_that("s3_get_files downloads public files", {
  skip_if_offline(host = "r-project.org")
  delete_test_download_folder()
  expect_identical({
      dl_results <- s3_get_files(s3_uri = c(
        "s3://geomarker/testing_downloads/mtcars.rds",
        "s3://geomarker/testing_downloads/mtcars_again.rds"
      ), confirm = FALSE)
      lapply(dl_results$file_path, readRDS)
    },
    list(mtcars, mtcars)
  )
  delete_test_download_folder()
})

test_that("s3_get_files downloads private files", {
  skip_if_offline(host = "r-project.org")
  skip_if_no_aws_credentials()
  delete_test_download_folder()
    expect_identical({
        dl_results <- s3_get_files(c(
          "s3://geomarker/testing_downloads/mtcars_private.rds",
          "s3://geomarker/testing_downloads/mtcars_private.rds"
        ), confirm = FALSE)
        lapply(dl_results$file_path, readRDS)
      },
      list(mtcars, mtcars)
    )
  delete_test_download_folder()
})

test_that("s3_get_files downloads public files without aws credentials", {
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

test_that("s3_get_files downloads public files overriding credentials", {
  skip_if_offline(host = "r-project.org")
  delete_test_download_folder()
  withr::with_envvar(new = c(
    "AWS_ACCESS_KEY_ID" = "thisisfake",
    "AWS_SECRET_ACCESS_KEY" = "thisisfaketoo"
  ), {
    expect_identical(
      {
        dl_results <- s3_get_files(c(
          "s3://geomarker/testing_downloads/mtcars.rds",
          "s3://geomarker/testing_downloads/mtcars_again.rds"
        ), confirm = FALSE, public = TRUE)
        lapply(dl_results$file_path, readRDS)
      },
      list(mtcars, mtcars)
    )
  })
  delete_test_download_folder()
})

test_that("s3_get_files doesn't download files that already exist", {
  skip_if_offline(host = "r-project.org")
  delete_test_download_folder()
  s3_get_files(c(
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
  delete_test_download_folder()
  })

test_that("s3_get_files downloads public files in bucket's root folder", {
  skip_if_offline(host = "r-project.org")
  delete_test_download_folder()
  expect_identical({
      dl_results <- s3_get_files(s3_uri = c(
        "s3://geomarker/mtcars.rds",
        "s3://geomarker/mtcars_again.rds"
      ), confirm = FALSE)
      lapply(dl_results$file_path, readRDS)
    },
    list(mtcars, mtcars)
  )
  delete_test_download_folder()
})
