library(devtools)
library(styler)

name_r <- "new_function"
use_r(name_r)
use_test()
# prompt(get(name_r))

# use_tidy_style()
use_tidy_description()
style_pkg(transformers = tidyverse_style(indent_by = 4))
lintr::lint_package()

document()
check()
install()
build()
BiocCheck::BiocCheck()

build_vignettes()
build_readme()
build_manual()

use_version()
use_news_md()

# use_citation(); use_latest_dependencies(); use_logo(); ; use_cran_comments()

remotes::install_github('yonicd/covrpage')
covrpage::covrpage()
