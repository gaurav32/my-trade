library("shiny")
library("timelineprogress")
library("rredis")
library("jsonlite")


redisConnect("127.0.0.1")

source("ui/createanalyticsdashboard.R", chdir=TRUE)
source("ui/createnewsdashboard.R", chdir=TRUE)
source("strategy/R/getNifty50stocksdata.R", chdir=TRUE)
source("strategy/R/getSureshotProfitStocks.R", chdir=TRUE)

symbols <- getAllSymbols()

finalallstocklow <- getAllStockLow()
finalallstockhigh <- getAllStockHigh()
finalallstocklowhigh <- getAllStockLowHigh()
gainpercent <- 0.01
sureshot1profitstocks <- getsureshotprofitstocks(finalallstocklow, finalallstockhigh, gainpercent)
gainpercent <- 0.02
sureshot2profitstocks <- getsureshotprofitstocks(finalallstocklow, finalallstockhigh, gainpercent)
gainpercent <- 0.03
sureshot3profitstocks <- getsureshotprofitstocks(finalallstocklow, finalallstockhigh, gainpercent)
gainpercent <- 0.04
sureshot4profitstocks <- getsureshotprofitstocks(finalallstocklow, finalallstockhigh, gainpercent)
gainpercent <- 0.05
sureshot5profitstocks <- getsureshotprofitstocks(finalallstocklow, finalallstockhigh, gainpercent)

sureshotprofitstocks <- sureshot1profitstocks

everydayhighlowdiffpercent <- geteverydayhighlowdiffpercent(finalallstocklow, finalallstockhigh)
##yesterdaylowtotodaydhighdiffpercent <- getyesterdaylowtotodaydhighdiffpercent(finalallstocklow, finalallstockhigh)
##todaylowtoyesterdaydhighdiffpercent <- gettodaylowtoyesterdaydhighdiffpercent(finalallstocklow, finalallstockhigh)

profitpercentageprobability <- getprofitpercentageprobability(finalallstocklow, finalallstockhigh)

symbols <- as.list(c("BHEL","PNB","BANKBARODA","IDEA"))
getConfidentPredictionGoodStocks(everydayhighlowdiffpercent,finalallstocklow, finalallstockhigh, symbols)

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
			drawanalyticsdataUI("analyticsdata")
		)
	)
)

server <- function(input, output, session) {
	generateanalyticsdashboard <- callModule(drawanalyticsdashboard, "analyticsdashboard", stringsAsFactors = FALSE)
	generateanalyticsdata <- callModule(drawanalyticsdata, "analyticsdata", stringsAsFactors = FALSE)
}

shinyApp(ui, server)