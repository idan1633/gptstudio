# gptstudio

This repo is a fork of <https://github.com/MichelNivard/gptstudio> which rolls back and only keeps one Rstudio Add-In. Write/Code from prompt. Usage:

## Install the addins from this package:

``` r
require(devtools)
install_github("idan1633/gptstudio")
```

## Usage

Once installed, you should have an Rstudio Add-In called 'Write/Code from prompt'. Comment a prompt, select it with the cursor, and click Addins, Write/Code from prompt. This should fill in GPTs reply in your file.

### An example of use.

``` r
# Make a function that multiplies three matrices together and gets the standard deviation of the values in the resultant matrix

multiply_and_get_sd <- function(matrix1, matrix2, matrix3) { 
  result <- matrix1 %*% matrix2 %*% matrix3 
  sd_result <- sd(result) return(sd_result) 
}
```

## Privacy Notice

These functions work by taking the text or code you have highlighted/selected with the cursor, or your prompt if you use one of the built-in apps, and send these to OpenAI as part of a prompt; they fall under their privacy notice/rules/exceptions you agreed to with OpenAI when making an account. Don't select sensitive data.

**DO NOT HIGHLIGHT, OR INCLUDE IN A PROMPT, AND THEREFORE UPLOAD, DATA/CODE/TEXT THAT SHOULD REMAIN PRIVATE**

## Prerequisites

1.  Make an OpenAI account. As of now, the free one will do.

2.  [Create an OpenAI API key](https://beta.openai.com/account/api-keys) to use `{openai}` package within Rstudio

3.  Set the API key up in Rstudio in one of two ways:

-   By default, functions of `{openai}` will look for `OPENAI_API_KEY` environment variable. If you want to set a global environment variable, you can use the following command, where `"<APIKEY>"` should be replaced with your actual key:

``` r
Sys.setenv(OPENAI_API_KEY = "<APIKEY>")
```

-   Alternatively, you can set the key in your .Renviron file.

Otherwise, you can add the key to the .Renviron file of the project. The following commands will open .Renviron for editing:

``` r
require(usethis)
edit_r_environ(scope = "project")
```

You can add the following line to the file (again, replace `"<APIKEY>"` with your actual key):

``` bash
OPENAI_API_KEY= "<APIKEY>")
```

This now set the API key every time you start up this particular project. Note: If you are using GitHub/Gitlab, do not forget to add .Renviron to .gitignore!

## Settings

The default settings are (model = gpt-3.5-turbo, temp = 0.1, max_tokens = 500). You can edit this as follows

``` r
# Change all settings
gptstudio::change_gpt_settings(max_tokens = 1000, model= "gpt-4-turbo-preview", temperature = 0.2)
# change the one setting and keep the others as is
gptstudio::change_gpt_settings(max_tokens = 100)
```

## Keyboard shortcut

I used [this article](<https://support.posit.co/hc/en-us/articles/206382178-Customizing-Keyboard-Shortcuts-in-the-RStudio-IDE> ) and made a shortcut to call this addin. I like command-shift-G. Keep in mind the addin is called "Write/Code from prompt" when following this tutorial.
