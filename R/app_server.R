#' The application server-side
#'
#' @param input,output,session Internal parameters for {shiny}.
#' @import shiny
#' @noRd
app_server <- function(input, output, session) {

    ########## Dataset loading ##########
    path <- file.path(get_golem_wd(), "inst", "extdata")
    show_notif(
        load(file.path(path, "tcga.rda")),
        "Data loading in progress..."
    )

    vars <- reactiveValues(
        cells = tcga$cells,
        phenotypes_temp = tcga$phenotypes,
        phenotypes = tcga$phenotypes,
        genes = tcga$genes,
        dataset = NULL
    )

    freezeReactiveValue(input, "algorithm")
    print_dev("Set cells choices")
    updateSelectInput(
        inputId = "algorithm",
        choices = sort(names(tcga$cells)),
        selected = "Cibersort_ABS"
    )

    freezeReactiveValue(input, "disease")
    print_dev("Set disease choices")
    updateSelectInput(
        inputId = "disease",
        choices = c(
            # "All",
            str_to_title(
                sort(unique(tcga$phenotypes$`_primary_disease`))
                )
        ),
        selected = "Breast Invasive Carcinoma"
    )

    freezeReactiveValue(input, "tissue")
    print_dev("Set tissue choices")
    updateSelectInput(
        inputId = "tissue",
        choices = c(
            # "All",
            sort(unique(tcga$phenotypes$sample_type))
        ),
        selected = "Primary Tumor"
    )

    print_dev("Gene loading in progress")
    updateSelectizeInput(
        inputId = "gene_x",
        choices = colnames(tcga$genes)[-1],
        server = TRUE,
        selected = ""
    )

    observeEvent(input$algorithm, {
        print_dev("Cell formatting")
        req(input$algorithm != "")
        vars$cells <- tcga$cells[[input$algorithm]]
    })

    observeEvent(input$disease, {
        message_dev("Phenotype formatting")
        req(input$disease != "All")
        req(input$disease != "")
        print_dev(input$disease)
        vars$phenotypes_temp <- tcga$phenotypes[
            tcga$phenotypes$`_primary_disease` == tolower(input$disease),
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
            phenotypes <- vars$phenotypes_temp[
                vars$phenotypes_temp$sample_type == input$tissue,
                "sample"
            ]
            condition <- (nrow(phenotypes) > 0)
            shinyFeedback::feedbackWarning(
                "tissue",
                !condition,
                "Please select a tissue that have samples"
            )
            req(condition)
            vars$phenotypes <- phenotypes
        }
    )

    observeEvent(input$gene_x, {
        print_dev(c("Gene formatting", input$gene_x))
        req(input$gene_x)
        req(input$gene_x != "")
        vars$genes <- select(
            tcga$genes,
            col,
            input$gene_x
        )
    })

    # Merge datasets
    observeEvent(
        c(vars$phenotypes, vars$genes, input$algorithm, input$disease),
        {
            message_dev("Launching merge")
            req(ncol(vars$phenotypes) == 1)
            req(ncol(vars$genes) == 2)
            print_dev("Merge in progress...")
            vars$dataset <- merge(
                subset(vars$phenotypes, select = "sample"),
                vars$genes,
                by = 1
            )
        }
    )

    output$violin_plot <- renderPlotly({
        message_dev("Launching plot")
        req(vars$dataset)
        req(!is(vars$cells, "list"))
        req(input$disease)
        req(input$stat)
        print_dev("Data formatting in progress...")
        # Data formatting
        sub_cutted_melt <- isolate(
            convert_biodata(vars$dataset, vars$cells, input$gene_x, input$stat)
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
        p <- p + stat_pvalue_manual(stats, label = "p.adj.signif")
        plot_dynamic(p)
    })

    exportTestValues(vars2 = vars)
}
