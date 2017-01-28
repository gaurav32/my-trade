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
							#```{r, fig.width=6, fig.height=2.5}
							dygraph(nhtemp, main = "Stock Prices", width="100%") %>%
							dyRangeSelector(dateWindow = c("1920-01-01", "1921-01-01"))
							#```
	    					)
    					)
	        		),
				fluidRow(
		          		column(4,
		          	 		radioButtons(ns("dist"), "Distribution type:",
	               					c("Year" = ns("year"),
			                 		"2-Month" = ns("month2"),
                			 		"1-Month" = ns("month1")),
			               			inline = TRUE),
		          	 		sliderInput(ns("obs"), "Number of observations:", min = 1, max = 1000, value = 500)
		          		),
          				column(8,
		          			wellPanel(
          						conditionalPanel(
         							condition = "input.dist == 'month1'",
         							sliderInput(ns("breakCount"), "Break Count", min=1, max=1000, value=10)
		      					)
          						#selectInput("symbol", "Symbol", choices = symbols)
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
