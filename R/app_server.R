#' The application server-side
#'
#' @param input,output,session Internal parameters for {shiny}.
#' @noRd
app_server <- function(input, output, session) {

    ########## Dataset loading ##########
    if (!exists("tcga")) {
        path <- system.file("extdata", package = "tcgaViz")
        file <- "tcga.rda"
        file_path <- file.path(path, file)
        if (!file.exists(file_path)) {
            download.file(
                "https://tcga-pancan-atlas-hub.s3.us-east-1.amazonaws.com/download/EB%2B%2BAdjustPANCAN_IlluminaHiSeq_RNASeqV2.geneExp.xena.gz",
                file_path,
                "wget"
            )
        }
        show_message(
            load(file_path),
            "Data loading in progress..."
        )
    }

    vars <- reactiveValues(
        cells = tcga$cells,
        phenotypes_temp = tcga$phenotypes,
        phenotypes = tcga$phenotypes,
        genes = tcga$genes,
        dataset = NULL,
        biodata = NULL,
        biostats = NULL,
        bioplot = NULL
    )

    freezeReactiveValue(input, "algorithm")
    updateSelectInput(
        inputId = "algorithm",
        choices = sort(names(tcga$cells)),
        selected = "Cibersort_ABS"
    )

    freezeReactiveValue(input, "disease")
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
    updateSelectInput(
        inputId = "tissue",
        choices = c(
            # "All",
            sort(levels(tcga$phenotypes$sample_type))
        ),
        selected = "Primary Tumor"
    )

    updateSelectizeInput(
        inputId = "gene_x",
        choices = colnames(tcga$genes)[-1],
        server = TRUE,
        selected = ""
    )

    observeEvent(input$algorithm, {
        req(input$algorithm != "")
        vars$cells <- tcga$cells[[input$algorithm]]
    })

    observeEvent(input$disease, {
        req(input$disease != "All")
        req(input$disease != "")
        vars$phenotypes_temp <- tcga$phenotypes[
            tcga$phenotypes$`_primary_disease` == tolower(input$disease),
        ]
    })

    observeEvent(
        c(input$tissue, vars$phenotypes_temp),
        {
            req(vars$phenotypes_temp$sample_type)
            req(input$tissue != "All")
            req(input$tissue != "")
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
        req(input$gene_x)
        req(input$gene_x != "")
        vars$genes <- select(
            tcga$genes,
            sample,
            input$gene_x
        )
    })

    # Merge datasets
    observeEvent(
        c(vars$phenotypes, vars$genes, input$algorithm, input$disease),
        {
            req(ncol(vars$phenotypes) == 1)
            req(ncol(vars$genes) == 2)
            vars$dataset <- merge(
                subset(vars$phenotypes, select = "sample"),
                vars$genes,
                by = 1
            )
        }
    )

    observeEvent(c(
        vars$dataset,
        vars$cells,
        input$gene_x,
        input$stat,
        input$disease,
        input$tissue
    ), {
        req(vars$dataset)
        req(!is(vars$cells, "list"))
        req(input$stat)
        req(input$gene_x != "")
        req(input$gene_x %in% colnames(vars$dataset))
        biodata <- show_notif(
            isolate(
                convert_biodata(
                    vars$dataset,
                    vars$cells,
                    input$gene_x,
                    input$stat,
                    input$disease,
                    input$tissue
                )
            )
        )
        condition <- !is.null(biodata)
        shinyFeedback::feedbackWarning(
            "stat",
            !condition,
            stop_msg_stat
        )
        req(condition)
        vars$biodata <- biodata
    })

    observeEvent(c(vars$biodata, input$test, input$correction, input$pval), {
        req(vars$biodata)
        vars$biostats <- show_message(
            calculate_pvalue(
                vars$biodata,
                method_test = input$test,
                method_adjust = input$correction,
                p_threshold = input$pval
            ),
            "Statistic calculation in progress..."
        )
    })

    observeEvent(
        c(
            vars$biodata,
            vars$biostats,
            input$type,
            input$dots,
            input$title,
            input$xlab,
            input$ylab,
            input$cex_main,
            input$cex_lab
        ),
        {
            req(vars$biostats)
            if (input$title == "") {
                title <- NULL
            } else {
                title <- input$title
            }
            if (input$xlab == "") {
                xlab <- NULL
            } else {
                xlab <- input$xlab
            }
            if (input$ylab == "") {
                ylab <- NULL
            } else {
                ylab <- input$ylab
            }
            vars$bioplot <- plot(
                x = vars$biodata,
                type = input$type,
                dots = input$dots,
                stats = vars$biostats,
                title = title,
                xlab = xlab,
                ylab = ylab,
                cex.main = input$cex_main,
                cex.lab = input$cex_lab,
                draw = FALSE
            )
        }
    )

    plot_distribution_app <- function() {
        suppressWarnings(plot(vars$bioplot))
    }

    output$distribution_plot <- renderPlot({
        req(vars$bioplot)
        show_message(plot_distribution_app(), "Plot in progress...")
    })

    output$stats_summary <- DT::renderDataTable({
        req(vars$biostats)
        df <- get_biostats(vars$biostats) %>%
            datatable(
                caption = gsub(
                    "\\n",
                    ": ",
                    description.biostats(vars$biostats)
                ),
                class = "cell-border stripe",
                rownames = FALSE,
                extensions = c("Scroller"),
                selection = "none",
                callback = JS('$("button.buttons-copy").css("background","#fff");
                $("button.buttons-collection").css("background","#fff");
                return table;'),
                options = list(
                    initComplete = JS(
                        "function(settings, json) {",
                        "$(this.api().table().header()).css({'background-color': '#000', 'color': '#fff'});",
                        "}"
                    ),
                    dom = "frtp",
                    columnDefs = list(
                        list(
                            targets = "_all",
                            render = JS(
                                "function(data, type, row, meta) {",
                                "return type === 'display' && data != null && data.length > 50 ?",
                                "'<span title=\"' + data + '\">' + data.substr(0, 50) + '...</span>' : data;",
                                "}"
                            )
                        )
                    ),
                    scrollY = 600, scrollX = 400, scroller = TRUE,
                    searchHighlight = TRUE,
                    search = list(regex = TRUE)
                )
            ) %>%
            formatSignif(columns = 2:8, digits = 3)
    })

    output$download_distribution <- downloadHandler(
        filename = function() {
            "statistics.tiff"
        },
        content = function(file) {
            req(vars$bioplot)
            tiff(file, units = "px", width = 2500, height = 2500, res = 300)
            plot_distribution_app()
            dev.off()
        }
    )

    output$download_stats <- downloadHandler(
        filename = function() {
            "statistics.csv"
        },
        content = function(file) {
            req(vars$biostats)
            df <- data.frame(get_biostats(vars$biostats))
            for (i in 2:8) {
                df[, i] <- formatC(df[, i], format = "e", digits = 3)
            }
            write.csv(df, file = file, row.names = FALSE)
        }
    )

    exportTestValues(vars2 = vars)
}
