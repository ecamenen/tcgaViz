#' The application server-side
#'
#' @param input,output,session Internal parameters for {shiny}.
#' @import shiny
#' @noRd
app_server <- function(input, output, session) {

    ########## Dataset loading ##########

    vars <- reactiveValues(
        cells = NULL,
        phenotypes = NULL,
        genes = NULL,
        dataset = NULL
    )

    observeEvent(input$cell_file, {
        vars$cells <- read.xlsx(input$cell_file$datapath)
        freezeReactiveValue(input, "algorithm")
        updateSelectInput(
            inputId = "algorithm",
            choices = sort(openxlsx::getSheetNames(input$cell_file$datapath))
        )
    })

    observeEvent(input$algorithm, {
        req(input$cell_file)
        vars$cells <- read.xlsx(
            input$cell_file$datapath,
            sheet = input$algorithm
        )
    })

    # Import the phenotypes file
    observeEvent(input$phenotype_file, {
        vars$phenotypes <- read_delim(
            input$phenotype_file$datapath,
            show_col_types = FALSE
        )
        freezeReactiveValue(input, "disease")
        updateSelectInput(
            inputId = "disease",
            choices = c(
                "All",
                sort(unique(vars$phenotypes$`_primary_disease`))
            )
        )
    })

    observeEvent(input$disease, {
        req(vars$phenotypes)
        req(input$disease != "All")
        vars$phenotypes <- subset(
            vars$phenotypes,
            subset = `_primary_disease` == input$disease
        )
    })

    # Double the buffer size
    Sys.setenv(VROOM_CONNECTION_SIZE = 131072 * 2)

    observeEvent(input$gene_file, {
        freezeReactiveValue(input, "gene_x")
        updateSelectInput(
            inputId = "gene_x",
            choices = colnames(vars$genes)[-1]
        )
        # Import the gene file
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
        vars$dataset <- merge(
            subset(vars$phenotypes, select = "sample"),
            vars$genes,
            by = 1
        )
    })

    output$violin_plot <- renderPlot({
        req(vars$cells)
        req(vars$dataset)

        # Data formatting
        sub_cutted_melt <- isolate(
            convert_biodata(vars$dataset, vars$cells, input$gene_x)
        )

        # Plot the cell subtypes according to the gene expression level
        p <- isolate(plot_violin(sub_cutted_melt, input$gene_x))

        # Add corrected Wilcoxon tests
        stats <- calculate_pvalue(sub_cutted_melt)
        p + stat_pvalue_manual(stats, label = "p.adj.signif")
    })

    exportTestValues(vars2 = vars)
}
