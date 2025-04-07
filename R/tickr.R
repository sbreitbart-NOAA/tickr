#' Adjust axis tick marks and labels
#'
#' @param data A dataframe containing the variable of interest
#' @param var Variable of interest (e.g., year)
#' @param by Step increase desired (e.g., every 5 years)
#' @param var_min minimum value to adjust axis range
#' @param var_max Maximum value to adjust axis range
#' @param lab_start Lowest value to label
#' @param lab_end Last value to label
#'
#' @return A dataframe containing:
#' \item{breaks}{Numeric vector of axis break positions}
#' \item{labels}{Character vector of axis labels}
#'
#' @export tickr
#' @examples
#' # Create sample data
#' df <- data.frame(year = 1977:2023, value = rnorm(47))
#'
#' # Basic usage
#' tickr(data=df, var=year, by=5)
tickr <- function(data, var, by = 5, var_min = NULL, var_max = NULL, lab_start = NULL, lab_end = NULL) {
  # input validation
  if (!is.data.frame(data)) { stop("'data' must be a dataframe") }
  if (by <= 0) { stop("'by' must be positive") }
  if (!is.null(var_min) && !is.null(var_max) && var_min > var_max) {
    stop("'var_min' must be less than or equal to 'var_max'")
  }
  if (!is.null(lab_start) && !is.null(lab_end) && lab_start > lab_end) {
    stop("'lab_start' must be less than or equal to 'lab_end'")
  }

  # enquo/eval_tidy for non-standard evaluation
  var_expr = rlang::enquo(var)
  var_name = rlang::as_name(var_expr)

  # check if variable is in data
  if(!(var_name) %in% names(data)) {
    stop(sprintf("Variable '%s' not found in data", var_name))
  }
  # data range
  var_vals <- rlang::eval_tidy(var_expr, data)
  out <- list(
    min = min(var_vals, na.rm = TRUE),
    max = max(var_vals, na.rm = TRUE)
  )

  # determine break range
  from <- if (!is.null(var_min)) var_min else out$min
  to <- if (!is.null(var_max)) var_max else out$max

  # create sequence of breaks
  breaks <- seq(from, to)

  # calculate sequence starting point
  seq_start <- if (!is.null(lab_start)) {
    lab_start
  } else {
    by * floor(from/by)
  }

  # sequence of labeled breaks
  seq_breaks <- seq(seq_start, to, by = by)

  # labels vector
  labels <- character(length(breaks))

  # assign labels
  is_match <- breaks %in% seq_breaks
  if (!is.null(lab_start) || !is.null(lab_end)) {
    is_in_range <- if (!is.null(lab_start) && !is.null(lab_end)) {
      breaks >= lab_start & breaks <= lab_end
    } else if (!is.null(lab_start)) {
      breaks >= lab_start
    } else {
      breaks <= lab_end
    }
    is_match <- is_match & is_in_range
  }

  labels[is_match] <- as.character(breaks[is_match])
  data.frame(breaks = breaks, labels = labels)
  }



#' Adjust axis tick marks and labels
#'
#' @param data A dataframe containing the variable of interest
#' @param var Variable of interest (e.g., year)
#' @param by Step increase desired (e.g., every 5 years)
#' @param var_min minimum value to adjust axis range
#' @param var_max Maximum value to adjust axis range
#' @param lab_start Lowest value to label
#' @param lab_end Last value to label
#' @param ... other ggplot2::scale_x_continuous inputs
#'
#' @export scale_x_tickr
#' @examples
#' # Use with ggplot2
#' df <- data.frame(year = 1977:2023, value = rnorm(47))
#' library(ggplot2)
# ggplot2::ggplot(data=df, ggplot2::aes(x = year, y = value)) +
#   ggplot2::geom_line() +
#   scale_x_tickr(data = df, var = year, by = 5)
scale_x_tickr <- function(..., data, var, by = 5, var_min=NULL, var_max=NULL, lab_start=NULL, lab_end=NULL) {
  if (!requireNamespace("ggplot2", quietly = TRUE)) {
    stop('ggplot2 is required for this functionality', call. = FALSE)
  }
  var_expr <- rlang::enquo(var)
  axis = tickr(data, var=!!var_expr, by=by, var_min, var_max, lab_start, lab_end)
  ggplot2::scale_x_continuous(breaks = axis$breaks, labels = axis$labels, ...)
}

#' Adjust axis tick marks and labels
#'
#' @param data A dataframe containing the variable of interest
#' @param var variable of interest (e.g., year)
#' @param by step increase desired (e.g., every 5 years)
#' @param var_min minimum value to adjust axis range
#' @param var_max Maximum value to adjust axis range
#' @param lab_start Lowest value to label
#' @param lab_end Last value to label
#' @param ... = other ggplot2::scale_y_continuous inputs
#'
#' @export scale_y_tickr
#' @examples
#' # Use with ggplot2
#' df <- data.frame(year = 1977:2023, value = rnorm(47))
#' library(ggplot2)
#' ggplot2::ggplot(data=df, ggplot2::aes(x = value, y = year)) +
#'   ggplot2::geom_line() +
#'   scale_y_tickr(data = df, var = year, by = 5)
scale_y_tickr <- function(..., data, var, by = 5, var_min=NULL, var_max=NULL, lab_start=NULL, lab_end=NULL) {
  if (!requireNamespace("ggplot2", quietly = TRUE)) {
    stop('ggplot2 is required for this functionality', call. = FALSE)
  }
  var_expr <- rlang::enquo(var)
  axis = tickr(data, var=!!var_expr, by, var_min, var_max, lab_start, lab_end)
  ggplot2::scale_y_continuous(breaks = axis$breaks, labels = axis$labels, ...)
}

