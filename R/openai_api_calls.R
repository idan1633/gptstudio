


#' Generate text completions using OpenAI's API
#'
#' @param model The model to use for generating text
#' @param prompt The prompt for generating completions
#' @param suffix The suffix for generating completions. If `NULL`, no suffix
#'   will be used.
#' @param max_tokens The maximum number of tokens to generate.
#' @param temperature The temperature to use for generating text (between 0 and
#'   1). If `NULL`, the default temperature will be used. It is recommended NOT
#'   to specify temperature and top_p at a time.
#' @param top_p The top-p value to use for generating text (between 0 and 1). If
#'   `NULL`, the default top-p value will be used. It is recommended NOT to
#'   specify temperature and top_p at a time.
#' @param openai_api_key The API key for accessing OpenAI's API. By default, the
#'   function will try to use the `OPENAI_API_KEY` environment variable.
#' @return A list with the generated completions and other information returned
#'   by the API.
#' @examples
#' \dontrun{
#' openai_create_completion(
#'   model = "text-davinci-002",
#'   prompt = "Hello world!"
#' )
#' }
#' @export
openai_create_completion <-
  function(model,
           prompt = "<|endoftext|>",
           suffix = NULL,
           max_tokens = 16,
           temperature = NULL,
           top_p = NULL,
           openai_api_key = Sys.getenv("OPENAI_API_KEY")) {
    assert_that(
      is.string(model),
      is.string(prompt),
      is.count(max_tokens),
      is.string(suffix) || is.null(suffix),
      value_between(temperature, 0, 1) || is.null(temperature),
      is.string(openai_api_key),
      value_between(top_p, 0, 1) || is.null(top_p)
    )
    print("****")
    print(model)
    body <- list(
      model = model,
      messages = list(
        list(role = "system", content = "You are a helpful assistant. You only reply in R code."),
        list(role = "user", content = prompt)
      ),
      suffix = suffix,
      max_tokens = max_tokens,
      temperature = temperature
    )

    return(query_openai_api(body, openai_api_key, task = "chat/completions"))
  }

query_openai_api <- function(body, openai_api_key, task) {
  #arg_match(task, c("completions", "edits"))

  base_url <- glue("https://api.openai.com/v1/{task}")

  headers <- c(
    "Authorization" = glue("Bearer {openai_api_key}"),
    "Content-Type" = "application/json"
  )
  print(body)

  response <- httr::POST(
    url = base_url,
    httr::add_headers(headers),
    body = body,
    encode = "json"
  )
  print(response)

  parsed <- response %>%
    httr::content(as = "text", encoding = "UTF-8") %>%
    jsonlite::fromJSON(flatten = TRUE)

  if (httr::http_error(response)) {
    abort(c(
      "x" = glue("OpenAI API request failed [{httr::status_code(response)}]."),
      "i" = glue("Error message: {parsed$error$message}")
    ))
  }

  cli_text("Status code: {httr::status_code(response)}")
  print("parsed")
  print(parsed)
  return(parsed)
}

value_between <- function(x, lower, upper) {
  x >= lower && x <= upper
}

both_specified <- function(x, y) {
  x != 1 && y != 1
}

length_between <- function(x, lower, upper) {
  length(x) >= lower && length(x) <= upper
}
