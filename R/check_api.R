#' Check connection to OpenAI's API works
#'
#' This function checks whether the API key provided in the `OPENAI_API_KEY`
#' environment variable is valid.
#'
#' @param api_key An API key.
#'
#' @return Nothing is returned. If the API key is valid, a success message is
#' printed. If the API key is invalid, an error message is printed and the
#' function is aborted.
#' @export
check_api_connection <- function(api_key) {
  if (!check_api_key(api_key)) {
    invisible()
  } else {
    status_code <- simple_api_check(api_key)
    if (status_code == 200) {
      # If the status code is 200, the key is valid
      cli_alert_success("API key is valid and a simple API call worked.")
      cli_alert_info("The API is validated once per session.")
      cli_text("REMINDER: NEVER COPY SENSITIVE INFO AND RUN GPTSTUDIO AS THIS WILL UPLOAD THIS DATA TO OPENAI")
      options("gptstudio.valid_api" = TRUE)
      options("gptstudio.openai_key" = api_key)
      invisible(TRUE)
    } else {
      # If the status code is not 200, the key is invalid
      cli_alert_danger("API key found but call was unsuccessful.")
      cli_alert_info("Attempted to use API key: {obscure_key(api_key)}")
      if (interactive()) {
        ask_to_set_api()
      } else {
        invisible(FALSE)
      }
    }
  }
}

#' Check API key
#'
#' This function checks whether the API key provided as an argument is in the
#' correct format.
#'
#' @param api_key An API key.
#' @return Nothing is returned. If the API key is in the correct format, a
#' success message is printed. If the API key is not in the correct format,
#' an error message is printed and the function aborts.
#' @export
#'
check_api_key <- function(api_key) {
  if (api_key == "") {
    cli_alert_warning("OPENAI_API_KEY is not set.")
    ask_to_set_api()
    invisible(FALSE)
  } else {
    regex <- "^[a-zA-Z0-9-]{30,60}$"
    if (grepl(regex, api_key)) {
      cli_alert_success("API key found and matches the expected format.")
      invisible(TRUE)
    } else {
      cli_alert_danger("API key not found or is not formatted correctly.")
      cli_alert_info(
        "Attempted to validate key: {obscure_key(api_key)}"
      )
      cli_alert_info(
        "Generate a key at {.url https://beta.openai.com/account/api-keys}"
      )
      ask_to_set_api()
    }
  }
}

#' Check API setup
#'
#' This function checks whether the API key provided in the `OPENAI_API_KEY`
#' environment variable is valid. This function will not re-check an API if it
#' has already been validated in the current session.
#'
#' @return Nothing is returned. If the API key is valid, a success message is
#' printed. If the API key is invalid, an error message is printed and the
#' function aborts.
#' @export
check_api <- function() {
  api_key <- Sys.getenv("OPENAI_API_KEY")
  valid_api <- getOption("gptstudio.valid_api")
  saved_key <- getOption("gptstudio.openai_key")
  if (!valid_api) {
    inform("Checking API key using OPENAI_API_KEY environment variable...")
    check_api_connection(api_key)
  } else if (saved_key == Sys.getenv("OPENAI_API_KEY")) {
    cli_alert_success("API already validated in this session.")
    invisible(TRUE)
  } else {
    cli_alert_warning("API key has changed. Re-checking API connection.")
    check_api_connection(api_key)
  }
}

simple_api_check <- function(api_key) {
  response <- httr::GET(
    "https://api.openai.com/v1/models",
    httr::add_headers(Authorization = paste0("Bearer ", api_key))
  )
  httr::status_code(response)
}

set_openai_api_key <- function() {
  new_api_key <- readline("Copy and paste your API key here: ")
  if (check_api()) {
    cli_alert_success("API key is valid.")
    cli_alert_info("Setting OPENAI_API_KEY environment variable.")
    Sys.setenv(OPENAI_API_KEY = new_api_key)
    cli_alert_info("You can set this variable in your .Renviron file.")
    invisible(TRUE)
  } else {
    cli_alert_danger("API key is invalid.")
    cli_alert_info(
      "Get key from {.url https://beta.openai.com/account/api-keys}"
    )
    if (interactive()) {
      try_again <- usethis::ui_yeah("Woud you like to try again?")
      ifelse(try_again, set_openai_api_key(), FALSE)
    } else {
      invisible(FALSE)
    }
  }
}

ask_to_set_api <- function(try_again = FALSE) {
  if (interactive()) {
    set_api <- usethis::ui_yeah(
      "Do you want to set the OPENAI_API_KEY for this session?"
    )
    if (set_api) {
      set_openai_api_key()
    } else {
      warn("Not setting OPENAI_API_KEY environment variable.")
      invisible(FALSE)
    }
  } else {
    invisible(FALSE)
  }
}

obscure_key <- function(api_key) {
  if (nchar(api_key) == 0) {
    "no key provided"
  } else if (nchar(api_key) > 8) {
    api_start <- substr(api_key, 1, 4)
    api_mid <- paste0(rep("*", nchar(api_key) - 8), collapse = "")
    api_end <- substr(api_key, nchar(api_key) - 3, nchar(api_key))
    paste0(api_start, api_mid, api_end)
  } else {
    "<hidden> (too short to obscure)"
  }
}
