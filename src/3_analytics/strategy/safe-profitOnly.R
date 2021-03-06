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
#raw_data<-redisHGetAll("ADANIPORTS")
#raw_data<-redisHGetAll("GAURAV")

############################################################################################
#******************************** CSV
############################################################################################
#raw_data<-read.csv("/home/gaurav/Desktop/Disk/Office/TradingMarket/CodeBase/python/2_datadump/datadump/BHEL.csv")

raw_data<-read.csv("/home/gaurav/Desktop/BHEL12Jun.csv")
############################################################################################
#******************************** DATA PREPARATION
############################################################################################

sorted_data <- raw_data[order(unlist(names(raw_data)), decreasing=FALSE)]
data_matrix <- as.matrix(sorted_data)
dataframe<-as.data.frame(data_matrix)

#colnames(dataframe) <- c("Timestamp", "Price")

#plot(as.Date(data$Timestamp, "%Y-%m-%d_%H:%M"), data$Price, xlab = "Timestamp", ylab = "Price", type = "l", col = "red", main = "Adjusted", xaxt = "n")
#axis.Date(side = 1, data$Timestamp, format = "%Y-%m-%d_%H:%M")

#key<-vector(mode="Date")
#data<-vector(mode="double")
#for(i in 1:length(sdf)){
#	key<-c(key,names(sdf[i]))
#	data<-c(data,as.numeric(sdf[[i]][1]))	
#}

dg<-subset(dataframe, as.Date(rownames(dataframe), "%Y-%m-%d_%H:%M") == "2016-05-24")
fulldataTs <- ts(dg)

############################################################################################
#******************************** ALGORITHM
############################################################################################

#monthplot(fulldataTs)
#Tells Mean Median etc fo the Time Series
summary(fulldataTs)
#      V1       
#Min.   :115.8  
#1st Qu.:117.5  
#Median :119.0  
#Mean   :119.1  
#3rd Qu.:120.2  
#Max.   :122.8  

realTimeData <- ts(numeric(1))
realTimeDataMean <- ts(numeric(1))
fullDayDataMean <- ts(numeric(1))
buySellTrend <- ts(numeric(1))
gainTrend <- ts(numeric(1))
doBuy <- FALSE
doSell <- FALSE
noOfBuys <- 0
noOfSells <- 0
prevTotalGain <- 0
totalgain <- 0
lastBoughtPrice <- 0
lastSoldPrice <- 0
prevNMean <- 0
counter <-0
numberOfTickCycles <- -1
brokerage <- 0.0001
max_shares <- 10
for(i in 1:nrow(dg)) {
    curr <- as.numeric(dg[i,])
#for(rec in dg){
#    curr <- as.numeric(rec[[1]])
    if(counter == 0){
        realTimeData <- tail(realTimeData, length(realTimeData) -1)
        realTimeDataMean <- tail(realTimeDataMean, length(realTimeDataMean) -1)
        buySellTrend <- tail(buySellTrend, length(buySellTrend) -1)
        gainTrend <- tail(gainTrend, length(gainTrend) -1)
        fullDayDataMean <- tail(fullDayDataMean, length(fullDayDataMean) -1)
    }

    if((noOfBuys-noOfSells) == 0){
        if(difftime(strptime(names(dg[i,]),"%Y-%m-%d_%H:%M"),strptime("2016-05-24_12:30","%Y-%m-%d_%H:%M")) > 0 
            && difftime(strptime("2016-05-24_14:30","%Y-%m-%d_%H:%M"),strptime(names(dg[i,]),"%Y-%m-%d_%H:%M")) > 0){
            doBuy <- TRUE
            #cat(sprintf ("BUY - C: %f - LB: %f, - LS: %f, M:%f ,Time:%s\n",curr, lastBoughtPrice, lastSoldPrice, prevNMean, names(dg[i,])))
        }
        doSell <- FALSE
    }else{
        doBuy <- FALSE
        doSell <- TRUE
    }

    realTimeData <- c(realTimeData, curr)
    counter <- counter + 1
    prevNMean <- mean(tail(realTimeData,20))
    realTimeDataMean <- c(realTimeDataMean, prevNMean)
    fullDayDataMean<- c(fullDayDataMean, mean(realTimeData))
    #prevNMean <- rollmean(realTimeData,10)
    cat(sprintf ("CHANCE - C: %f - LB: %f, - LS: %f, M:%f ,Time:%s\n",curr, lastBoughtPrice, lastSoldPrice, prevNMean, names(dg[i,])))
    
    if(doBuy){
        if(curr > prevNMean){#Only 1 Trade(1 Buy must be sold first for any subsequent buy) at a time - Buy only 1 Share
    #       buy
            noOfBuys = noOfBuys + 1
            numberOfTickCycles <- -1
            lastBoughtPrice <- curr
            totalgain = totalgain - lastBoughtPrice
            cat(sprintf ("C: %f - LB: %f, G:%f \n",curr, lastBoughtPrice, totalgain))
        }
    }
    if(doSell){
        numberOfTickCycles <- numberOfTickCycles + 1
        if(curr > lastBoughtPrice){#CONTROL GREED Over a period of 5 ticks
    #       sell
            noOfSells = noOfSells + 1
            lastSoldPrice <- curr
            lastBoughtPrice <- 0
            totalgain = totalgain + lastSoldPrice
            prevTotalGain <- totalgain
            cat(sprintf ("C: %f - LSNC: %f, G:%f \n",curr, lastSoldPrice, totalgain))
        }else if(TRUE){

        }
    }
    buySellTrend <- c(buySellTrend, lastBoughtPrice)
    gainTrend <- c(gainTrend, prevTotalGain+lastBoughtPrice)
}
noOfBuys
prevTotalGain
#Descriptives(testdataTs, plot = TRUE, r = 2, answer = 1, statistic = "ALL")
attach(mtcars)
par(mfrow=c(2,2))
plot.ts(realTimeData)
#lines(buySellTrend,col="red")
lines(realTimeDataMean,col="green")
lines(buySellTrend,col="red")
lines(fullDayDataMean,col="blue")
lines(CMA(realTimeData, 5),col="pink")
lines(CMA(realTimeData, 20),col="yellow")
lines(EMA(realTimeData, 20),col="brown")

plot.ts(diff(realTimeData))

with(dataframe, plot(as.Date(rownames(dataframe), "%Y-%m-%d_%H:%M"), dataframe$V1, xaxt="n"))
axis.Date(1, at=seq(min(as.Date(rownames(dataframe), "%Y-%m-%d_%H:%M")), max(as.Date(rownames(dataframe), "%Y-%m-%d_%H:%M")), by="1 day"), format="%d-%m")



dg<-subset(dataframe, as.Date(rownames(dataframe), "%Y-%m-%d_%H:%M") == "2016-05-24")

with(dg, plot(strptime(rownames(dg), "%Y-%m-%d_%H:%M"), dg$V1, xaxt="n"))
axis.Date(1, at=seq(min(strptime(rownames(dg), "%Y-%m-%d_%H:%M")), max(strptime(rownames(dg), "%Y-%m-%d_%H:%M")), by="1 min"), format="%d-%m-%H:%M")
#axis.Date(1, at=seq(min(strptime(rownames(dg), "%Y-%m-%d_%H:%M")), max(strptime(rownames(dg), "%Y-%m-%d_%H:%M")), by="1 min"), format="%d-%m-%H:%M")



#plot(as.Date(data$Timestamp, "%Y-%m-%d_%H:%M"), data$Price, xlab = "Timestamp", ylab = "Adjusted closing price", type = "l", col = "red", main = "Adjusted closing price of INFOSYS for past 1 year", xaxt = "n")
#axis.Date(side = 1, data$Timestamp, format = "%Y-%m-%d_%H:%M")
#plot.ts(dataTs,col = "red", xlab = "Time", ylab = "% Gain/Loss", main = "Stock Matket Trend")

#pred <- predict(fit, n.ahead = 200)
#pred
#lowForecast<-forecast$lower[,2]
#upForecast<-forecast$upper[,2]
#total <- append(dataTs, pred$pred,length(dataTs))
#totalF<-vector(mode="character")

#for(i in 1:length(forecast)){
#	totalF<-c(totalF,forecast[[i]][1])	
#}


#totalF$mean
#totalF$sigma2

#lines(10^(pred$pred),col=”blue”)
#lines(10^(pred$pred+2*pred$se),col=”orange”)
#lines(10^(pred$pred-2*pred$se),col=”orange”)

#http://ucanalytics.com/blogs/step-by-step-graphic-guide-to-forecasting-through-arima-modeling-in-r-manufacturing-case-study-example/



###############################################################################
# Load Systematic Investor Toolbox (SIT)
# http://systematicinvestor.wordpress.com/systematic-investor-toolbox/
###############################################################################
 
    #*****************************************************************
    # Load historical data
    #****************************************************************** 
    #load.packages('quantmod')   
    #tickers = 'SPY'
 
    #data = getSymbols(tickers, src = 'yahoo', from = '1950-01-01', auto.assign = F)
 
    #*****************************************************************
    # Euclidean distance, one to one mapping
    #****************************************************************** 
    #obj = bt.matching.find(Cl(data), normalize.fn = normalize.mean, dist.fn = 'dist.euclidean', plot=T)
 
    #matches = bt.matching.overlay(obj, plot.index=1:90, plot=T)
 
    #layout(1:2)
    #matches = bt.matching.overlay(obj, plot=T, layout=T)
    #bt.matching.overlay.table(obj, matches, plot=T, layout=T)


############################################################################################
#******************************** PREPARE DATASET FOR VALIDATION
############################################################################################

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

#z <- tapply(X=tS[,"End.Equity"],INDEX=list(Fast=tS[,1],Slow=tS[,2]),FUN=sum)
#z[1:5,1:10]
#x <- as.numeric(rownames(z))
#y <- as.numeric(colnames(z))
#filled.contour(x=x,y=y,z=z,color = heat.colors,xlab="Fast MA",ylab="Slow MA")

#t <- strptime(rownames(dg), "%Y-%m-%d_%H:%M")
