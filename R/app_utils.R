#' Notifications in Shiny
#'
#' @description A wrapper around notifications in Shiny
#'
#' @noRd
show_message <- function(
    f,
    ui,
    duration = NULL,
    closeButton = TRUE,
    type = "default"
) {
    id <- showNotification(
        ui,
        duration = duration,
        closeButton = closeButton,
        type = type
    )
    if (is.null(duration)) {
        on.exit(removeNotification(id), add = TRUE)
    }
    f
}

show_notif <- function(f, duration = 5) {
    show_notif0 <- function(e, duration) {
        notif <- quote(
            show_message(
                {},
                duration = duration
            )
        )
        notif$ui <- e$message
        notif$type <- class(e)[2]
        eval(notif)
    }
    tryCatch(
        f,
        error = function(e) show_notif0(e, duration),
        warning = function(w) show_notif0(w, duration),
        message = function(m) show_notif0(m, duration)
    )
}

format_correction_choices <- function() {
    names <- sort(p.adjust.methods)[-4]
    correction_choices <- as.list(names)
    names(correction_choices) <- str_to_title(names)
    names(correction_choices)[1] <- "Benjamini & Hochberg"
    names(correction_choices)[3] <- "Benjamini & Yekutieli"
    return(correction_choices)
}
