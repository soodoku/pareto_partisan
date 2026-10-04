clean_codes <- function(x, valid, missing = numeric()) {
  stopifnot(is.numeric(x))
  if (any(!is.na(x) & !x %in% c(valid, missing))) stop("Unexpected response code")
  x[x %in% missing] <- NA_real_
  x
}

party_pre <- function(pid7) {
  pid7 <- clean_codes(pid7, 1:9, c(98, 99))
  out <- rep("Nonpartisan", length(pid7))
  out[pid7 %in% 1:3] <- "Democrat"
  out[pid7 %in% 5:7] <- "Republican"
  out[is.na(pid7)] <- NA_character_
  out
}

party_post <- function(pid3, lean) {
  pid3 <- clean_codes(pid3, 1:4, c(8, 9, -1))
  lean <- clean_codes(lean, c(1:3, 8), c(98, 99, -1))
  out <- rep("Nonpartisan", length(pid3))
  out[pid3 %in% 1 | (!pid3 %in% 1:2 & lean %in% 1)] <- "Democrat"
  out[pid3 %in% 2 | (!pid3 %in% 1:2 & lean %in% 2)] <- "Republican"
  out[is.na(pid3)] <- NA_character_
  out
}

support_score <- function(x, categories) {
  x <- clean_codes(x, seq_len(categories), c(8, 9, -1))
  100 * (categories - x) / (categories - 1)
}

read_data <- function(path = "data/raw/cces2018.csv") {
  d <- read.csv(path, na.strings = "")
  stopifnot(nrow(d) == 1625L, !anyDuplicated(d$row_id))
  stopifnot(all(d$matched %in% 0:1), sum(d$matched) == 1000L)
  stopifnot(all(is.na(d$teamweight) == (d$matched == 0)))
  stopifnot(all(d$teamweight[d$matched == 1] > 0))
  d$party_pre <- party_pre(d$pid7)
  d$party_post <- party_post(d$CC18_421a, d$CC18_421b)
  d$strict_pre <- ifelse(d$pid3 %in% 1, "Democrat", ifelse(
    d$pid3 %in% 2, "Republican", "Nonpartisan"
  ))
  d$strict_post <- ifelse(d$CC18_421a %in% 1, "Democrat", ifelse(
    d$CC18_421a %in% 2, "Republican", "Nonpartisan"
  ))
  d$highway <- clean_codes(d$UCMpareto, 1:2, c(8, 9))
  d$lower_plan <- 100 * (d$highway == 2)
  d$highway_eligible <- d$party_pre %in% c("Democrat", "Republican")
  stopifnot(all(d$UCMpareto[!d$highway_eligible] == 9))
  stopifnot(all(d$UCMpareto[d$highway_eligible] %in% c(1, 2, 8)))
  d$income_arm <- clean_codes(d$UCMincrease_treat, 1:4, c(8, 9, -1))
  d$income_support <- support_score(d$UCMincrease, 5)
  d$income_assigned <- !is.na(d$income_arm)
  d$reference_party <- ifelse(d$income_arm <= 2, "Democrat", "Republican")
  d$high <- as.integer(d$income_arm %in% c(2, 4))
  d$high[!d$income_assigned] <- NA_integer_
  d$income_favor <- ifelse(is.na(d$income_support), NA_real_, 100 * (d$UCMincrease <= 2))
  d$income_oppose <- ifelse(is.na(d$income_support), NA_real_, 100 * (d$UCMincrease >= 4))
  partisan <- d$party_post %in% c("Democrat", "Republican")
  stopifnot(all(d$reference_party[partisan] == d$party_post[partisan]))
  stopifnot(all(d$income_assigned == (d$tookpost == 2)))
  stopifnot(all(d$income_assigned == !is.na(d$income_support)))
  d$jobs_support <- support_score(d$UCMjobs, 6)
  d$jobs_black <- clean_codes(d$UCMjobstreat, 1:2, c(8, 9)) == 1
  d
}
