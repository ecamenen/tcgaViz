#' The application User-Interface
#'
#' @param request Internal parameter for `{shiny}`.
#' @noRd
app_ui <- function(request) {
    tagList(
        golem_add_external_resources(),
        fluidPage(
            shinyFeedback::useShinyFeedback(),
            title = "tcga-Viz",
            h1(toupper("tcga-Viz")),
            tags$p(
                tags$a(
                    href = "https://github.com/ecamenen/tcgaViz",
                    "Etienne CAMENEN,"
                ),
                "Gilles MARODON, Nicolas AUBERT"
            ),
            h4(
                paste(
                    "Differential analysis of tumor tissue immune cell type",
                    "abundance based on RNASeq gene-level expression from The",
                    "Cancer Genome Atlas (TCGA) database."
                )
            ),
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
                            )
                        ),
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
                                choices = format_correction_choices()
                            ),
                            sliderInput(
                                "pval",
                                "P-value threshold",
                                max = 1,
                                min = 0,
                                value = 0.05
                            ),
                            selectInput(
                                "stat",
                                "Cut-off",
                                choices = c("Mean", "Median", "Quantile")
                            )
                        ),
                        tabPanel(
                            "Plot",
                            radioButtons(
                                "type",
                                "Plot",
                                choices = c("Violin", "Boxplot")
                            ),
                            checkboxInput("dots", "Add dots", FALSE),
                            textInput("title", "Main title"),
                            textInput("xlab", "X-axis title"),
                            textInput("ylab", "Y-axis title"),
                            sliderInput(
                                "cex_main",
                                "Size of the main title",
                                max = 40,
                                min = 10,
                                value = 16
                            ),
                            sliderInput(
                                "cex_lab",
                                "Size of the axis titles",
                                max = 40,
                                min = 10,
                                value = 12
                            )
                        )
                    )
                ),
                mainPanel(
                    tabsetPanel(
                        type = "tabs",
                        id = "navbar",
                        tabPanel(
                            "Distribution plot",
                            plotOutput("distribution_plot", height = 700),
                            downloadButton("download_distribution")
                        ),
                        tabPanel(
                            "Statistic summary",
                            DT::dataTableOutput("stats_summary"),
                            downloadButton("download_stats")
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
