library(shiny)
library(googlesheets)
library(dplyr)

ui <- fluidPage(
    # this are the query inputs
    textInput("name", "Nombre"),
    numericInput("cycle", "Ciclo", 0),
    numericInput("pass", "PASSWORD", 0),
    # this is the query table
    tableOutput("table")
)

server <- function(input, output)
{
    # variable to hold which sheet we're going to use
    dataBase <- "power_log"
    protocols <- "Esquemas"
    # load the auth token
    suppressMessages(gs_auth(token = "googleSheetsToken.rds", verbose = FALSE))
    # here we get the database
    gs <- gs_title(dataBase)
    # here we open the sheet that holds the protocols
    gsProtocols <- gs %>% gs_read(ws = protocols)
    # we read that sheet and make the query using dplyr
    output$table <- renderTable({
        data.frame(gsProtocols %>% filter(Atleta == input$name &
                                          Numero_ciclo == input$cycle &
                                          Pass == input$pass) %>%
                   select(PASTE))
    })
}

shinyApp(ui = ui, server = server)
