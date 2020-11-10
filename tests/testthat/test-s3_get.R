
test_that("s3_get downloads a file", {
  skip_if_no_boto()
  skip_if_offline(host = "r-project.org")

  expect_identical(
    readRDS(s3_get("s3://geomarker/testing_downloads/mtcars.rds")),
    mtcars
  )
})
