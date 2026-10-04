# Validation and scope

## Data integrity

The export verifies unique original respondent keys, complete matched-to-full joins, exact agreement of retained fields, expected delivery dimensions, and weight availability. Numeric public fields are allowlisted. A separate mechanical data sweep checks missingness, types, unique identifiers, duplicate rows, ranges, constants, and category frequencies. Structural nonresponse is distinguished from skipped and system-missing responses.

Every income-assigned respondent has an outcome; the assigned set matches post-election participation. Updated party identity matches all partisan income routes. Highway nonpartisans have the not-asked code. Six eligible respondents skipped highway choice; completion bounds put them all in each alternative in turn. Jobs has one skip; it is excluded before computing cell means, variances, and counts.

## Estimation

Tests compare party-specific contrasts with independent Welch t tests. Pooled contrasts reproduce saturated cell regressions using independently constructed contrast vectors and HC2 covariance matrices; weighted versions reproduce WLS and HC3. Wilson intervals reproduce an independent score-interval calculation. Endpoint tests verify that support and vote likelihood run in the intended direction. Tests also cover unexpected codes, invalid weights, known-effect simulations, deterministic permutations, and exact case-deletion calculations.

The principal interval uses four independent respondent cells. No repeated-observation or geographic clustering unit is implied by the design. Treatments are assigned to respondents, not states. The weights and standardization shares are treated as fixed. The analysis does not claim to estimate uncertainty from weight estimation, online sample selection, or choosing particular stimuli.

Robustness covers full versus matched samples, supplied team weights, inclusion versus exclusion of leaners, binary responses, within-party permutations, and single-case deletions. These checks do not repair unknown assignment execution or establish national representativeness. There is no outcome-dependent trimming or selection of covariates based on balance significance.

## Claims

The highway result is descriptive. A 100% larger-allocation benchmark follows from monotonic preferences over the displayed benefits plus comprehension, error-free choice, and no other relevant differences. No test against exactly 100% is reported because this degenerate null makes any contrary answer impossible. Its value is as an explicit behavioral prediction; the observed departure does not uniquely measure spite. A 50% test would address majority choice instead.

The income treatment effect is conditional on the recorded randomization having operated within the delivered partisan routes. Pure own-group preferences predict zero effect; monotonic preferences over both groups' gains predict no decline. Interpreting a negative effect as a departure also assumes respondents accept the descriptions and that other perceived policy attributes do not change. There is no neutral-beneficiary arm or independent variation of opponent gains and relative rank.

Subgroup findings and secondary outcomes are exploratory, with unadjusted intervals. Party membership is not randomized. Differences in significance are never treated as significant differences; the Democrat-minus-Republican comparison uses a direct four-cell contrast. The race-and-jobs exercise has a different estimand and an unresolved questionnaire wording ambiguity.

## Reproducibility and presentation

`make check` runs the complete local build and verification. All headline estimates are generated as LaTeX macros and README substitutions from CSV results. Table bodies are generated, and static numerals specify stimulus amounts, scale endpoints, theoretical benchmarks, dates, or fixed analysis settings. The [claim ledger](claims.csv) maps statements to outputs; the [citation ledger](citations.csv) records source verification. The compiled paper is checked for unresolved references and visually reviewed page by page.

The repository contains no causal panel model, instrumental-variable design, regression discontinuity, prediction model, text-as-data model, generated-regressor procedure, or structural welfare estimator; checks specific to those methods are inapplicable. The live questions are randomization, sample definition, coding direction, independent-cell uncertainty, interpretation of hypothetical group benefits, and the limits of welfare and mechanism claims.

## Mechanical audit adjudications

The missingness sweep flags variation in post-election participation by pre-election party and by the earlier jobs arm. These are selection into a later wave, not missing outcomes after income assignment. The income estimand is explicitly restricted to the participants assigned in that wave. Missing team weights mark unmatched respondents; missing pre-election leaning fields follow questionnaire routing and do not enter the primary party definition. Category codes are not continuous variables whose numeric skew requires a transformation. The right-skewed supplied weights are handled by weighted sensitivity estimates and effective sample sizes.

The numeral-provenance sweep finds no scoped near-miss. Its orphan flags are stimulus dollar amounts, theoretical/scale endpoints, fixed permutation settings, and LaTeX dimensions; it also parses minus signs in hyphenated contrasts and formula coefficients as numbers. Every estimated manuscript value is a generated macro or table fragment. The jobs CSV and TeX share a basename, so the generic scanner cannot choose between them; the table generator and direct output comparison establish their common source.
