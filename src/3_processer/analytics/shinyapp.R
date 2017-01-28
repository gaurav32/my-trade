library("shiny")
library("timelineprogress")
library("rredis")
library("jsonlite")


redisConnect("127.0.0.1")

source("ui/createanalyticsdashboard.R", chdir=TRUE)
source("ui/createnewsdashboard.R", chdir=TRUE)

worldstockexchangetimeings <- fromJSON(redisGet("WSI"))
worldstockexchangetimeings['content'] = worldstockexchangetimeings['StockExchangeSymbol']
worldstockexchangetimeings['content'] = worldstockexchangetimeings['Country']
worldstockexchangetimeings['start'] = worldstockexchangetimeings['Open']
worldstockexchangetimeings['end'] = worldstockexchangetimeings['Close']

data <- data.frame(
	id      = 1:61,
        content = as.list(worldstockexchangetimeings['content']),
        start = as.list(worldstockexchangetimeings['start']),
        end = as.list(worldstockexchangetimeings['end'])
)

ui <- fluidPage(
	fluidRow(
		sidebarLayout(position = "right",
			sidebarPanel(
   				drawnewsboard("newsboard","hello")
			),
			mainPanel(
				drawanalyticsdashboardOutput("analyticsdashboard", "hello")
    			)
		)
  	),
	fluidRow(
		wellPanel(
		
		)
	)
)

server <- function(input, output, session) {
	generateanalyticsdashboard <- callModule(drawanalyticsdashboard, "analyticsdashboard", stringsAsFactors = FALSE)
	generateanalyticsdashboard()
}

shinyApp(ui, server)
