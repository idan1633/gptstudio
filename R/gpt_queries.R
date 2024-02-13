
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
                       max_tokens,
                       openai_api_key = Sys.getenv("OPENAI_API_KEY")
                       ) {
  check_api()
  selection <- get_selection()


  edit <- openai_create_completion(
    model = model,
    prompt = selection$value,
    temperature = temperature,
    max_tokens = max_tokens,
    openai_api_key = openai_api_key
  )

  if(edit$usage$total_tokens > max_tokens) stop(sprintf("Ran out of tokens, you had %s and need at least %s", max_tokens, edit$usage$total_tokens))
  inform(sprintf("Inserting text from %s...", model))

  output_string <-  edit$choices$message.content
  start_index <- gregexpr(pattern = "```", output_string)[[1]][1]
  end_index <- gregexpr(pattern = "```", output_string)[[1]][2]
  if(start_index != -1){
    selected_text <- substr(output_string, start_index + 4, end_index - 1)
  }else{
    selected_text <- output_string
  }
  improved_text <- c(selection$value, selected_text)
  inform(sprintf("Appending text from %s", model))
  print(edit$usage)
  inform(sprintf("This completion used %s tokens", edit$usage$total_tokens))

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

estimate_price <- function(model_name, input_tokens, output_tokens) {
  model_name <- tolower(model_name)  # Convert model name to lowercase for case-insensitive comparison
  
  if (model_name == "gpt-4-turbo") {
    price <- input_tokens * 0.01 + output_tokens * 0.02
  } else if (grepl("gpt-3.5-turbo", model_name)) {
    price <- input_tokens * 0.0005 + output_tokens * 0.0015
  } else if (grepl("gpt-4", model_name)) {
    price <- input_tokens * 0.03 + output_tokens * 0.06
  } else {
    # Default case if the model name doesn't match any of the specified patterns
    price <- NA
    cat("Model pricing not known\n")
  }
  
  return(price)
}
