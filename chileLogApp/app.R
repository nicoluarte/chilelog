library(shiny)
library(googlesheets)
library(dplyr)
library(ggplot2)

ui <- fluidPage(
    # this are the query inputs
    textInput("name", "Nombre"),
    numericInput("cycle", "Ciclo", 0),
    numericInput("pass", "PASSWORD", 0),
    # this is the query table
    tableOutput("table"),
    tableOutput("table2"),
    plotOutput("plot1", click = "plot_click")
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
    ## simple plot
    gsNumbers <- gs %>% gs_read(ws = "Registros")
    names <- gsNumbers %>% select(Nombre) %>% c()
    movements <- gsNumbers %>% select(grep("Mov*", names(gsNumbers), value = TRUE)) %>% stack()
    weights <- gsNumbers %>% select(grep("Peso*", names(gsNumbers), value = TRUE)) %>% stack()
    toPlot <- data.frame(names = names,
                         movements = movements,
                         weights = weights)
    toPlot[is.na(toPlot)] <- 0
    #output$table2 <- renderTable({
    #    data.frame(toPlot %>%
    #               filter(Nombre == input$name) %>%
    #               select(weights.values))
    #})
    output$plot1 <- renderPlot({
        y <- toPlot %>% filter(Nombre == input$name) %>%
            select(weights.values)
        plot(unlist(y), type = "line")
    })
}

shinyApp(ui = ui, server = server)
