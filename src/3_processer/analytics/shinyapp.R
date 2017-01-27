library(shiny)

source("ui/createanalyticsdashboard.R", chdir=TRUE)
source("ui/createnewsdashboard.R", chdir=TRUE)

ui <- fluidPage(
	fluidRow(
		sidebarLayout(position = "right",
			sidebarPanel(
   				drawnewsboard("newsboard","hello")
			),
			mainPanel(
				drawanalyticsdashboard("analyticsdashboard", "hello")
    			)
		)
  	),
	fluidRow(
		wellPanel(
		
		)
	)
)

server <- function(input, output, session) {

}

shinyApp(ui, server)
