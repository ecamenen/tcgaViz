library(devtools)

name <- "tcgaViz"
available::available(name)
path <- paste0("~/bin/", name)
if (!file.exists(path)) {
    dir.create(file.path(path))
}
setwd(path)
use_git()
use_github()
create_project(path)
create_package(path)
use_description(
    fields = list(
        Title = "Vizualisation tool for The Cancer Genome Atlas Program (TCGA)",
        `Authors@R` = c(
            person("Etienne", "Camenen", email = "etienne.camenen@gmail.com", role = c("aut", "cre")),
            person("Gilles", "Marodon", role = "aut"),
            person("Nicolas", "Petit", role = "aut")
        ),
        Description = "A visualization tool to depict proportions of immune cells in any tumor relative to the average expression of any gene (or signature).",
        License = "GPL-3",
        Version = "0.1.0"
    )
)
use_readme_rmd()
use_cran_badge()
use_github_actions_badge()
use_package_doc()
# promptPackage(name)
for (f in c(".idea/", "dev/", "inst/extdata/")) {
    use_git_ignore(f)
    use_build_ignore(f)
}
# use_vignette("Tutorial")
use_testthat()
use_spell_check()
for (p in c(
    "openxlsx",
    "dplyr",
    "ggplot2",
    "reshape2",
    "readr",
    "data.table",
    "ggpubr",
    "rstatix"
)) {
    use_package(p)
}
