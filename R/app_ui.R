#' The application User-Interface
#'
#' @param request Internal parameter for `{shiny}`.
#' @import shiny
#' @noRd
app_ui <- function(request) {
    tagList(
        golem_add_external_resources(),
        fluidPage(
            h1("tcgaViz"),
            sidebarLayout(
                sidebarPanel(
                    tabsetPanel(
                        id = "tabset",
                        tabPanel(
                            "Data",
                            fileInput("cell_file", label = "Cell file"),
                            fileInput("phenotype_file", label = "Phenotype file"),
                            fileInput("gene_file", label = "Gene file")
                        )
                    )
                ),
                mainPanel(
                    tabsetPanel(
                        type = "tabs",
                        id = "navbar",
                        tabPanel(
                            "Violin plot",
                            plotOutput("violin_plot")
                        )
                    )
                )
            )
        )
    )
}

#' Add external Resources to the Application
#'
#' This function is internally used to add external
#' resources inside the Shiny application.
#'
#' @import shiny
#' @importFrom golem add_resource_path activate_js favicon bundle_resources
#' @noRd
golem_add_external_resources <- function() {
    add_resource_path(
        "www", app_sys("app/www")
    )

    tags$head(
        favicon(),
        bundle_resources(
            path = app_sys("app/www"),
            app_title = "tcgaViz"
        )
    )
}
