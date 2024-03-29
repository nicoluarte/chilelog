library(shiny)
library(googlesheets)
library(dplyr)
library(ggplot2)
library(DT)
library(lubridate)

ui <- fluidPage(

    titlePanel("ChileLog App"),
    sidebarLayout(
        sidebarPanel(
                                        # this are the query inputs
        textInput("name", "Nombre"),
        numericInput("pass", "Contraseña", value = 0),
        numericInput("cycle", "Ciclo", value = 0),
        selectInput("bloque", "Bloque", choices = list("A", "B", "C")),
        dateInput("date", label = "Fecha", value = Sys.Date())
    ),
    mainPanel(
        uiOutput("trainingLog"),
        actionButton("log", "Registrar"),
        ## dataTableOutput("obs")
    )
    )
)


server <- function(input, output, session)
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
    gsNumbers <- gs %>% gs_read(ws = "Registros")
    plans <- gs %>% gs_read(ws = "Codes")
    ## output to numeric input in ui
    output$trainingLog <- renderUI({
        protocolo <- data.frame(gsProtocols %>%
                           filter(Atleta == input$name & Bloque == input$bloque & Pass == input$pass) %>%
                           select(Protocolo))
        lapply(1:length(protocolo[,1]), function(i){
            numericInput(paste0("protocolo", i), toString(protocolo[i,1]), 0)
        })
    })
    observe({
        x <- plans %>%
            filter(Atleta == input$name & Pass == input$pass) %>%
            select(Ciclo_actual)
        updateNumericInput(session, "cycle", value = x[[1]])
    })

    ## process data vector to enter into database
    # output$obs <- renderDataTable({
    #     protocolo <- data.frame(gsProtocols %>%
    #                             filter(Atleta == input$name & Bloque == input$bloque) %>%
    #                             select(Protocolo))
    #     topSet <- sapply(1:length(protocolo[ , 1]), function(i){
    #         input[[paste0("protocolo", i)]]
    #     })
    #     nombre <- replicate(length(protocolo[ , 1]), input$name)
    #     ciclo <- replicate(length(protocolo[ , 1]), input$cycle)
    #     bloque <- replicate(length(protocolo[ , 1]), input$bloque)
    #     lift <- protocolo[ , 1]
    #     logVector <- data.frame(
    #         name = nombre,
    #         ciclo = ciclo,
    #         bloque = bloque,
    #         lift = lift,
    #         topSet = topSet
    #     )
    #     return(logVector)
    # })
    writeTable <- reactive({
        recordDate <- ymd(input$date)
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
        year <- replicate(length(protocolo[ , 1]), year(recordDate))
        month <- replicate(length(protocolo[ , 1]), month(recordDate))
        day <- replicate(length(protocolo[ , 1]), day(recordDate))
        logVector <- data.frame(
            name = nombre,
            ciclo = ciclo,
            bloque = bloque,
            year = year,
            month = month,
            day = day,
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
