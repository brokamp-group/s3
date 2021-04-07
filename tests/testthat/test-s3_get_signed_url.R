test_that("creating signed url works", {
  skip_if_offline(host = "r-project.org")
  expect_type(
    s3_get_signed_url("s3://geomarker/testing_downloads/mtcars_private.rds"),
    "character"
  )
})
