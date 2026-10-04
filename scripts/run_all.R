source("R/data.R")
source("R/analysis.R")
dir.create("tabs", showWarnings = FALSE)
save_table <- function(x, name) {
  write.csv(x, file.path("tabs", paste0(name, ".csv")), row.names = FALSE, na = "")
}
d <- read_data()
parties <- c("Democrat", "Republican")
all_income <- d[d$income_assigned, ]
income <- all_income[all_income$party_post %in% parties, ]
flow <- data.frame(
  stage = c(
    "Full delivery", "Matched delivery", "Highway eligible", "Highway observed",
    "Highway missing", "Post-election participants", "Income partisans", "Income nonpartisans",
    "Matched income partisans", "Income Democrats", "Income Republicans"
  ),
  n = c(
    nrow(d), sum(d$matched), sum(d$highway_eligible), sum(!is.na(d$highway)),
    sum(d$highway_eligible & is.na(d$highway)), nrow(all_income), nrow(income),
    sum(all_income$party_post == "Nonpartisan"), sum(income$matched),
    sum(income$party_post == "Democrat"), sum(income$party_post == "Republican")
  )
)
save_table(flow, "sample_flow")

highway <- list()
for (sample in c("Full", "Matched", "Matched weighted")) {
  z <- if (sample == "Full") d else d[d$matched == 1, ]
  for (identity in c("Including leaners", "Strict identifiers")) {
    g <- if (identity == "Including leaners") z$party_pre else z$strict_pre
    for (party in c("Pooled", parties)) {
      keep <- if (party == "Pooled") g %in% parties else g %in% party
      x <- z[keep & z$highway_eligible, ]
      w <- if (sample == "Matched weighted") x$teamweight else NULL
      out <- proportion_summary(x$highway == 2, w)
      weights <- if (is.null(w)) rep(1, nrow(x)) else w
      lower <- sum(weights * (x$highway %in% 2)) / sum(weights)
      upper <- sum(weights * (x$highway %in% 2 | is.na(x$highway))) / sum(weights)
      highway[[length(highway) + 1]] <- cbind(
        sample = sample, identity = identity, party = party, out, assigned = nrow(x),
        missing = sum(is.na(x$highway)), bound_low = 100 * lower, bound_high = 100 * upper
      )
    }
  }
}
highway <- do.call(rbind, highway)
save_table(highway, "highway")

results <- list()
for (sample in c("Full", "Matched", "Matched weighted")) {
  z <- if (sample == "Full") income else income[income$matched == 1, ]
  for (identity in c("Including leaners", "Strict identifiers")) {
    x <- if (identity == "Including leaners") z else z[z$strict_post %in% parties, ]
    for (party in c("Pooled", parties)) {
      a <- if (party == "Pooled") x else x[x$party_post == party, ]
      for (outcome in c("income_support", "income_favor", "income_oppose")) {
        results[[length(results) + 1]] <- cbind(
          sample = sample, identity = identity, party = party, outcome = outcome,
          contrast(a, outcome, weighted = sample == "Matched weighted")
        )
      }
    }
  }
}
results <- do.call(rbind, results)
save_table(results, "income_effects")
primary <- subset(results, sample == "Full" & identity == "Including leaners")
save_table(primary, "primary")

cells <- list()
distributions <- list()
for (party in parties) {
  for (arm in 0:1) {
    x <- income[income$party_post == party & income$high == arm, ]
    cell <- mean_cell(x$income_support)
    cells[[length(cells) + 1]] <- cbind(
      party = party, high = arm, cell,
      low = cell$mean - qt(0.975, cell$n - 1) * sqrt(cell$variance),
      upper = cell$mean + qt(0.975, cell$n - 1) * sqrt(cell$variance)
    )
    for (response in 1:5) {
      distributions[[length(distributions) + 1]] <- data.frame(
        party = party, high = arm, response = response,
        n = sum(x$UCMincrease == response), assigned = nrow(x),
        percent = 100 * mean(x$UCMincrease == response)
      )
    }
  }
}
cells <- do.call(rbind, cells)
save_table(cells, "income_cells")
save_table(do.call(rbind, distributions), "income_distribution")
save_table(linear_summary(cells, c(-1, 1, 1, -1)), "party_effect_difference")

save_table(permutation_check(income, "income_support"), "permutation")
save_table(influence_range(income, "income_support"), "influence")
save_table(
  as.data.frame(with(d, table(party_pre, party_post, useNA = "always"))), "party_transition"
)
save_table(as.data.frame(with(d, table(matched, tookpost))), "completion")
save_table(as.data.frame(with(d, table(CC18_421a, CC18_421b, income_arm))), "income_routing")

nonpartisans <- all_income[all_income$party_post == "Nonpartisan", ]
save_table(contrast(nonpartisans, "income_support", group = "reference_party"), "nonpartisans")

balance <- list()
for (v in c("birthyr", "gender", "educ", "race", "lower_plan")) {
  values <- income[[v]]
  if (v %in% c("gender", "educ", "race")) {
    codes <- sort(unique(values[!is.na(values)]))
  } else {
    codes <- NA_real_
  }
  for (code in codes) {
    z <- income
    label <- if (is.na(code)) v else paste(v, code, sep = "=")
    z$balance_value <- if (is.na(code)) values else 100 * (values == code)
    balance[[length(balance) + 1]] <- cbind(
      variable = label, contrast(z, "balance_value")
    )
  }
}
save_table(do.call(rbind, balance), "balance")

jobs <- list()
for (sample in c("Full", "Matched", "Matched weighted")) {
  z <- if (sample == "Full") d else d[d$matched == 1, ]
  for (group in c("All", "White", "Black", "Other races", parties)) {
    keep <- switch(group,
      All = rep(TRUE, nrow(z)),
      White = z$race == 1,
      Black = z$race == 2,
      `Other races` = !z$race %in% 1:2,
      z$party_pre == group
    )
    x <- z[which(keep), ]
    x$high <- as.integer(x$jobs_black)
    x$stratum <- "All"
    jobs[[length(jobs) + 1]] <- cbind(
      sample = sample, group = group,
      contrast(x, "jobs_support", group = "stratum", weighted = sample == "Matched weighted")
    )
  }
}
save_table(do.call(rbind, jobs), "jobs")
writeLines(trimws(capture.output(sessionInfo()), which = "right"), "tabs/session_info.txt")
print(subset(primary, outcome == "income_support"), row.names = FALSE)
print(subset(highway, sample == "Full" & identity == "Including leaners"), row.names = FALSE)
