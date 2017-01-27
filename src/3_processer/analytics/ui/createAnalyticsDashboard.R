#library("shinythemes")
#library("shiny")
#library("timevis")

drawanalyticsdashboard <- function(id){
	# Create a namespace function using the provided id
	ns <- NS(id)

	tabsetPanel(
		tabPanel("WorldMarketsToday",
			wellPanel(
    				fluidRow(
					#timevisOutput("timeline")
        			)
        		)
        	)	
	)
}
