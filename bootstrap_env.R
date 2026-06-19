# ============================================================
# bootstrap_env.R  —  Trade Capstone
# Run ONCE to set up the reproducible environment (the renv equivalent
# of `uv venv` + `uv add ...` + `uv lock`).
#
# Run line-by-line the first time so you can verify each step.
# ============================================================

# ---- Step A: install renv itself (goes in the GLOBAL library, like uv) ----
if (!requireNamespace("renv", quietly = TRUE)) {
  install.packages("renv")
}
# VERIFY:
packageVersion("renv")          # should print a version, no error

# ---- Step B: initialize the project-local library (creates renv/ + .Rprofile) ----
# Like `uv venv`. Run from the project root.
renv::init(bare = TRUE)         # bare = don't auto-crawl yet; we install explicitly
# After this, RESTART R if VS Code prompts you. The .Rprofile auto-activates renv.

# ---- Step C: install the project packages INTO the project library ----
# Like `uv add ...`. renv intercepts install.packages and routes here.
renv::install(c(
  "comtradr",
  "dplyr",
  "tidyr",
  "readr",
  "ggplot2",
  "fixest",
  "pROC"
))
# VERIFY each loads:
for (p in c("comtradr","dplyr","tidyr","readr","ggplot2","fixest","pROC")) {
  suppressMessages(library(p, character.only = TRUE))
  message("loaded OK: ", p, " ", as.character(packageVersion(p)))
}

# ---- Step D: write the lockfile (like `uv lock`) ----
renv::snapshot()                # creates/updates renv.lock
# VERIFY: a renv.lock file now exists in the project root.
file.exists("renv.lock")        # should be TRUE

# ============================================================
# DONE. Commit to git:  renv.lock, .Rprofile, renv/activate.R,
#                       .gitignore, scripts/, README.md
# Do NOT commit:        renv/library/, .Renviron, data, outputs
#
# On another machine:   clone, open in R, run renv::restore()
# ============================================================
