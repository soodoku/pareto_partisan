# Pareto Party

# Load libs
library(tidyverse)
library(readstata13)
library(car)
library(dplyr)
library(xtable)
library(dplyr)

# Read in data
cces <- readstata13::read.dta13("pareto_partisan/data/CCES18_UCM_unmatched_OUTPUT.dta")

# Expectation
# Republicans rational take the Smith plan 
# Pareto
table(cces$UCMpareto)

table(cces$UCMpareto, cces$pid3)

table(cces$UCMpareto, cces$pid3lean)

table(cces$UCMpareto, cces$pid3)[1:2, 1:3]

cces$pid3_lab  <- car::recode(cces$pid3, "1 = 'Democrat'; 2 = 'Republican'; 3 = 'Independent'; c(4, 5) = NA")
cces$treat_lab <- car::recode(cces$UCMpareto, "1 = 'Smith Plan'; 2 = 'Williams Plan'; c(8, 9) = NA")

prop <- with(cces, table(treat_lab, pid3_lab)) %>% 
  prop.table(margin = 2)

print(xtable(prop),
  floating = FALSE,
  latex.environments = NULL,
  booktabs = TRUE)

# Jobs/Race

cces$jobsn <- car::recode(cces$UCMjobs, "6 = 1; 5 = .8; 4 = .6; 3 = .4; 2 = .2; 1 = 0; else = NA")

cces %>%
	group_by(UCMjobstreat) %>%
	summarize(mean_support = mean(jobsn, na.rm = T))

cces %>%
	group_by(UCMjobstreat, UCMjobsparty) %>%
	summarize(mean_support = mean(jobsn, na.rm = T), n = n())

cces %>%
	filter(race == 1) %>%
	group_by(UCMjobstreat, UCMjobsparty, pid3lean) %>%
	filter(!is.na(pid3lean) & pid3lean != 0) %>%
	summarize(mean_support = mean(jobsn, na.rm = T), n = n()) %>%
	arrange(desc(pid3lean, UCMjobstreat))

# 1 = black
# 2 is white

cces %>%
	filter(race == 1) %>%
	group_by(UCMjobstreat, pid3_lab) %>%
	summarize(mean_support = mean(jobsn, na.rm = T))
