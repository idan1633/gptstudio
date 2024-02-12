
#' Use GPT to improve text
#'
#' This function uses the GPT model from OpenAI to improve the spelling and
#'  grammar of the selected text in the current RStudio session.
#'
#' @param model The name of the GPT model to use.
#' @param temperature A parameter for controlling the randomness of the GPT
#'  model's output.
#' @param max_tokens Maximum number of tokens to return (related to length of
#' response), defaults to 500
#' @param openai_api_key An API key for the OpenAI API.
#' @param append_text Add text to selection rather than replace, default to TRUE
#'
#' @return Nothing is returned. The improved text is inserted into the current
#' RStudio session.
#' @export
gpt_create <- function(model,
                       temperature,
                       max_tokens = getOption("gptstudio.max_tokens"),
                       openai_api_key = Sys.getenv("OPENAI_API_KEY"),
                       append_text = TRUE) {
  check_api()
  selection <- get_selection()


  edit <- openai_create_completion(
    model = model,
    prompt = selection$value,
    temperature = temperature,
    max_tokens = max_tokens,
    openai_api_key = openai_api_key
  )

  inform("Inserting text from GPT...")
  print(append_text)
  if (append_text) {
    output_string <-  edit$choices$message.content
    start_index <- gregexpr(pattern = "```", output_string)[[1]][1]
    end_index <- gregexpr(pattern = "```", output_string)[[1]][2]
    if(start_index != -1){
      selected_text <- substr(output_string, start_index + 4, end_index - 1)
    }else{
      selected_text <- output_string
    }
    improved_text <- c(selection$value, selected_text)
    inform("Appending text from GPT...")
  } else {
    improved_text <- edit$choices$text
    inform("Inserting text from GPT...")
  }
  insert_text(improved_text)
}




#' Wrapper around selectionGet to help with testthat
#'
#' @return Text selection via `rstudioapi::selectionGet`
#'
#' @export
get_selection <- function() {
  rstudioapi::verifyAvailable()
  rstudioapi::selectionGet()
}

#' Wrapper around selectionGet to help with testthat
#'
#' @param improved_text Text from model queries to inert into script or document
#'
#' @export
insert_text <- function(improved_text) {
  rstudioapi::verifyAvailable()
  rstudioapi::insertText(improved_text)
}
