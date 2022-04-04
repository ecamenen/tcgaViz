#' The application server-side
#'
#' @param input,output,session Internal parameters for {shiny}.
#' @import shiny
#' @noRd
app_server <- function(input, output, session) {

    ########## Dataset loading ##########
    path <- file.path(get_golem_wd(), "inst", "extdata")
    show_notif(
        load(file.path(path, "tcga_raw.rda")),
        "Data loading in progres..."
    )

    vars <- reactiveValues(
        cells = tcga_raw$cells,
        phenotypes_temp = tcga_raw$phenotypes,
        phenotypes = tcga_raw$phenotypes,
        genes = tcga_raw$genes,
        dataset = NULL
    )

    freezeReactiveValue(input, "algorithm")
    print_dev("Set cells choices")
    updateSelectInput(
        inputId = "algorithm",
        choices = sort(names(tcga_raw$cells))
    )

    freezeReactiveValue(input, "disease")
    print_dev("Set disease choices")
    updateSelectInput(
        inputId = "disease",
        choices = c(
            # "All",
            sort(unique(tcga_raw$phenotypes$`_primary_disease`))
        ),
        selected = "breast invasive carcinoma"
    )

    freezeReactiveValue(input, "tissue")
    print_dev("Set tissue choices")
    updateSelectInput(
        inputId = "tissue",
        choices = c(
            # "All",
            sort(unique(tcga_raw$phenotypes$sample_type))
        ),
        selected = "Primary Tumor"
    )

    init <- Sys.time()
    print_dev("Gene loading in progress")
    updateSelectizeInput(
        inputId = "gene_x",
        choices = colnames(tcga_raw$genes)[-1],
        server = TRUE,
        selected = ""
    )
    print_dev(Sys.time() - init)

    observeEvent(input$algorithm, {
        print_dev("Cell formatting")
        req(input$algorithm != "")
        vars$cells <- tcga_raw$cells[[input$algorithm]]
    })

    observeEvent(input$disease, {
        message_dev("Phenotype formatting")
        req(input$disease != "All")
        req(input$disease != "")
        print_dev(input$disease)
        vars$phenotypes_temp <- tcga_raw$phenotypes[
            tcga_raw$phenotypes$`_primary_disease` == input$disease,
        ]
    })

    observeEvent(
        c(input$tissue, vars$phenotypes_temp),
        {
            message_dev("Tissue formatting")
            req(vars$phenotypes_temp$sample_type)
            req(input$tissue != "All")
            req(input$tissue != "")
            print_dev(input$tissue)
            vars$phenotypes <- vars$phenotypes_temp[
                vars$phenotypes_temp$sample_type == input$tissue,
                "sample"
            ]
        }
    )

    observeEvent(input$gene_x, {
        init <- Sys.time()
        print_dev(c("Gene formatting", input$gene_x))
        req(input$gene_x)
        req(input$gene_x != "")
        vars$genes <- select(
            tcga_raw$genes,
            col,
            input$gene_x
        )
        print_dev(Sys.time() - init)
    })

    # Merge datasets
    observeEvent(
        c(vars$phenotypes, vars$genes, input$algorithm, input$disease),
        {
            message_dev("Launching merge")
            req(ncol(vars$phenotypes) == 1)
            req(ncol(vars$genes) == 2)
            init <- Sys.time()
            print_dev("Merge in progress...")
            vars$dataset <- merge(
                subset(vars$phenotypes, select = "sample"),
                vars$genes,
                by = 1
            )
            print_dev(Sys.time() - init)
        }
    )

    output$violin_plot <- renderPlot({
        message_dev("Launching plot")
        req(vars$dataset)
        req(!is(vars$cells, "list"))
        req(input$disease)
        print_dev("Data formatting in progress...")
        # Data formatting
        sub_cutted_melt <- isolate(
            convert_biodata(vars$dataset, vars$cells, input$gene_x)
        )
        print_dev("Whatever in progress...")
        # Plot the cell subtypes according to the gene expression level
        p <- isolate(plot_violin(sub_cutted_melt, input$gene_x))
        # Add corrected Wilcoxon tests
        stats <- show_notif(
            calculate_pvalue(sub_cutted_melt),
            "Statistic calculation in progres..."
        )

        print_dev("Plot in progress...")
        p + stat_pvalue_manual(stats, label = "p.adj.signif")
    })

    exportTestValues(vars2 = vars)
}
