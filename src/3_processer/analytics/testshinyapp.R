library(shiny)

source("server/testModuleServer1.R", chdir=TRUE)
source("ui/testModule1.R", chdir=TRUE)
source("ui/createAnalyticsDashboard.R", chdir=TRUE)

gaurav()*5

ui <- fluidPage(
  sidebarLayout(
    sidebarPanel(
      csvFileInput("datafile", "User data (.csv format)")
    ),
    mainPanel(
      #dataTableOutput("table")
	drawanalyticsdashboard()
    )
  )
)

server <- function(input, output, session) {
  datafile <- callModule(csvFile, "datafile",
    stringsAsFactors = FALSE)

#  output$table <- renderDataTable({
#    datafile()
#  })
}

shinyApp(ui, server)
