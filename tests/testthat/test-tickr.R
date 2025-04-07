# setup ----
library(ggplot2)

df <- data.frame(year = 2000:2020,
                  value = rnorm(21,100, 0.25))

plot <- df %>%
  ggplot(aes(year, value)) +
  geom_point()


# test tickr function ----
test_that('tickr is functional', {
  expect_s3_class(tickr(df, var=year), 'data.frame')
  expect_s3_class(tickr(df, var=year, by=2), 'data.frame')
  expect_s3_class(tickr(df, var=year, by=5, var_min = 1998, var_max = 2024, lab_start = 1998, lab_end = 2017), 'data.frame')
})

test_that('scale_x_tickr returns a ggplot',{
  expect_s3_class(plot + scale_x_tickr(data=df, var=year), 'gg')
})

test_that('scale_y_tickr returns a ggplot',{
  expect_s3_class(plot + scale_y_tickr(data=df, var=value), 'gg')
})
