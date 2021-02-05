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

test_that("s3_get_files correctly handles files that already exist, are private, etc", {
  skip_if_offline(host = "r-project.org")
  delete_test_download_folder()
  withr::with_envvar(new = c(
    "AWS_ACCESS_KEY_ID" = NA,
    "AWS_SECRET_ACCESS_KEY" = NA
  ), {
    s3_get("s3://geomarker/testing_downloads/mtcars.rds")
    expect_identical(
     s3_get_files(c("s3://geomarker/testing_downloads/mtcars.rds",
                     "s3://geomarker/testing_downloads/mtcars_again.rds",
                    "s3://geomarker/testing_downloads/mtcars_private.rds"),
                  confirm = FALSE),
      tibble::tibble(s3_uri = c('s3://geomarker/testing_downloads/mtcars.rds',
                                's3://geomarker/testing_downloads/mtcars_again.rds'),
                     file_path = c(fs::path_wd('/s3_downloads/geomarker/testing_downloads/mtcars.rds'),
                                   fs::path_wd('/s3_downloads//geomarker/testing_downloads/mtcars_again.rds')))
    )
  })
  delete_test_download_folder()
})
