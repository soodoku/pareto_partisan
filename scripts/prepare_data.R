args <- commandArgs(trailingOnly = TRUE)
if (length(args) != 1) stop("Supply the directory containing the original survey deliveries")
source_dir <- args[1]
paths <- file.path(source_dir, c(
  "CCES18_UCM_unmatched_OUTPUT.sav", "CCES18_UCM_OUTPUT.sav"
))
full <- haven::read_sav(paths[1], user_na = TRUE)
matched <- haven::read_sav(paths[2], user_na = TRUE)
stopifnot(nrow(full) == 1625L, nrow(matched) == 1000L)
stopifnot(!anyDuplicated(full$caseid), !anyDuplicated(matched$caseid))
index <- match(matched$caseid, full$caseid)
stopifnot(!anyNA(index))
columns <- c(
  "teamweight", "tookpost", "birthyr", "gender", "educ", "race", "pid3", "pid7",
  "pid3lean", "CC18_421a", "CC18_421b", "UCMpareto", "UCMincrease_treat",
  "UCMincrease", "UCMjobs", "UCMjobstreat", "UCMjobsparty"
)
for (v in columns) {
  stopifnot(isTRUE(all.equal(as.numeric(full[[v]][index]), as.numeric(matched[[v]]))))
}
public <- data.frame(row_id = seq_len(nrow(full)), matched = as.integer(
  full$caseid %in% matched$caseid
))
for (v in columns) public[[v]] <- as.numeric(full[[v]])
stopifnot(all(is.na(public$teamweight) == (public$matched == 0)))
dir.create("data/raw", recursive = TRUE, showWarnings = FALSE)
write.csv(public, "data/raw/cces2018.csv", row.names = FALSE, na = "")
dictionary <- do.call(rbind, lapply(columns, function(v) {
  labels <- attr(full[[v]], "labels", exact = TRUE)
  label <- attr(full[[v]], "label", exact = TRUE)
  data.frame(
    variable = v, label = if (is.null(label)) "" else label,
    values = if (length(labels)) {
      paste(paste0(unname(labels), "=", names(labels)), collapse = "; ")
    } else {
      ""
    }
  )
}))
write.csv(dictionary, "docs/data_dictionary.csv", row.names = FALSE)
manifest <- data.frame(
  file = basename(paths), rows = c(nrow(full), nrow(matched)),
  columns = c(ncol(full), ncol(matched)),
  sha256 = vapply(paths, digest::digest, character(1), algo = "sha256", file = TRUE)
)
write.csv(manifest, "docs/source_manifest.csv", row.names = FALSE)
