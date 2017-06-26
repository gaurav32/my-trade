library("shiny")
library("timelineprogress")
library("rredis")
library("jsonlite")


redisConnect("127.0.0.1")

source("ui/createanalyticsdashboard.R", chdir=TRUE)
source("ui/createnewsdashboard.R", chdir=TRUE)
source("strategy/R/getNifty50stocksdata.R", chdir=TRUE)
source("strategy/R/getSureshotProfitStocks.R", chdir=TRUE)

finalallstocklowhigh <- getAllStockLowHigh()
sureshotprofitstocks <- getsureshotprofitstocks(finalallstocklowhigh)

symbols <- getAllSymbols()


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
   				drawnewsboardUI("newsboard","all the news")
			),
			mainPanel(
				drawanalyticsdashboardUI("analyticsdashboard")
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
}

shinyApp(ui, server)