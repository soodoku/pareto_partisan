testthat::test_that("party contrasts agree with independent Welch tests", {
  d <- read_data(file.path(root, "data/raw/cces2018.csv"))
  for (party in c("Democrat", "Republican")) {
    z <- d[d$party_post %in% party, ]
    result <- contrast(z, "income_support")
    reference <- t.test(z$income_support[z$high == 1], z$income_support[z$high == 0])
    testthat::expect_equal(result$estimate, unname(diff(rev(reference$estimate))))
    testthat::expect_equal(c(result$low, result$high), as.numeric(reference$conf.int))
    testthat::expect_equal(result$p, reference$p.value)
  }
})

testthat::test_that("standardized estimates agree with saturated regressions", {
  d <- read_data(file.path(root, "data/raw/cces2018.csv"))
  for (weighted in c(FALSE, TRUE)) {
    z <- d[d$party_post %in% c("Democrat", "Republican") & (!weighted | d$matched == 1), ]
    z$party_post <- factor(z$party_post, levels = c("Democrat", "Republican"))
    z$w <- if (weighted) z$teamweight else 1
    fit <- lm(income_support ~ high * party_post, data = z, weights = w)
    share_rep <- sum(z$w[z$party_post == "Republican"]) / sum(z$w)
    vector <- c(0, 1, 0, share_rep)
    expected <- sum(vector * coef(fit))
    covariance <- sandwich::vcovHC(fit, type = if (weighted) "HC3" else "HC2")
    expected_se <- sqrt(drop(t(vector) %*% covariance %*% vector))
    got <- contrast(z, "income_support", weighted = weighted)
    testthat::expect_equal(got$estimate, expected)
    testthat::expect_equal(got$se, expected_se)
  }
})

testthat::test_that("highway counts reproduce both identity definitions", {
  d <- read_data(file.path(root, "data/raw/cces2018.csv"))
  testthat::expect_equal(sum(d$highway == 2 & d$party_pre == "Democrat", na.rm = TRUE), 499L)
  testthat::expect_equal(sum(d$highway == 2 & d$party_pre == "Republican", na.rm = TRUE), 442L)
  z <- d[d$strict_pre == "Democrat", ]
  testthat::expect_equal(mean(z$highway == 1, na.rm = TRUE), 207 / 621)
  z <- d[d$strict_pre == "Republican", ]
  testthat::expect_equal(mean(z$highway == 1, na.rm = TRUE), 117 / 447)
  result <- proportion_summary(c(rep(TRUE, 499), rep(FALSE, 269)))
  reference <- prop.test(499, 768, correct = FALSE)
  testthat::expect_equal(c(result$low, result$high) / 100, as.numeric(reference$conf.int))
})

testthat::test_that("weighted cell variances match HC3 and reject invalid weights", {
  x <- c(0, 0, 25, 50, 100, NA)
  weights <- c(1, 2, 3, 1, 2, 10)
  fit <- lm(x ~ 1, weights = weights)
  cell <- mean_cell(x, weights)
  testthat::expect_equal(cell$mean, unname(coef(fit)))
  testthat::expect_equal(cell$variance, unname(sandwich::vcovHC(fit, type = "HC3")[1, 1]))
  testthat::expect_equal(cell$n, 5L)
  testthat::expect_error(mean_cell(x, c(0, weights[-1])))
  testthat::expect_error(mean_cell(c(NA, 1)), "At least two")
})

testthat::test_that("case deletion holds the standardization shares fixed", {
  d <- read_data(file.path(root, "data/raw/cces2018.csv"))
  z <- d[d$party_post %in% c("Democrat", "Republican"), ]
  shares <- prop.table(table(z$party_post))
  reference <- vapply(seq_len(nrow(z)), function(i) {
    a <- z[-i, ]
    sum(vapply(names(shares), function(p) {
      y <- a[a$party_post == p, ]
      shares[p] * (mean(y$income_support[y$high == 1]) - mean(y$income_support[y$high == 0]))
    }, numeric(1)))
  }, numeric(1))
  got <- influence_range(z, "income_support")
  testthat::expect_equal(c(got$deletion_min, got$deletion_max), range(reference))
})

testthat::test_that("permutations are reproducible and include the observed assignment", {
  z <- data.frame(
    party_post = rep(c("Democrat", "Republican"), each = 10),
    high = rep(rep(0:1, each = 5), 2), income_support = rep(c(rep(100, 5), rep(0, 5)), 2)
  )
  first <- permutation_check(z, "income_support", draws = 99, seed = 5)
  second <- permutation_check(z, "income_support", draws = 99, seed = 5)
  testthat::expect_equal(first, second)
  testthat::expect_gte(first$p, 0.01)
})

testthat::test_that("the stratified interval recovers a planted effect", {
  set.seed(6148)
  estimates <- replicate(300, {
    z <- data.frame(
      party_post = rep(c("Democrat", "Republican"), each = 120),
      high = rep(rep(0:1, each = 60), 2)
    )
    z$income_support <- 60 - 20 * z$high + rnorm(240, sd = 20)
    r <- contrast(z, "income_support")
    c(estimate = r$estimate, covered = r$low <= -20 & r$high >= -20)
  })
  testthat::expect_lt(abs(mean(estimates["estimate", ]) + 20), 0.6)
  testthat::expect_gt(mean(estimates["covered", ]), 0.90)
  testthat::expect_lt(mean(estimates["covered", ]), 0.99)
})
