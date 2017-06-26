#library("shinythemes")
library("shiny")
#library("timevis")

drawnewsboardUI <- function(id, allnews){
	# Create a namespace function using the provided id
	ns <- NS(id)
#	wellPanel(
	fluidRow(
  		fluidRow(
			headerPanel(
				h5("NEWS FEED")
			),
        	column(6,
         		wellPanel(
        			h5("Latest News"),
           			#tags$b("This text is bold.")
           			#tags$marquee(tableOutput("latestnews"))
          			HTML(paste("<marquee scrolldelay='150' direction='up'>",allnews,"</marquee>",sep=""))
           		)
         	),
            column(6,
	    		wellPanel(
    	   			h5("Scheduled Events"),
      	   			tableOutput(ns("scheduledevent"))
        	   	)
           	)            			
		),
        fluidRow(
			headerPanel(
                h5("SENTIMETER")
            ),
			column(12,
               	wellPanel(
            			
    			)
			)
    	)
	)
}
