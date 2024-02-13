
#' @export
change_gpt_settings <- function(max_tokens = NULL, 
                                model = NULL, 
                                temperature = NULL) {
  
  op <- options()

  op_gptstudio <- list(
    gptstudio.valid_api  = op$gptstudio.valid_api,
    gptstudio.openai_key = op$gptstudio.openai_key,
    gptstudio.max_tokens = ifelse(is.null(max_tokens), op$gptstudio.max_tokens, max_tokens),
    gptstudio.model = ifelse(is.null(model), op$gptstudio.model, model),
    gptstudio.temperature = ifelse(is.null(temperature), op$gptstudio.temperature, temperature)
  )

  options(op_gptstudio)
  
  invisible()
}