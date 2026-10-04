# Design and interpretation

## Questions and benchmarks

The highway question asks whether people choose larger allocations for both groups when doing so leaves their own side behind. If respondents strictly prefer more for their side, weakly prefer more for the other side, understand the allocations, make no choice errors, and judge no other attributes, **100% should select the larger plan**. Indifference to opponents' gains is sufficient; altruism is unnecessary. A 50% comparison asks which proposal wins a majority and is not the benchmark for universal preference for larger allocations.

This is a conditional prediction about displayed allocations. It is not a demonstration that every person receives higher net welfare. Highway spending requires financing, states contain members of both parties, and individual benefits are unspecified. Departures can reflect relative partisan preferences, fiscal preferences, other attributes, or misunderstanding. A binomial test of exactly 100% is uninformative under an error-free model: one contrary response suffices. Report the departure's magnitude, intervals on the observed share, and alternative explanations.

The income experiment asks whether increasing opponents' stated income gain lowers support while the own-party gain stays fixed. Pure own-group preferences predict no effect. Preferences weakly increasing in both groups' gains predict a nonnegative effect, assuming a stable mapping from evaluations to reported support and no other perceived changes. A negative effect violates this benchmark. Respondents see one assigned plan, so it does not measure the fraction who would choose the higher-gain plan when offered both.

Neither exercise alone separates hostility toward opponents from aversion to being behind. The absolute gap in gains is constant across alternatives, but the group ahead changes. Income levels before the policy are unknown; equal percentage-point gaps do not establish equal income inequality. No politically neutral comparator identifies how much of the response is specifically partisan.

## Highway item

The pre-election questionnaire routes Democrats and Democratic leaners to the blue-state image and Republicans and Republican leaners to the red-state image. Smith allocates $11B to own-party states and $12B to the other side; Williams allocates $10B and $9B. Choosing Williams reduces own-side funding by $1B and other-side funding by $3B, while changing an own-side disadvantage of $1B into an advantage of $1B. These are stimulus properties, not estimated effects.

The questionnaire randomizes response-option order, not exposure to a partisan versus neutral allocation. The delivery has no order indicator. Choice shares are descriptive. The main universe includes independent leaners; direct identifiers are a sensitivity analysis. Skips are excluded from observed shares and included at both possible extremes for completion bounds. Nonpartisans were not asked. Wilson intervals describe binomial uncertainty, not uncertainty arising from the nonprobability sample.

## Income experiment

Post-election identification is `CC18_421a`; independent/other respondents' leaning is `CC18_421b`. Direct Democrats/Republicans retain their party; other respondents leaning Democratic/Republican join that party. This classification exactly reproduces the delivered partisan routing. A pre-election classification would put some respondents in the wrong own-party condition.

| `UCMincrease_treat` | Democratic voters' gain | Republican voters' gain | Partisan route |
| --- | --- | --- | --- |
| 1 | 5% | 3% | Democrat, including leaners |
| 2 | 5% | 7% | Democrat, including leaners |
| 3 | 3% | 5% | Republican, including leaners |
| 4 | 7% | 5% | Republican, including leaners |

The questionnaire instructs random assignment of images. Causal interpretation assumes randomization of the opposing-party gain within these routes, receipt of the assigned image, and no interference. Complete implementation logs and a final routing script are unavailable. Nonpartisans receive these images too, but lack an own-party interpretation; their separate analysis stratifies by the party held at 5%.

All assigned respondents have an observed outcome. Nonparticipants have neither assignment nor outcome and are outside this post-election estimand. Treatment-related item attrition is therefore absent in the delivered data; selection into the post-election wave remains relevant for external validity.

Raw responses 1 (strongly support) through 5 (strongly oppose) become `25 * (5 - response)`. The primary contrast is the 7%-minus-3% opposing-party gain difference, within respondent party. The pooled contrast uses fixed shares of eligible Democrats and Republicans. Positive values mean more support when opponents gain more. Welch–Satterthwaite intervals combine independent cell variances. Binary support and opposition estimates preserve their own units, percentage points.

The full delivered sample is primary. The matched subset, matched team-weighted sample, and strict identifiers change the represented sample and serve as sensitivity analyses. Weighted estimates treat the supplied team weights and party shares as fixed, use HC3 cell variances, and reference a t distribution with respondents minus cells degrees of freedom. There is no separate post-election team weight, so these weights do not establish nationally representative post-election effects.

The principal experimental estimate is pooled support on the 0–100 scale. Party heterogeneity, binary responses, identity restrictions, nonpartisans, and the jobs item are secondary/exploratory; confidence intervals are unadjusted for those comparisons. There is no preregistration. Balance, permutation, and single-case deletion diagnostics are reported without using balance tests to choose a regression specification.

## Separate jobs vignette

`UCMjobstreat=1` describes a 7% income gain for an average Black family initially making $50,000 and a 5% gain for an average White family with the same starting income; arm 2 reverses the gains. Candidate party follows pre-election partisan identity; it is not separately randomized for partisans. The outcome runs from extremely likely to vote (1) to extremely unlikely (6), coded `20 * (6 - response)`.

The contrast is Black-advantage minus White-advantage. Both groups' gains change, so for Black and White respondents this does not hold own-racial-group gains fixed. It also uses a candidate-vote outcome rather than policy support. It is reported separately in the appendix. The questionnaire's White-advantage text calls the 5% beneficiary an “average white black family”; without the deployed script this ambiguity cannot be resolved. Race and party subgroup intervals are exploratory and overlapping.
