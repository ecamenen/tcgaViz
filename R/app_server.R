#' The application server-side
#'
#' @param input,output,session Internal parameters for {shiny}.
#' @import shiny
#' @noRd
app_server <- function(input, output, session) {
    algorithm <- "Cibersort_ABS"
    disease <- "breast invasive carcinoma"
    gene_x <- "A"

    ########## Dataset loading ##########

    vars <- reactiveValues(
        cells = NULL,
        phenotypes = NULL,
        genes = NULL,
        dataset = NULL
    )

    observeEvent(input$cell_file, {
        vars$cells <- read.xlsx(input$cell_file$datapath, sheet = algorithm)
    })

    # Import the phenotypes file
    observeEvent(input$phenotype_file, {
        phenotypes <- read_delim(
            input$phenotype_file$datapath,
            show_col_types = FALSE
        )
        if (!is.null(disease)) {
            vars$phenotypes <- subset(
                phenotypes,
                subset = `_primary_disease` == disease,
                select = "sample"
            )
        }
    })

    # Double the buffer size
    Sys.setenv(VROOM_CONNECTION_SIZE = 131072 * 2)
    # Import the gene file
    observeEvent(input$gene_file, {
        genes <- read_delim(
            input$gene_file$datapath,
            show_col_types = FALSE
        )
        vars$genes <- transpose(
            genes,
            keep.names = "col",
            make.names = "sample"
        )
    })

    # Merge datasets
    observeEvent(c(vars$phenotypes, vars$genes), {
        req(input$phenotype_file)
        req(input$gene_file)
        vars$dataset <- merge(vars$phenotypes, vars$genes, by = 1)
    })

    output$violin_plot <- renderPlot({
        req(input$phenotype_file)
        req(input$gene_file)
        req(input$cell_file)

        # Data formatting
        sub_cutted_melt <- isolate(
            convert_biodata(vars$dataset, vars$cells, gene_x)
        )

        # Plot the cell subtypes according to the gene expression level
        p <- plot_violin(sub_cutted_melt, gene_x)

        # Add corrected Wilcoxon tests
        stats <- calculate_pvalue(sub_cutted_melt)
        p + stat_pvalue_manual(stats, label = "p.adj.signif")
    })

    exportTestValues(vars2 = vars)
}
