timelineprogress <- function(data, groups, showZoom = TRUE, zoomFactor = 0.5, fit = TRUE,
                    options, width = NULL, height = NULL, elementId = NULL,
                    loadDependencies = TRUE) {

  # Validate the input data
  if (missing(data)) {
    data <- data.frame()
  }
  if (!is.data.frame(data)) {
    stop("timevis: 'data' must be a data.frame",
         call. = FALSE)
  }
  if (nrow(data) > 0 &&
      (!"start" %in% colnames(data) || anyNA(data[['start']]))) {
    stop("timevis: 'data' must contain a 'start' date for each item",
         call. = FALSE)
  }
  if (!missing(groups) && !is.data.frame(groups)) {
    stop("timevis: 'groups' must be a data.frame",
         call. = FALSE)
  }
  if (!missing(groups) && nrow(groups) > 0 &&
      (!"id" %in% colnames(groups) || !"content" %in% colnames(groups) )) {
    stop("timevis: 'groups' must contain a 'content' and 'id' variables",
         call. = FALSE)
  }
  if (!is.bool(showZoom)) {
    stop("timevis: 'showZoom' must be either 'TRUE' or 'FALSE'",
         call. = FALSE)
  }
  if (!is.numeric(zoomFactor) || length(zoomFactor) > 1 || zoomFactor <= 0) {
    stop("timevis: 'zoomFactor' must be a positive number",
         call. = FALSE)
  }
  if (!is.bool(fit)) {
    stop("timevis: 'fit' must be either 'TRUE' or 'FALSE'",
         call. = FALSE)
  }
  if (missing(options) || is.null(options)) {
    options <- list()
  }
  if (!is.list(options)) {
    stop("timevis: 'options' must be a named list",
         call. = FALSE)
  }

  items <- dataframeToD3(data)
  if (missing(groups)) {
    groups <- NULL
  } else {
    groups <- dataframeToD3(groups)
  }

  # forward options using x
  x = list(
    items = items,
    groups = groups,
    showZoom = showZoom,
    zoomFactor = zoomFactor,
    fit = fit,
    options = options,
    height = height
  )

  # Allow a list of API functions to be called on the timevis after
  # initialization
  x$api <- list()

  # add dependencies so that the zoom buttons will work in non-Shiny mode
  if (loadDependencies) {
    deps <- list(
      rmarkdown::html_dependency_jquery(),
      rmarkdown::html_dependency_bootstrap("default")
    )
  } else {
    deps <- NULL
  }

  # create widget
  htmlwidgets::createWidget(
    name = 'timevis',
    x,
    width = width,
    height = height,
    package = 'timevis',
    elementId = elementId,
    dependencies = deps
  )
}



timelineprogressOutput <- function(outputId, width = '100%', height = 'auto') {
  htmlwidgets::shinyWidgetOutput(outputId, 'timelineprogress', width, height, package = 'timelineprogress')
}

renderTimelineprogress <- function(expr, env = parent.frame(), quoted = FALSE) {
  if (!quoted) { expr <- substitute(expr) } # force quoted
  htmlwidgets::shinyRenderWidget(expr, timelineprogressOutput, env, quoted = TRUE)
}

# Add custom HTML to wrap the widget to allow for a zoom in/out menu
timelineprogress_html <- function(id, style, class, ...){
  htmltools::tags$div(
    id = id, class = class, style = style,
    htmltools::tags$div(
      class = "btn-group zoom-menu",
      htmltools::tags$button(
        type = "button",
        class = "btn btn-default btn-lg zoom-in",
        title = "Zoom in",
        "+"
      ),
      htmltools::tags$button(
        type = "button",
        class = "btn btn-default btn-lg zoom-out",
        title = "Zoom out",
        "-"
      )
    )
  )
}