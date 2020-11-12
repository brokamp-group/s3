test_that("s3_get downloads a public file", {
  skip_if_no_boto()
  skip_if_offline(host = "r-project.org")
  delete_test_download_folder()
  expect_identical(
    readRDS(s3_get("s3://geomarker/testing_downloads/mtcars.rds")),
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

test_that("s3_get_files downloads all files (forcing no user confirmation)", {
  skip_if_no_boto()
  skip_if_offline(host = "r-project.org")
  delete_test_download_folder()
  expect_success({
    s3_get_files(s3_uri = c(
      "s3://geomarker/testing_downloads/mtcars.rds",
      "s3://geomarker/testing_downloads/mtcars.fst"
    ), confirm = FALSE)
  })
  delete_test_download_folder()
})

test_that("s3_get_files downloads larger files with informative progress messages and user confirmation", {
  skip_if_no_boto()
  skip_if_offline(host = "r-project.org")
  skip()

  delete_test_download_folder()
  expect_success({
    s3_get_files(s3_uri = c(
      "s3://geomarker/testing_downloads/zctas_2000_contig_us_5072.rds",
      "s3://geomarker/testing_downloads/county_fips_contig_us_5072.rds"
    ))
  })
  delete_test_download_folder()
})