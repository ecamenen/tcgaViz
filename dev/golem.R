library(golem)
library(reactlog)
library(rsconnect)

create_golem(path)
set_golem_options()
use_recommended_tests()
use_recommended_deps()
remove_favicon()

set_golem_version("1.0.0")

use_utils_ui()
use_utils_server()

shinyAppTemplate(path, "all")

# add_dockerfile()
# add_dockerfile_shinyproxy()

devtools::load_all()
reactlog_enable()
run_dev()
shiny::reactlogShow()

setAccountInfo(
    name = "iconics",
    token = "4A7520766199D4DA0A6527F1E59793E4",
    secret = as.character(secret)
)
add_shinyappsio_file()
# Before doing that, remove BiocCheck and biocViews in DESCRIPTION
deployApp(
    appName = "tcgaViz",
    appTitle = "Vizualisation tool for The Cancer Genome Atlas Program (TCGA)"
)

# Set options here
options(golem.app.prod = FALSE) # TRUE = production mode, FALSE = development mode

# Detach all loaded packages and clean your environment
golem::detach_all_attached()
# rm(list=ls(all.names = TRUE))

# Document and reload your package
golem::document_and_reload()

# Run the application
run_app()
