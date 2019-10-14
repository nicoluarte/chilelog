library(shiny)
library(googlesheets)
library(dplyr)

ui <- fluidPage(
    textInput("name", "Nombre"),
    numericInput("cycle", "Ciclo", 0),
    numericInput("pass", "PASSWORD", 0),
    tableOutput("table")
)

server <- function(input, output)
{
    dataBase <- "power_log"
    protocols <- "Esquemas"
    suppressMessages(gs_auth(token = "googleSheetsToken.rds", verbose = FALSE))
    gs <- gs_title(dataBase)
    gsProtocols <- gs %>% gs_read(ws = protocols)
    output$table <- renderTable({
        data.frame(gsProtocols %>% filter(Atleta == input$name &
                                          Numero_ciclo == input$cycle &
                                          Pass == input$pass) %>%
                   select(PASTE))
    })
}

shinyApp(ui = ui, server = server)
