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
