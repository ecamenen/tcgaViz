#' Notifications in Shiny
#'
#' @description A wrapper around notifications in Shiny
#'
#' @noRd
show_notif <- function(f, m) {
    id <- showNotification(m, duration = NULL, closeButton = FALSE)
    on.exit(removeNotification(id), add = TRUE)
    f
}

format_correction_choices <- function() {
    names <- sort(p.adjust.methods)[-4]
    correction_choices <- as.list(names)
    names(correction_choices) <- str_to_title(names)
    names(correction_choices)[1] <- "Benjamini & Hochberg"
    names(correction_choices)[3] <- "Benjamini & Yekutieli"
    return(correction_choices)
}
