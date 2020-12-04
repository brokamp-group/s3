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
