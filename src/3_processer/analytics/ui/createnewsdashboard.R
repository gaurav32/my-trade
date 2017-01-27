#library("shinythemes")
library("shiny")
#library("timevis")

drawnewsboard <- function(id, allnews){
	# Create a namespace function using the provided id
	ns <- NS(id)
	wellPanel(
       	fluidRow(
          	h5("NEWS FEED")
        ),
  	fluidRow(
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
	            	wellPanel(
            			h5("SENTIMETER")
            		)
        )
	)
}
