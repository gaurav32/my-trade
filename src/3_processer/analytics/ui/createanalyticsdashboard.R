library("shiny")
library("timelineprogress")
#library("timevis")
library("dygraphs")
library("ggplot2")

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
    					selectInput(ns("symbol"), "Symbol", choices = symbols)
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
	               				c("Year" = ns("year"),
			                	"2-Month" = ns("month2"),
                			 	"1-Month" = ns("month1")),
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
		dygraph(as.ts(finalallstocklowhigh[input$symbol]), main = "Stock Prices", width="100%") #%>%
		#dyRangeSelector(dateWindow = c("90", "100"))
		#dygraph(nhtemp, main = "Stock Prices", width="100%") %>%
		#dyRangeSelector(dateWindow = c("1920-01-01", "1921-01-01"))
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