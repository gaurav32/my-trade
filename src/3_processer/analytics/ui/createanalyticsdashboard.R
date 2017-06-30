library("shiny")
library("timelineprogress")
#library("timevis")
library("dygraphs")
library("ggplot2")
library("xts")

drawanalyticsdashboardUI <- function(id){
	# Create a namespace function using the provided id
	ns <- NS(id)

	tabsetPanel(
		tabPanel("WorldMarketsToday",
			wellPanel(
    				fluidRow(
						#timelineprogressOutput(ns("worldmarketprogress"))
        			)
        		)
        	),	
		tabPanel("IndiaStocks",
			wellPanel(
				fluidRow(
					column(4,
    					selectInput(ns("symbol"), "Symbol", choices = symbols),
    					radioButtons(ns("stockanalytics"), "StockAnalytics :",
	               				c("Stock Low High Prices" = "stocklowhighprice",
	               				"SureShot1% Across Day" = "sureshot1percent",
                			 	"SureShot2% Across Day" = "sureshot2percent",
                			 	"SureShot3% Across Day" = "sureshot3percent",
                			 	"SureShot4% Across Day" = "sureshot4percent",
                			 	"SureShot5% Across Day" = "sureshot5percent"),
			               		inline = TRUE)
	    			),
    				column(8,
	    				wellPanel(
							dygraphOutput(ns("stockgraph"))
	    				)
    				)
	       		),
				fluidRow(
		          	column(4,
		          		radioButtons(ns("dist"), "Distribution type:",
	               				c("Year" = "year",
			                	"2-Month" = "month2",
                			 	"1-Month" = "month1"),
			               		inline = TRUE),
		          	 	sliderInput(ns("obs"), "Number of observations:", min = 1, max = 1000, value = 500)
		          	),
          			column(8,
		          		wellPanel(
          					conditionalPanel(
         						condition = "input$dist == 'month1'",
         						sliderInput(ns("breakCount"), "Break Count", min=1, max=1000, value=10)
	     					)
	          			)
					)
       			)
			)
		),
        tabPanel("IndiaOptions",
   			wellPanel(
    			fluidRow(
					selectInput(ns("options"), "Options", choices = symbols)
        		)
        	)
       	),
       	tabPanel("IndiaCommodity",
   			wellPanel(
   				fluidRow(
#					timevisOutput(ns("timeline"))
  				)
        	)
        )
	)
}

drawanalyticsdashboard <- function(input, output, session, stringsAsFactors) {
	#output$worldmarketprogress <- renderTimelineprogress({
    #		timelineprogress(data)
  	#})

	observe({
    	msg <- sprintf("Updating Analytics dashboard....")
    	cat(msg, "\n")
  	})

	output$stockgraph <- renderDygraph({

    sureshot1percentdata <- as.xts(as.ts(sureshot1profitstocks[input$symbol]))
    colnames(sureshot1percentdata)[1] <- "sureshot1percentdata"
    sureshot2percentdata <- as.xts(as.ts(sureshot2profitstocks[input$symbol]))
    colnames(sureshot2percentdata)[1] <- "sureshot2percentdata"
    sureshot3percentdata <- as.xts(as.ts(sureshot3profitstocks[input$symbol]))
    colnames(sureshot3percentdata)[1] <- "sureshot3percentdata"
    sureshot4percentdata <- as.xts(as.ts(sureshot4profitstocks[input$symbol]))
    colnames(sureshot4percentdata)[1] <- "sureshot4percentdata"
    sureshot5percentdata <- as.xts(as.ts(sureshot5profitstocks[input$symbol]))
    colnames(sureshot5percentdata)[1] <- "sureshot5percentdata"

    everydayhighlowdiffpercentdata <- as.xts(as.ts(everydayhighlowdiffpercent[input$symbol]))
    colnames(everydayhighlowdiffpercentdata)[1] <- "everydayhighlowdiffpercentdata"
    datacompare1 <- cbind(sureshot1percentdata=sureshot1percentdata, everydayhighlowdiffpercentdata=everydayhighlowdiffpercentdata)
    datacompare2 <- cbind(sureshot2percentdata=sureshot2percentdata, everydayhighlowdiffpercentdata=everydayhighlowdiffpercentdata)
    datacompare3 <- cbind(sureshot3percentdata=sureshot3percentdata, everydayhighlowdiffpercentdata=everydayhighlowdiffpercentdata)
    datacompare4 <- cbind(sureshot4percentdata=sureshot4percentdata, everydayhighlowdiffpercentdata=everydayhighlowdiffpercentdata)
    datacompare5 <- cbind(sureshot5percentdata=sureshot5percentdata, everydayhighlowdiffpercentdata=everydayhighlowdiffpercentdata)

		type <- input$stockanalytics
  		switch(type,
  			stocklowhighprice = dygraph(as.ts(finalallstocklowhigh[input$symbol]), main = "Stock Prices", width="100%") %>% dyRangeSelector(),
       	sureshot1percent = dygraph(datacompare1, main = "Stock Prices Trend", width="100%") %>% dySeries("sureshot1percentdata", label = "TodLow_TomHigh_1%_inDays") %>% dySeries("everydayhighlowdiffpercentdata", label = "TodLow_TodHigh") %>% dyRangeSelector(),
  			sureshot2percent = dygraph(datacompare2, main = "Stock Prices Trend", width="100%") %>% dySeries("sureshot2percentdata", label = "TodLow_TomHigh_2%_inDays") %>% dySeries("everydayhighlowdiffpercentdata", label = "TodLow_TodHigh") %>% dyRangeSelector(),
       	sureshot3percent = dygraph(datacompare3, main = "Stock Prices Trend", width="100%") %>% dySeries("sureshot3percentdata", label = "TodLow_TomHigh_3%_inDays") %>% dySeries("everydayhighlowdiffpercentdata", label = "TodLow_TodHigh") %>% dyRangeSelector(),
  			sureshot4percent = dygraph(datacompare4, main = "Stock Prices Trend", width="100%") %>% dySeries("sureshot4percentdata", label = "TodLow_TomHigh_4%_inDays") %>% dySeries("everydayhighlowdiffpercentdata", label = "TodLow_TodHigh") %>% dyRangeSelector(),
       	sureshot5percent = dygraph(datacompare5, main = "Stock Prices Trend", width="100%") %>% dySeries("sureshot5percentdata", label = "TodLow_TomHigh_5%_inDays") %>% dySeries("everydayhighlowdiffpercentdata", label = "TodLow_TodHigh") %>% dyRangeSelector(),
  		)

  	})

}

drawanalyticsdataUI <- function(id){
	# Create a namespace function using the provided id
	ns <- NS(id)

	wellPanel(
		fluidRow(
        	column(12,
          		dataTableOutput(ns('datatable'))
        	)
      	)
	)

}

drawanalyticsdata <- function(input, output, session, stringsAsFactors) {

	observe({
    	msg <- sprintf("Updating Analytics data....")
    	cat(msg, "\n")
  	})

	output$datatable <- renderDataTable({
		sureshotprofitstocks
	})
}