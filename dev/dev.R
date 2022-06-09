library(devtools)
library(styler)

name_r <- "new_function"
use_r(name_r)
use_test()
# prompt(get(name_r))

# use_tidy_style()
use_tidy_description()
style_pkg(
    transformers = tidyverse_style(indent_by = 4),
    exclude_files = c(
        "R/app_config.R",
        "R/run_app.R",
        "tests/testthat/test-golem-recommended.R"
    )
  )
lintr::lint_package()

document()
build(path = ".")
install(upgrade = "never")
build_vignettes()
build_readme()
check()
BiocCheck::BiocCheck(paste0(get_golem_name(), "_", get_golem_version(), ".tar.gz"))

build_manual()

use_version()
use_news_md()

# use_citation(); use_latest_dependencies(); use_logo(); ; use_cran_comments()

remotes::install_github('yonicd/covrpage')
covrpage::covrpage()
