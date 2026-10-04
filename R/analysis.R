mean_cell <- function(x, weights = NULL) {
  observed <- !is.na(x)
  if (!is.null(weights)) {
    stopifnot(length(weights) == length(x), all(is.finite(weights)), all(weights > 0))
  }
  x <- x[observed]
  n <- length(x)
  if (n < 2) stop("At least two observed outcomes are required")
  if (is.null(weights)) {
    mu <- mean(x)
    variance <- var(x) / n
    effective_n <- n
  } else {
    w <- weights[observed]
    h <- w / sum(w)
    mu <- sum(h * x)
    variance <- sum((h * (x - mu) / (1 - h))^2)
    effective_n <- 1 / sum(h^2)
  }
  data.frame(mean = mu, variance = variance, n = n, effective_n = effective_n)
}

linear_summary <- function(cells, coefficients, weighted = FALSE) {
  stopifnot(nrow(cells) == length(coefficients))
  estimate <- sum(coefficients * cells$mean)
  terms <- coefficients^2 * cells$variance
  se <- sqrt(sum(terms))
  df <- if (weighted) {
    sum(cells$n) - nrow(cells)
  } else {
    sum(terms)^2 / sum(terms^2 / (cells$n - 1))
  }
  if (se == 0) df <- sum(cells$n) - nrow(cells)
  critical <- qt(0.975, df)
  data.frame(
    estimate = estimate, se = se, df = df, low = estimate - critical * se,
    high = estimate + critical * se, p = if (se > 0) {
      2 * pt(-abs(estimate / se), df)
    } else {
      as.numeric(estimate == 0)
    },
    n = sum(cells$n)
  )
}

contrast <- function(d, outcome, group = "party_post", weighted = FALSE) {
  stopifnot(nrow(d) > 0, !anyNA(d[[group]]), all(d$high %in% 0:1))
  groups <- sort(unique(d[[group]]))
  weights <- if (weighted) d$teamweight else rep(1, nrow(d))
  stopifnot(all(is.finite(weights)), all(weights > 0))
  shares <- tapply(weights, d[[group]], sum) / sum(weights)
  cells <- list()
  coefficients <- numeric()
  for (g in groups) {
    for (arm in 0:1) {
      sel <- d[[group]] == g & d$high == arm
      cells[[length(cells) + 1]] <- mean_cell(d[[outcome]][sel], if (weighted) weights[sel])
      coefficients <- c(coefficients, shares[g] * if (arm == 1) 1 else -1)
    }
  }
  cells <- do.call(rbind, cells)
  ans <- linear_summary(cells, coefficients, weighted)
  ans$baseline <- sum(cells$mean[seq(1, nrow(cells), 2)] * shares[groups])
  ans$treated <- ans$baseline + ans$estimate
  ans$eligible <- nrow(d)
  ans
}

proportion_summary <- function(x, weights = NULL) {
  cell <- mean_cell(100 * x, weights)
  if (is.null(weights)) {
    p <- mean(x, na.rm = TRUE)
    z <- qnorm(0.975)
    center <- (p + z^2 / (2 * cell$n)) / (1 + z^2 / cell$n)
    half <- z * sqrt(p * (1 - p) / cell$n + z^2 / (4 * cell$n^2)) /
      (1 + z^2 / cell$n)
    low <- 100 * (center - half)
    high <- 100 * (center + half)
  } else {
    critical <- qt(0.975, cell$n - 1)
    low <- max(0, cell$mean - critical * sqrt(cell$variance))
    high <- min(100, cell$mean + critical * sqrt(cell$variance))
  }
  data.frame(
    estimate = cell$mean, low = low, high = high, n = cell$n,
    successes = sum(x, na.rm = TRUE), effective_n = cell$effective_n
  )
}

permutation_check <- function(d, outcome, draws = 9999L, seed = 20261004L) {
  set.seed(seed)
  observed <- contrast(d, outcome)$estimate
  groups <- split(seq_len(nrow(d)), d$party_post)
  shares <- lengths(groups) / nrow(d)
  simulated <- replicate(draws, sum(vapply(seq_along(groups), function(j) {
    ix <- groups[[j]]
    high <- sample(d$high[ix])
    shares[j] * (mean(d[[outcome]][ix][high == 1]) - mean(d[[outcome]][ix][high == 0]))
  }, numeric(1))))
  data.frame(
    estimate = observed, draws = draws, seed = seed,
    p = (1 + sum(abs(simulated) >= abs(observed) - 1e-12)) / (draws + 1)
  )
}

influence_range <- function(d, outcome) {
  shares <- prop.table(table(d$party_post))
  full <- contrast(d, outcome)$estimate
  shifts <- numeric(nrow(d))
  for (g in names(shares)) {
    for (arm in 0:1) {
      ix <- which(d$party_post == g & d$high == arm)
      x <- d[[outcome]][ix]
      shifts[ix] <- shares[g] * (if (arm == 1) 1 else -1) * (mean(x) - x) / (length(x) - 1)
    }
  }
  data.frame(estimate = full, deletion_min = min(full + shifts), deletion_max = max(full + shifts))
}
