library("rredis")
library("tseries")

####################################################################################################################################################################################
#INPUT 
####################################################################################################################################################################################
#******************************** REDIS 
####################################################################################################################################################################################
redisConnect("127.0.0.1")

####################################################################################################################################################################################
#******************************** CSV
####################################################################################################################################################################################
#raw_data<-read.csv("/home/gaurav/Desktop/Disk/Office/TradingMarket/CodeBase/python/2_datadump/datadump/nifty50.csv")

####################################################################################################################################################################################
#******************************** DATA PREPARATION
####################################################################################################################################################################################

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

getAllSymbols <- function(){
	symbols
}

getAllStockLowHigh <- function(){
	final_low_high
}

getAllStockLow <- function(){
	low_merged
}

getAllStockHigh <- function(){
	high_merged
}
