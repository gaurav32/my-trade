library("rredis")
library("forecast")
library("dtw")
library("tseries")
library("jsonlite")
library("foreach")
library("doParallel")
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

############################################################################################
#INPUT 
############################################################################################
#******************************** REDIS 
############################################################################################
redisConnect("127.0.0.1")

#raw_data<-redisHGetAll("BHEL")
#raw_data<-redisHGetAll("HINDALCO")
#raw_data<-redisHGetAll("GAURAV")

############################################################################################
#******************************** CSV
############################################################################################
#raw_data<-read.csv("/home/gaurav/Desktop/Disk/Office/TradingMarket/CodeBase/python/2_datadump/datadump/nifty50.csv")

############################################################################################
#******************************** DATA PREPARATION
############################################################################################
#Prepare a Graph depicting all symbols
#rediskeys <- redisKeys()

symbols <- names(redisHGetAll("SYMBOL"))

#Initialize data structures
key <- paste("CLOSE_",symbols[1],sep="")
	raw_data<-redisHGetAll(key)
	raw_data[names(raw_data)] <- as.numeric(raw_data[names(raw_data)])
	sorted_data <- raw_data[order(unlist(names(raw_data)), decreasing=FALSE)]
	data_matrix <- as.matrix(unlist(sorted_data))
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
plot(as.ts(final_low_high["PNB"]))

close_merged["date"] <- as.Date(rownames(close_merged), format = "%Y-%m-%d")
rownames(close_merged) <- NULL
close_merged["date"] <- as.Date(close_merged$date, format = "%Y-%m-%d")
final <- melt(close_merged ,  id = 'date')
ggplot(data=final, aes(x=date, y=value, colour=variable)) + geom_line()



#Code to find out repeating oscilation at regular interval
df <- as.ts(final_low_high["PNB"])
peaks <- findPeaks(df)
valleys <- findValleys(df)
peakfreqvariance <- var(diff(peaks))
valleyfreqvariance <- var(diff(valleys))
peakfreqmean <- mean(diff(peaks))
valleyfreqmean <- mean(diff(valleys))

if(peakfreqmean <= 3 && peakfreqvariance <= 0.95)
	#markeligible


#Raw Minute wise data in CSV
#Read CSV compute Min Max for day put in Redis - Min Max
#R Join Redis Min Max as time series data
#compute peaks and valleys
#compute mean of distances between peaks, valleys and variance associated with the mean. 
#compute mean change, min change, median change


#fulldataTs <- ts(dataframe)
#plot(as.Date(data$Timestamp, "%Y-%m-%d_%H:%M"), data$Price, xlab = "Timestamp", ylab = "Price", type = "l", col = "red", main = "Adjusted", xaxt = "n")
#axis.Date(side = 1, data$Timestamp, format = "%Y-%m-%d_%H:%M")

#rownames(raw_data) <- raw_data[,2]
#raw_data["Timestamp"]<-NULL
#raw_data["X"]<-NULL
#raw_data[is.na(raw_data)] <- 0
#final_dataframe <- raw_data[ order(row.names(raw_data)), ]

#ts.plot(final_dataframe,gpars= list(col=rainbow(10)))

############################################################################################
#******************************** PREPARE DATASET FOR VALIDATION
############################################################################################

#total <- append(sampledataTs, forecast$mean,length(sampledataTs))

############################################################################################
#******************************** GRAPHICAL DEPICTION - VALIDATION
############################################################################################
#Actual Data
#plot.ts(fulldataTs,col = "red", xlab = "Time", ylab = "% Gain/Loss", main = "Stock Matket Trend")

#Test Data + Predicted Data
#lines(total,col="red")
#mysummary("HINDALCO")
##################################################################################################
#	R LEARNINGS


#[1] "1463727900.0"
#> df[1]
#$`1463727900.0`
#[1] "88.00"
#attr(,"redis string value")
#[1] TRUE

#names(df[1]) df[[1]]
#stocks <- xts(df[[1]], order.by=as.Date(names(df[1]), "%Y-%m-%d_%H:%M:%S"))
