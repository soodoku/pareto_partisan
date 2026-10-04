source("R/style.R")
library(ggplot2)
dir.create("figs", showWarnings = FALSE)
d <- read.csv("tabs/income_effects.csv")
d <- subset(d, identity == "Including leaners" & outcome == "income_support")
d$party <- factor(d$party,
  levels = c("Pooled", "Democrat", "Republican"),
  labels = c("Pooled", "Democrats", "Republicans")
)
d$sample <- factor(d$sample,
  levels = c("Matched weighted", "Matched", "Full"),
  labels = c("Matched, team weighted", "Matched, unweighted", "Full, unweighted")
)
p <- ggplot(d, aes(estimate, sample)) +
  geom_vline(xintercept = 0, linetype = 2, color = "#777777", linewidth = 0.4) +
  geom_errorbar(aes(xmin = low, xmax = high), orientation = "y", width = 0.12) +
  geom_point(color = "#176B75", size = 2.2) +
  facet_wrap(~party, nrow = 1) +
  scale_x_continuous(limits = c(-35, 3), breaks = seq(-30, 0, 10)) +
  labs(x = "Effect of raising opponents' gain from 3% to 7% (0-100 support points)") +
  paper_theme()
save_figure(p, "income_effects", width = 7.2, height = 3.3)

d <- read.csv("tabs/income_distribution.csv")
d$response <- factor(d$response,
  levels = 1:5,
  labels = c(
    "Strongly\nsupport", "Somewhat\nsupport", "Neither",
    "Somewhat\noppose", "Strongly\noppose"
  )
)
d$condition <- factor(d$high,
  levels = 0:1, labels = c("Opposition gains 3%", "Opposition gains 7%")
)
d$party <- factor(d$party,
  levels = c("Democrat", "Republican"), labels = c("Democrats", "Republicans")
)
p <- ggplot(d, aes(response, percent, fill = condition)) +
  geom_col(position = position_dodge(width = 0.8), width = 0.7) +
  facet_wrap(~party, ncol = 1) +
  scale_fill_manual(values = c("#888888", "#176B75"), name = NULL) +
  scale_y_continuous(
    limits = c(0, 50), breaks = seq(0, 50, 10), expand = expansion(mult = c(0, 0.02))
  ) +
  labs(x = NULL, y = "Percent of respondents") +
  paper_theme() +
  theme(
    axis.title.y = element_text(), panel.grid.major.y = element_line(color = "#dddddd"),
    panel.grid.major.x = element_blank()
  )
save_figure(p, "income_distribution", width = 6.5, height = 5.1)
