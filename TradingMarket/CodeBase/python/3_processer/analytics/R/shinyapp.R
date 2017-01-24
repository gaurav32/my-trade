library("rredis")
library("forecast")
library("dtw")
library("tseries")
library("jsonlite")
library("foreach")
#library("doParallel")
library("PerformanceAnalytics")
library("ggplot2")
library("reshape2")
library("iterators")
library("zoo")
#library("seewave")
library("adwave")
library("biwavelet")
library("brainwaver")
library("futureheatwaves")
library("mvcwt")
library("seawaveQ")
library("W2CWM2C")
library("WaveletComp")
library("wavethresh")
library("wmtsa")
library("AnalyzeTS")
library("TTR")
library("quantmod")
library("lmtest")
library("dtw")
library("tsoutliers")
library("shinythemes")
library("shiny")
library("timevis")

####################################################################################################################################################################################
#INPUT 
####################################################################################################################################################################################
#******************************** REDIS 
####################################################################################################################################################################################
redisConnect("127.0.0.1")

#raw_data<-redisHGetAll("BHEL")
#raw_data<-redisHGetAll("HINDALCO")
#raw_data<-redisHGetAll("GAURAV")

####################################################################################################################################################################################
#******************************** CSV
####################################################################################################################################################################################
#raw_data<-read.csv("/home/gaurav/Desktop/Disk/Office/TradingMarket/CodeBase/python/2_datadump/datadump/nifty50.csv")

####################################################################################################################################################################################
#******************************** DATA PREPARATION
####################################################################################################################################################################################
#Prepare a Graph depicting all symbols
#rediskeys <- redisKeys()
worldstockexchangetimeings <- fromJSON(redisGet("WSI"))


scheduledevents <- redisHGetAll("EVENTS")
events <- colnames(as.data.frame(scheduledevents))
allnews <- ""
for(row in events){
	allnews <- paste(row,allnews,sep="\n")
}

symbols <- sort(names(redisHGetAll("SYMBOL")),decreasing = FALSE)

#Initialize data structures
key <- paste("CLOSE_",symbols[1],sep="")

raw_data<-redisHGetAll(key)
raw_data[names(raw_data)] <- as.numeric(raw_data[names(raw_data)])
data_matrix <- as.matrix(unlist(raw_data[order(unlist(names(raw_data)), decreasing=FALSE)]))

close_merged<-as.data.frame(data_matrix)[,0]
low_merged<-as.data.frame(data_matrix)[,0]
high_merged<-as.data.frame(data_matrix)[,0]


#Function that helps merge data for all symbols in single dataframe - for comparative study
mergefunc <- function(merged,key) {
	raw_data<-redisHGetAll(key)
	raw_data[names(raw_data)] <- as.numeric(raw_data[names(raw_data)])
	sorted_data <- raw_data[order(unlist(names(raw_data)), decreasing=FALSE)]
	data_matrix <- as.matrix(unlist(sorted_data))
	dataframe<-as.data.frame(data_matrix)
	#dataframe[,1] <- ((dataframe[,1] - dataframe[1,])*100)/dataframe[1,]
	colnames(dataframe)[1] <- key
	merged <- merge(merged, dataframe, by=0, all=TRUE)
	rownames(merged) <- merged[,1]	
	merged[,1]	<- NULL

  return(merged)
}

#Populate All the Dataframes - contain all high, low, close, volume data ets for all the symbols
for (symbol in symbols){
	close_merged <- mergefunc(close_merged,paste("CLOSE_",symbol,sep=""))
	low_merged <- mergefunc(low_merged,paste("MIN_",symbol,sep=""))
	high_merged <- mergefunc(high_merged,paste("MAX_",symbol,sep=""))
}

####################################################################################################################################################################################

#USECASE 1 - graph for everyday's HIGH LOW
final_low_high <- data.frame(1)
for (symbol in symbols){
	symbol_low_high <- data.frame(Doubles=double())
	for(row in rownames(close_merged)){			
		symbol_low_high <- rbind(symbol_low_high, low_merged[row,paste("MIN_",symbol,sep="")],high_merged[row,paste("MAX_",symbol,sep="")])
	}
	colnames(symbol_low_high) <- symbol
	final_low_high <- cbind(final_low_high, symbol_low_high)
}
final_low_high[,1]	<- NULL
#plot(as.ts(final_low_high["PNB"]))

final_low_high_year <- final_low_high
final_low_high_2month <- tail(final_low_high,120)
final_low_high_1month <- tail(final_low_high,60)


####################################################################################################################################################################################

#USECASE 2 - 
#		% changes in HIGH of previous day to LOW of next day
#		% changes in LOW of previous day to HIGH of next day
final_prevdaylow_to_nextdayhigh <- data.frame(1)
final_prevdayhigh_to_nextdaylow <- data.frame(1)
records <- nrow(final_low_high)
for (symbol in symbols){
	symbol_prevdaylow_to_nextdayhigh <- data.frame(Doubles=double())
	symbol_prevdayhigh_to_nextdaylow <- data.frame(Doubles=double())
	for (rowIndx in 1:records){
		if(rowIndx %% 2 && rowIndx+3 <= records && rowIndx+1 <= records){
			day_low <- final_low_high[rowIndx,symbol]
			day_high <- final_low_high[rowIndx+1,symbol]
			next_day_low <- final_low_high[rowIndx+2,symbol]
			next_day_high <- final_low_high[rowIndx+3,symbol]
			symbol_prevdaylow_to_nextdayhigh <- rbind(symbol_prevdaylow_to_nextdayhigh,(next_day_high - day_low)*100/day_low)
			symbol_prevdayhigh_to_nextdaylow <- rbind(symbol_prevdayhigh_to_nextdaylow,(day_high - next_day_low)*100/next_day_low)
		}
	}
	colnames(symbol_prevdaylow_to_nextdayhigh) <- symbol
	colnames(symbol_prevdayhigh_to_nextdaylow) <- symbol
	final_prevdaylow_to_nextdayhigh <- cbind(final_prevdaylow_to_nextdayhigh, symbol_prevdaylow_to_nextdayhigh)		
	final_prevdayhigh_to_nextdaylow <- cbind(final_prevdayhigh_to_nextdaylow, symbol_prevdayhigh_to_nextdaylow)
}
final_prevdaylow_to_nextdayhigh[,1]	<- NULL
final_prevdayhigh_to_nextdaylow[,1]	<- NULL

####################################################################################################################################################################################

#RULE1 - Mean, Variance
#RULE DEFINITION
#Min > 0, 25Percentile > 1%gain, Mean ~ 3%change ---------- Can earn you 2Rs on safer side
final_acrossdaychange <- data.frame(1)
final_rule1_satisfying_stocks <- data.frame(1)
row_names_final_acrossdaychange <- rbind("Y0%ile","2M0%ile","1M0%ile","Y%ile-S","2M%ile-S","1M%ile-S","Y%ile-0","2M%ile-0","1M%ile-0","Y%ile-0.75","2M%ile-0.75","1M%ile-0.75","Y%ile-1","2M%ile-1","1M%ile-1","Y%ile-1.5","2M%ile-1.5","1M%ile-1.5","Mean","Std. Devtn","75%ile","Max")
for (symbol in symbols){
	temp_col <- data.frame(Doubles=double())
	asts <- as.ts(final_prevdaylow_to_nextdayhigh[symbol])
	#temp_col <- rbind(temp_col, min(asts))
	temp_col <- rbind(temp_col, quantile(asts,0))
	temp_col <- rbind(temp_col, quantile(tail(asts,60),0))
	temp_col <- rbind(temp_col, quantile(tail(asts,30),0))
	temp_col <- rbind(temp_col, ecdf(asts)(quantile(tail(asts,30),0)+.15)*100)
	temp_col <- rbind(temp_col, ecdf(tail(asts,60))(quantile(tail(asts,30),0)+.15)*100)
	temp_col <- rbind(temp_col, ecdf(tail(asts,30))(quantile(tail(asts,30),0)+.15)*100)
	temp_col <- rbind(temp_col, ecdf(asts)(0)*100)
	temp_col <- rbind(temp_col, ecdf(tail(asts,60))(0)*100)
	temp_col <- rbind(temp_col, ecdf(tail(asts,30))(0)*100)
	temp_col <- rbind(temp_col, ecdf(asts)(0.75)*100)
	temp_col <- rbind(temp_col, ecdf(tail(asts,60))(0.75)*100)
	temp_col <- rbind(temp_col, ecdf(tail(asts,30))(0.75)*100)
	temp_col <- rbind(temp_col, ecdf(asts)(1)*100)
	temp_col <- rbind(temp_col, ecdf(tail(asts,60))(1)*100)
	temp_col <- rbind(temp_col, ecdf(tail(asts,30))(1)*100)
	temp_col <- rbind(temp_col, ecdf(asts)(1.5)*100)
	temp_col <- rbind(temp_col, ecdf(tail(asts,60))(1.5)*100)
	temp_col <- rbind(temp_col, ecdf(tail(asts,30))(1.5)*100)
	temp_col <- rbind(temp_col, mean(asts))
	#temp_col <- rbind(temp_col, var(asts)[1])
	temp_col <- rbind(temp_col, sd(asts))
	temp_col <- rbind(temp_col, quantile(asts)[4])#25Percentile
	temp_col <- rbind(temp_col, max(asts))

	colnames(temp_col) <- symbol
	final_acrossdaychange <- cbind(final_acrossdaychange, temp_col)		

	if(min(asts) > 0 && quantile(asts)[2] > 1.0 && mean(asts) > 2){
		final_rule1_satisfying_stocks <- cbind(final_rule1_satisfying_stocks, temp_col)				
	}
}
final_acrossdaychange[,1]	<- NULL
rownames(final_acrossdaychange) <- row_names_final_acrossdaychange
final_rule1_satisfying_stocks[,1]	<- NULL
rownames(final_rule1_satisfying_stocks) <- row_names_final_acrossdaychange

predictarima<- function(data){

}

####################################################################################################################################################################################

predictarima<- function(symb){
	trainDataDays<-7
	symb="PNB"
	autoarimatraindata <- tail(final_low_high[symb],2*trainDataDays)
	#fit<-auto.arima(autoarimatraindata)
	fit<-HoltWinters(autoarimatraindata,gamma=FALSE)
	summary(fit)
	forecastvalues<-as.data.frame(forecast(fit,2))
	
	forecastvalues
	#plot(autoarimatraindata)
	#lines(as.ts(forecastvalues[,1]),col="red")
	#predLow<-forecastvalues[1,1]
	#predHigh<-forecastvalues[2,1]
}

close_merged["date"] <- as.Date(rownames(close_merged), format = "%Y-%m-%d")
rownames(close_merged) <- NULL
close_merged["date"] <- as.Date(close_merged$date, format = "%Y-%m-%d")


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

####################################################################################################################################################################################
#OUPUT 
#Interactive Use Interface
####################################################################################################################################################################################

ui <- fluidPage(theme = "bootstrap.css",
    #titlePanel("TRADING"),
    fluidRow(
        sidebarLayout(position = "right",
        	sidebarPanel(
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
            	   			tableOutput("scheduledevent")
            	   		)
            		)            		
            	),
            	fluidRow(
	            	wellPanel(
            			h5("SENTIMETER")
            		)
            	)
        	),
        	mainPanel(
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
    								selectInput("symbol", "Symbol", choices = symbols)
    							),
    							column(8,
    								wellPanel(
    									plotOutput("highlowplot")
    								)
    							)
        					)
        				)
        			),
        			tabPanel("IndiaOptions",
   						wellPanel(
    						fluidRow(
								selectInput("options", "Options", choices = symbols)
        					)
        				)
        			),
        			tabPanel("IndiaCommodity",
   						wellPanel(
    						fluidRow(
								timevisOutput("timeline")
        					)
        				)
        			)
        		)
        	)
        )
    )
)

server <- function(input, output, session) {

    output$highlowplot <- renderPlot({
        plot(as.ts(final_low_high[input$symbol]))
        #lines(as.ts(final_arima_prediction_values[input$symbol]),col="red")
        #ggplot(filtered, aes(Alcohol_Content)) +
        #geom_histogram()
    })

    output$latestnews <- renderTable({
		
    })
    #output$prevlownexthighplot <- renderPlot({
        #plot(as.ts(final_prevdaylow_to_nextdayhigh[input$symbol]))
    #      plot(tsclean(as.ts(final_low_high[input$symbol])))
    #})

    #output$arimaresults <- renderTable({
    #    predictarima(input$symbol)
    #})

    #output$results <- renderTable({
    #    final_acrossdaychange[input$symbol]
    #})

    #output$rule1result <- renderTable({
    #    final_rule1_satisfying_stocks
    #})

    #output$rule2result <- renderTable({
    #      final_arima_prediction_validation_score
    #})

    output$timeline <- renderTimevis({
    	timevis(data)
  	})
}

shinyApp(ui = ui, server = server)

####################################################################################################################################################################################

#References
#https://daattali.com/shiny/timevis-demo/
####################################################################################################################################################################################