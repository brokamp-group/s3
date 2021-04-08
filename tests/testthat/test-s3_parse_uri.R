test_that("s3_parse_uri works with one folder in URI", {
  expect_equal(
    s3_parse_uri("s3://geomarker/testing_downloads/mtcars.rds"),
    list(
      uri = "s3://geomarker/testing_downloads/mtcars.rds",
      bucket = "geomarker",
      key = "testing_downloads/mtcars.rds",
      folder = "testing_downloads",
      file_name = "mtcars.rds",
      url = "https://geomarker.s3.amazonaws.com/testing_downloads/mtcars.rds"
    )
  )
})

test_that("s3_parse_uri works with multiple folders in URI", {
  expect_equal(
    s3_parse_uri("s3://geomarker/here/is/a/deep/folder/mtcars.rds"),
    list(
      uri = "s3://geomarker/here/is/a/deep/folder/mtcars.rds",
      bucket = "geomarker",
      key = "here/is/a/deep/folder/mtcars.rds",
      folder = "here/is/a/deep/folder",
      file_name = "mtcars.rds",
      url = "https://geomarker.s3.amazonaws.com/here/is/a/deep/folder/mtcars.rds"
    )
  )
})

test_that("s3_parse_uri works with no folders in URI", {
  expect_equal(
    s3_parse_uri("s3://geomarker/mtcars.rds"),
    list(
      uri = "s3://geomarker/mtcars.rds",
      bucket = "geomarker",
      key = "mtcars.rds",
      folder = "",
      file_name = "mtcars.rds",
      url = "https://geomarker.s3.amazonaws.com/mtcars.rds"
    )
  )
})

