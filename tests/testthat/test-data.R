testthat::test_that("response direction and nonresponse are explicit", {
  testthat::expect_equal(support_score(c(1, 3, 5, 8, 9, NA), 5), c(100, 50, 0, NA, NA, NA))
  testthat::expect_equal(support_score(c(1:6, 8), 6), c(100, 80, 60, 40, 20, 0, NA))
  testthat::expect_error(support_score(7, 6), "Unexpected")
  testthat::expect_error(clean_codes(factor(1:3), 1:3))
  testthat::expect_equal(party_pre(1:9), c(
    rep("Democrat", 3), "Nonpartisan", rep("Republican", 3), rep("Nonpartisan", 2)
  ))
  testthat::expect_equal(party_post(c(1, 2, 3, 4, 3, NA), c(99, 99, 1, 2, 3, NA)), c(
    "Democrat", "Republican", "Democrat", "Republican", "Nonpartisan", NA
  ))
})

testthat::test_that("sample accounting distinguishes selection from item nonresponse", {
  d <- read_data(file.path(root, "data/raw/cces2018.csv"))
  testthat::expect_identical(d$row_id, seq_len(1625L))
  testthat::expect_equal(sum(d$matched), 1000L)
  testthat::expect_equal(sum(d$highway_eligible), 1380L)
  testthat::expect_equal(sum(!is.na(d$highway)), 1374L)
  testthat::expect_equal(sum(d$UCMpareto == 9), 245L)
  testthat::expect_equal(sum(d$UCMpareto == 8), 6L)
  testthat::expect_equal(sum(d$income_assigned), 1052L)
  testthat::expect_equal(sum(d$party_post %in% c("Democrat", "Republican")), 911L)
  testthat::expect_equal(sum(!is.na(d$jobs_support)), 1624L)
  testthat::expect_true(all(is.na(d$income_support[!d$income_assigned])))
  testthat::expect_equal(sum(d$matched == 1 & d$income_assigned), 859L)
})

testthat::test_that("income routing follows contemporaneous party including leaners", {
  d <- read_data(file.path(root, "data/raw/cces2018.csv"))
  testthat::expect_equal(
    as.integer(table(d$income_arm[d$party_post %in% "Democrat"])), c(256L, 249L)
  )
  testthat::expect_equal(
    as.integer(table(d$income_arm[d$party_post %in% "Republican"])), c(203L, 203L)
  )
  testthat::expect_equal(sum(d$party_post %in% "Nonpartisan"), 141L)
  testthat::expect_true(any(d$party_pre != d$party_post, na.rm = TRUE))
})

testthat::test_that("public data contain only documented numeric columns", {
  d <- read.csv(file.path(root, "data/raw/cces2018.csv"))
  dictionary <- read.csv(file.path(root, "docs/data_dictionary.csv"))
  testthat::expect_setequal(names(d), c("row_id", "matched", dictionary$variable))
  testthat::expect_true(all(vapply(d, is.numeric, logical(1))))
  testthat::expect_false(any(grepl("caseid|email|ipaddress|zip|starttime|endtime", names(d))))
})
