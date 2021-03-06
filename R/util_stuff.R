#' Identify and report the current OS
#'
#' @description Identify and report the current OS
#'
#' @aliases util_get_os
#' @rdname util_get_os
#' @keywords internal
util_get_os <- function() {
  # nocov start
  if (.Platform$OS.type == "windows") {
    "win"
  } else if (Sys.info()["sysname"] == "Darwin") {
    "mac"
  # nocov end
  } else if (.Platform$OS.type == "unix") {
    "unix"
  # nocov start
  } else {
    stop("Unknown OS")
  }
  # nocov end
}

#' Identify and report the current OS
#'
#' @description Identify and report the current OS
#'
#' @param input list with variables and value ranges
#' @param samples number of lhs samples
#' @param precision number of digits for the decimal fraction of parameter
#' values
#' @aliases util_create_lhs
#' @rdname util_create_lhs
#' @keywords internal
util_create_lhs <- function(input, samples, precision) {

  # create a random sample of input factor sets (Latin Hypercube Sampling)
  lhs.design <- lhs::randomLHS(samples, length(input))
  # transform the standardized random values to the real input value range
  # and apply the desired random distribution
  lhs.design <- lapply(seq(1, length(input)), function(i) {
    match.fun(input[[i]]$qfun)(lhs.design[, i], input[[i]]$min, input[[i]]$max)
  })
  names(lhs.design) <- names(input)
  lhs.final <- tibble::as.tibble(lhs.design)
  ## Precision:
  lhs.final <- round(lhs.final, digits = precision)

  return(lhs.final)
}


#' Generate a vector of random seeds
#'
#' @description Generate a vector of random seeds
#'
#' @param nseeds desired length of the random seeds vector
#' @aliases util_generate_seeds
#' @rdname util_generate_seeds
#' @keywords internal
util_generate_seeds <- function(nseeds) {
  seeds <- ceiling(stats::runif(nseeds, 0, 10000))
  return(seeds)
}

#' Report globals from a NetLogo model that is defined within a nl object
#'
#' @description Report globals from a NetLogo model that is defined within a nl
#'  object
#'
#' @param nl nl object with a defined modelpath that points to a NetLogo model
#'  (*.nlogo)
#'
#' @details
#'
#' The function reads the NetLogo model file that is defined within the nl object
#'  and reports all global parameters that are defined as widget elements on
#'  the GUI of the NetLogo model.
#' Only globals that are found by this function are valid globals that can be
#'  entered into the variables or constants vector of an experiment object.
#'
#'
#' @examples
#' \dontrun{
#' report_model_parameters(nl)
#' }
#'
#' @aliases report_model_parameters
#' @rdname report_model_parameters
#'
#' @export

report_model_parameters <- function(nl) {

  ## Open the model as string
  model.code <- readLines(getnl(nl, "modelpath"))

  ## Find the line in the NetLogoCode where the interface definiton starts
  ## (separator: @#$#@#$#@)
  model.code.s1 <- grep("@#$#@#$#@", model.code, fixed = TRUE)[1]

  ## Remove model code before first separator:
  if (is.na(model.code.s1) == FALSE) {
    model.code <- model.code[(model.code.s1 + 1):length(model.code)]
  }
  ## Find second separator where interface definiton ends:
  model.code.s2 <- grep("@#$#@#$#@", model.code, fixed = TRUE)[1]

  ## Remove model code following second separator:
  if (is.na(model.code.s1) == FALSE) {
    model.code <- model.code[1:(model.code.s2 - 1)]
  }

  ## Extract the parameters and their values line by line:
  modelparam <- list()

  for (i in seq_len(length(model.code)))
  {
    ## Read current line from model code
    l <- model.code[i]

    ## Check if l is a definition element and of what kind:
    if (l %in% c("SLIDER", "SWITCH", "INPUTBOX", "CHOOSER")) {
      if (l == "SLIDER") {
        name <- as.character(model.code[i + 5])

        entry <- list(
          type = l,
          value = as.numeric(as.character(model.code[i + 9])),
          min = as.numeric(as.character(model.code[i + 7])),
          max = as.numeric(as.character(model.code[i + 8])),
          incr = as.numeric(as.character(model.code[i + 10]))
        )
      }
      if (l == "SWITCH") {
        name <- as.character(model.code[i + 5])

        entry <- list(
          type = l,
          value = ifelse(as.numeric(as.character(model.code[i + 8])) == 1,
                         TRUE, FALSE)
        )
      }
      # nocov start
      if (l == "INPUTBOX") {
        name <- as.character(model.code[i + 5])

        entry <- list(
          type = l,
          value = model.code[i + 6],
          entrytype = model.code[i + 9]
        )
      }
      # nocov end
      if (l == "CHOOSER") {
        name <- as.character(model.code[i + 5])

        validvalues <- scan(text = (model.code[i + 7]), what = "", quiet = TRUE)
        select_id <- (as.numeric(as.character(model.code[i + 8])) + 1)
        selectedvalue <- validvalues[select_id]

        entry <- list(
          type = l,
          value = selectedvalue,
          validvalues = validvalues
        )
      }

      ## Store in data.frame:
      modelparam[[name]] <- entry
    }
  }

  return(modelparam)
}
