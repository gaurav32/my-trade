library("shiny")

drawanalyticsdashboard <- function(id, symbols){
	# Create a namespace function using the provided id
	ns <- NS(id)

	tabsetPanel(
		tabPanel("WorldMarketsToday",
			wellPanel(
    				fluidRow(
					#timevisOutput("timeline")
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
    							plotOutput(ns("highlowplot"))
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
					#timevisOutput("timeline")
  				)
        		)
        	)
	)
}
