#' write/code from prompt Addin
#'
#' Call this function as a Rstudio addin to ask GPT to write text or code from
#' a descriptive prompt
#'
#' @export
wpAddin <- function() {
  gpt_create(
    model = getOption("gptstudio.model"),
    max_tokens = getOption("gptstudio.max_tokens"),
    temperature = getOption("gptstudio.temperature")
  )
}
