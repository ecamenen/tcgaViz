#' The application User-Interface
#'
#' @param request Internal parameter for `{shiny}`.
#' @import shiny
#' @noRd
app_ui <- function(request) {
    tagList(
        golem_add_external_resources(),
        fluidPage(
            shinyFeedback::useShinyFeedback(),
            h1("tcgaViz"),
            sidebarLayout(
                sidebarPanel(
                    tabsetPanel(
                        id = "tabset",
                        tabPanel(
                            "Data",
                            selectInput("algorithm", "Algorithm", NULL),
                            selectInput("disease", "Cancer", NULL),
                            selectInput("tissue", "Tissue", NULL),
                            selectizeInput(
                                "gene_x",
                                "Gene",
                                NULL,
                                multiple = FALSE,
                                options = list(
                                    maxItems = 1,
                                    maxOptions = 3,
                                    placeholder = "Select a gene",
                                    mode = "multi"
                                )
                            )),
                        tabPanel(
                            "Statistics",
                            selectInput(
                                "test",
                                "Test",
                                choices = c(
                                    "Student's t-test" = "t_test",
                                    "Wilcoxon-Mann-Whitney test" = "wilcox_test"
                                )
                            ),
                            selectInput(
                                "correction",
                                "Multiple correction",
                                choices = sort(p.adjust.methods)
                            ),
                            selectInput(
                                "stat",
                                "Cut-off",
                                choices = c("mean", "median", "quantile")
                            )),
                        tabPanel(
                            "Plot",
                            radioButtons(
                                "type",
                                "Plot",
                                choices = c("violin", "boxplot")
                            ),
                            checkboxInput("dots", "Add dots", FALSE)
                        ))
                ),
                mainPanel(
                    tabsetPanel(
                        type = "tabs",
                        id = "navbar",
                        tabPanel(
                            "Distribution plot",
                            plotOutput("distribution_plot", height = 700)
                        ),
                        tabPanel(
                            "Statistic summary",
                            DT::dataTableOutput("stats_summary")
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
