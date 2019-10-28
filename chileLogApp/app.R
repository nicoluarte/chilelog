library(shiny)
library(googlesheets)
library(dplyr)
library(ggplot2)
library(DT)

ui <- fluidPage(

    titlePanel("ChileLog App"),
    sidebarLayout(
        sidebarPanel(
                                        # this are the query inputs
        textInput("name", "Nombre", "Nicolas"),
        numericInput("cycle", "Ciclo", 0),
        numericInput("pass", "PASSWORD", 0),
        selectInput("bloque", "Bloque", choices = list("A", "B", "C")),
        uiOutput("table")
    ),
    mainPanel(
        uiOutput("trainingLog"),
        actionButton("log", "Registrar"),
        dataTableOutput("obs")
    )
    )
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
    ## output to numeric input in ui
    output$trainingLog <- renderUI({
        protocolo <- data.frame(gsProtocols %>%
                           filter(Atleta == input$name & Bloque == input$bloque) %>%
                           select(Protocolo))
        lapply(1:length(protocolo[,1]), function(i){
            numericInput(paste0("protocolo", i), toString(protocolo[i,1]), 0)
        })
    })
    ## process data vector to enter into database
    output$obs <- renderDataTable({
        protocolo <- data.frame(gsProtocols %>%
                                filter(Atleta == input$name & Bloque == input$bloque) %>%
                                select(Protocolo))
        topSet <- sapply(1:length(protocolo[ , 1]), function(i){
            input[[paste0("protocolo", i)]]
        })
        nombre <- replicate(length(protocolo[ , 1]), input$name)
        ciclo <- replicate(length(protocolo[ , 1]), input$cycle)
        bloque <- replicate(length(protocolo[ , 1]), input$bloque)
        lift <- protocolo[ , 1]
        logVector <- data.frame(
            name = nombre,
            ciclo = ciclo,
            bloque = bloque,
            lift = lift,
            topSet = topSet
        )
        return(logVector)
    })
    writeTable <- reactive({
        protocolo <- data.frame(gsProtocols %>%
                                filter(Atleta == input$name & Bloque == input$bloque) %>%
                                select(Protocolo))
        topSet <- sapply(1:length(protocolo[ , 1]), function(i){
            input[[paste0("protocolo", i)]]
        })
        nombre <- replicate(length(protocolo[ , 1]), input$name)
        ciclo <- replicate(length(protocolo[ , 1]), input$cycle)
        bloque <- replicate(length(protocolo[ , 1]), input$bloque)
        lift <- protocolo[ , 1]
        logVector <- data.frame(
            name = nombre,
            ciclo = ciclo,
            bloque = bloque,
            lift = lift,
            topSet = topSet
        )
        return(logVector)
    })

    observeEvent(input$log, {
        TT <- writeTable()
        gs_add_row(gs, ws = "Registros", input = TT)
    })

}

shinyApp(ui = ui, server = server)
