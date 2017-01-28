library("shiny")
library("timelineprogress")
#library("timevis")
library(dygraphs)

drawanalyticsdashboardOutput <- function(id, symbols){
	# Create a namespace function using the provided id
	ns <- NS(id)

	tabsetPanel(
		tabPanel("WorldMarketsToday",
			wellPanel(
    				fluidRow(
					timelineprogressOutput(ns("worldmarketprogress"))
        			)
        		)
        	),	
		tabPanel("IndiaStocks",
			wellPanel(
				fluidRow(
					column(4,
    						selectInput(ns("symbol"), "Symbol", choices = symbols)
	    				),
    					column(8,
	    					wellPanel(
    							#plotOutput(ns("highlowplot"))
							dygraph(nhtemp, main = "Stock Prices") %>%
							dyRangeSelector(dateWindow = c("1920-01-01", "1921-01-01"))
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

drawanalyticsdashboard <- function(input, output, session, stringsAsFactors){
	output$worldmarketprogress <- renderTimelineprogress({
    		timelineprogress(data)
  	})
}
