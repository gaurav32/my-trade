library("rredis")
library("forecast")
library("dtw")
library("tseries")
library("jsonlite")
library("foreach")
library("doParallel")
library("PerformanceAnalytics")
library("ggplot2")
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
#library("aws")

############################################################################################
#INPUT 
############################################################################################
#******************************** REDIS 
############################################################################################
redisConnect("127.0.0.1")

#raw_data<-redisHGetAll("BHEL")
#raw_data<-redisHGetAll("HINDALCO")
#raw_data<-redisHGetAll("AXISBANK")
#raw_data<-redisHGetAll("GAURAV")

############################################################################################
#******************************** CSV
############################################################################################

raw_data<-read.csv("/home/gaurav/Desktop/Disk/Office/TradingMarket/CodeBase/python/2_datadump/datadump/nifty50.csv")

############################################################################################
#******************************** DATA PREPARATION
############################################################################################


rownames(raw_data) <- raw_data[,2]
raw_data["Timestamp"]<-NULL
raw_data["X"]<-NULL
#raw_data[is.na(raw_data)] <- 0
final_dataframe <- raw_data[ order(row.names(raw_data)), ]


#colnames(dataframe) <- c("Timestamp", "Price")

#plot(as.Date(data$Timestamp, "%Y-%m-%d_%H:%M"), data$Price, xlab = "Timestamp", ylab = "Price", type = "l", col = "red", main = "Adjusted", xaxt = "n")
#axis.Date(side = 1, data$Timestamp, format = "%Y-%m-%d_%H:%M")

#key<-vector(mode="Date")
#data<-vector(mode="double")
#for(i in 1:length(sdf)){
#	key<-c(key,names(sdf[i]))
#	data<-c(data,as.numeric(sdf[[i]][1]))	
#}

############################################################################################
#******************************** ALGORITHM
############################################################################################

#monthplot(fulldataTs)
#Tells Mean Median etc fo the Time Series
#      V1       
#Min.   :115.8  
#1st Qu.:117.5  
#Median :119.0  
#Mean   :119.1  
#3rd Qu.:120.2  
#Max.   :122.8  
fulldataTs<- ts(dataframe)
testdataTs <- ts(dg<-subset(dataframe, as.Date(rownames(dataframe), "%Y-%m-%d_%H:%M") == "2016-05-23"))

newdataTs <- ts(dg<-subset(dataframe, as.Date(rownames(dataframe), "%Y-%m-%d_%H:%M") == "2016-05-24"))

summary(testdataTs)

peaks <- findPeaks(testdataTs)
valleys <- findValleys(testdataTs)
#timeseriescomponents <- decompose(testdataTs)

attach(mtcars)
par(mfrow=c(2,2))
plot.ts(testdataTs)
#lines(buySellTrend,col="red")
lines(SMA(testdataTs, 10),col="blue")
points(peaks,testdataTs[peaks],col="green")
points(valleys,testdataTs[valleys],col="red")

lines(buySellTrend,col="red")
lines(fullDayDataMean,col="blue")


plot.ts(diff(realTimeData))
