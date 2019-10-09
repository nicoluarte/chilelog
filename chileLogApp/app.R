# import libraries
library(shiny)
# googlesheets is the api
library(googlesheets)

# the ui defines all that the user will see in the web app
ui <- fluidPage(
    textInput("caption", "Caption", "Data summary"),
    verbatimTextOutput("value"),
    actionButton(inputId = "log", label = "log")
)

# server executes functions, based on the user input
server <- function(input, output)
{
  # here text is being rendered based on user input
    output$value <- renderText({input$caption})
  # observeEvent watches for actionButton value
  # when this values changes (the button is pressed) some functions are executed
    observeEvent(input$log,
    {
      # in order to work with googlesheets we need a token to authenticate 
      # commented at the bottom is how I obtained the token, this doesn't seem
      # like a good solution but it works for prototyping
        suppressMessages(gs_auth(token = "googleSheetsToken.rds", verbose = FALSE))
        # for_gs holds the google sheet "test"
        for_gs <- gs_title("test")
        # this functions add a new row with user input
        gs_add_row(for_gs, ws = 1, input = input$caption)
    })
}

shinyApp(ui = ui, server = server)

## code to generate a token ##
# https://cran.r-project.org/web/packages/googlesheets/vignettes/managing-auth-tokens.html
#token <- gs_auth(cache = FALSE)
#gd_token()
#saveRDS(token, file = "googleSheetsToken.rds")
