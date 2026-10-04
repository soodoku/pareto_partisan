source("R/data.R")
d <- read_data()
highway <- read.csv("tabs/highway.csv")
income <- read.csv("tabs/income_effects.csv")
primary <- read.csv("tabs/primary.csv")
flow <- read.csv("tabs/sample_flow.csv")
macros <- new.env(parent = emptyenv())
fmt <- function(x, digits = 1) formatC(x, digits = digits, format = "f")
count <- function(x) format(x, big.mark = ",", scientific = FALSE, trim = TRUE)
add <- function(name, value) assign(name, as.character(value), envir = macros)
ci <- function(x) paste0("[", fmt(x$low), ", ", fmt(x$high), "]")
result <- function(name, x) {
  stopifnot(nrow(x) == 1)
  add(paste0(name, "Estimate"), fmt(x$estimate))
  add(paste0(name, "CI"), ci(x))
  add(paste0(name, "N"), count(x$n))
  if ("baseline" %in% names(x)) {
    add(paste0(name, "Baseline"), fmt(x$baseline))
    add(paste0(name, "Treated"), fmt(x$treated))
  }
}
flow_names <- c(
  "FullN", "MatchedN", "HighwayN", "HighwayObserved", "HighwayMissing", "PostN",
  "IncomeN", "NonpartisanN", "IncomeMatchedN", "DemN", "RepN"
)
for (i in seq_along(flow_names)) add(flow_names[i], count(flow$n[i]))
for (party in c("Pooled", "Democrat", "Republican")) {
  prefix <- c(Pooled = "Pool", Democrat = "Dem", Republican = "Rep")[[party]]
  h <- highway[
    highway$sample == "Full" & highway$identity == "Including leaners" &
      highway$party == party,
  ]
  result(paste0("Highway", prefix), h)
  add(paste0("Highway", prefix, "Larger"), fmt(100 - h$estimate))
  add(paste0("Highway", prefix, "Count"), count(h$successes))
  add(paste0("Highway", prefix, "Bounds"), paste0(
    "[", fmt(h$bound_low), ", ", fmt(h$bound_high), "]"
  ))
  result(paste0("Income", prefix), primary[
    primary$party == party & primary$outcome == "income_support",
  ])
}
result("Favor", subset(primary, party == "Pooled" & outcome == "income_favor"))
result("Oppose", subset(primary, party == "Pooled" & outcome == "income_oppose"))
result("PartyDifference", read.csv("tabs/party_effect_difference.csv"))
result("Nonpartisan", read.csv("tabs/nonpartisans.csv"))
result("IncomeWeighted", subset(
  income,
  sample == "Matched weighted" &
    party == "Pooled" & identity == "Including leaners" & outcome == "income_support"
))
result("IncomeMatched", subset(
  income,
  sample == "Matched" & party == "Pooled" &
    identity == "Including leaners" & outcome == "income_support"
))
result("IncomeStrict", subset(
  income,
  sample == "Full" & party == "Pooled" &
    identity == "Strict identifiers" & outcome == "income_support"
))
add("PostRate", fmt(100 * sum(d$income_assigned) / nrow(d)))
add("MatchedPostN", count(sum(d$matched == 1 & d$income_assigned)))
add("IncomeUnobserved", count(sum(d$income_assigned & is.na(d$income_support))))
add("PrePostChangeN", count(sum(d$party_pre != d$party_post, na.rm = TRUE)))
add("PermutationP", fmt(read.csv("tabs/permutation.csv")$p, 4))
a <- read.csv("tabs/influence.csv")
add("DeletionRange", paste0("[", fmt(a$deletion_min, 2), ", ", fmt(a$deletion_max, 2), "]"))
add("JobsMissing", count(sum(is.na(d$jobs_support))))
jobs <- read.csv("tabs/jobs.csv")
for (g in c("All", "White", "Black")) {
  result(paste0("Jobs", g), subset(
    jobs, sample == "Full" & group == g
  ))
}
macros <- as.list(macros)
writeLines(vapply(sort(names(macros)), function(n) {
  paste0("\\newcommand{\\", n, "}{", macros[[n]], "}")
}, character(1)), "tabs/macros.tex")

row <- function(...) paste0(paste(c(...), collapse = " & "), " \\\\")
write_table <- function(lines, path, align) {
  writeLines(c(
    paste0("\\begin{tabular}{", align, "}"), "\\toprule", lines,
    "\\bottomrule", "\\end{tabular}"
  ), file.path("tabs", paste0(path, ".tex")))
}
lines <- c(row("Respondents", "Larger plan / answered", "Percent [95\\% CI]"), "\\midrule")
for (party in c("Democrat", "Republican", "Pooled")) {
  r <- highway[
    highway$sample == "Full" & highway$identity == "Including leaners" &
      highway$party == party,
  ]
  lines <- c(lines, row(
    paste0(party, if (party == "Pooled") "" else "s"),
    paste0(r$n - r$successes, "/", r$n),
    paste(fmt(100 - r$estimate), ci(data.frame(low = 100 - r$high, high = 100 - r$low)))
  ))
}
write_table(lines, "highway_primary", "lrr")

lines <- c(
  row("Respondents", "Opposition 3\\%", "Opposition 7\\%", "Difference [95\\% CI]", "$n$"),
  "\\midrule"
)
for (party in c("Democrat", "Republican", "Pooled")) {
  r <- primary[primary$party == party & primary$outcome == "income_support", ]
  lines <- c(lines, row(
    paste0(party, if (party == "Pooled") "" else "s"),
    fmt(r$baseline), fmt(r$treated), paste(fmt(r$estimate), ci(r)), r$n
  ))
}
write_table(lines, "income_primary", "lrrrr")

lines <- c(row("Sample / identity", "Democrats", "Republicans", "Pooled"), "\\midrule")
for (sample in c("Full", "Matched", "Matched weighted")) {
  for (identity in c("Including leaners", "Strict identifiers")) {
    r <- highway[
      highway$sample == sample & highway$identity == identity,
    ]
    vals <- vapply(c("Democrat", "Republican", "Pooled"), function(p) {
      a <- r[r$party == p, ]
      paste(fmt(a$estimate), ci(a))
    }, character(1))
    lines <- c(lines, row(
      paste(sample, if (identity == "Including leaners") "+ leaners" else "strict"),
      vals[1], vals[2], vals[3]
    ))
  }
}
write_table(lines, "highway_sensitivity", "lrrr")

lines <- c(row("Sample / identity", "Democrats", "Republicans", "Pooled"), "\\midrule")
for (sample in c("Full", "Matched", "Matched weighted")) {
  for (identity in c("Including leaners", "Strict identifiers")) {
    r <- income[
      income$sample == sample & income$identity == identity &
        income$outcome == "income_support",
    ]
    vals <- vapply(c("Democrat", "Republican", "Pooled"), function(p) {
      a <- r[r$party == p, ]
      paste(fmt(a$estimate), ci(a))
    }, character(1))
    lines <- c(lines, row(
      paste(sample, if (identity == "Including leaners") "+ leaners" else "strict"),
      vals[1], vals[2], vals[3]
    ))
  }
}
write_table(lines, "income_sensitivity", "lrrr")

lines <- c(row("Respondents", "Opposition gain", "Assigned", "Observed"), "\\midrule")
for (party in c("Democrat", "Republican")) {
  for (arm in 0:1) {
    z <- d[d$party_post %in% party & d$high %in% arm, ]
    lines <- c(lines, row(
      paste0(party, "s"), if (arm == 0) "3\\%" else "7\\%",
      nrow(z), sum(!is.na(z$income_support))
    ))
  }
}
write_table(lines, "income_assignment", "lrrr")

lines <- c(
  row("Respondents", "White advantage", "Black advantage", "Difference [95\\% CI]", "$n$"),
  "\\midrule"
)
for (g in c("All", "White", "Black", "Other races", "Democrat", "Republican")) {
  r <- jobs[jobs$sample == "Full" & jobs$group == g, ]
  lines <- c(lines, row(g, fmt(r$baseline), fmt(r$treated), paste(fmt(r$estimate), ci(r)), r$n))
}
write_table(lines, "jobs", "lrrrr")

readme <- readLines("docs/README.md.in")
for (n in names(macros)) readme <- gsub(paste0("@", n, "@"), macros[[n]], readme, fixed = TRUE)
if (any(grepl("@[A-Za-z]+@", readme))) stop("Unresolved README value")
writeLines(readme, "README.md")
