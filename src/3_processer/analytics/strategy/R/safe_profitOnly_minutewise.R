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

raw_data<-read.csv("/home/gaurav/Desktop/BHEL.csv")
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

fulldataTs <- ts(dataframe)
dg<- dataframe
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
localTrendDuration <- 5
maxLossPcnt <- 0.05
maxLoss <- 0
currMinute <- 0
marketOpenMinute <- 0
tradeStartMinute <- marketOpenMinute+60
noMoreBuyMinute <- marketOpenMinute + nrow(dg) - 90
onlySellLastBuyMinute <- marketOpenMinute + nrow(dg) - 60
Minute <- 0
marketEndMinute <- 0


triggerBuy<- function(curr) {
    #       buy
    noOfBuys = noOfBuys + 1
    numberOfTickCycles <- -1
    lastBoughtPrice <- curr
    totalgain = totalgain - lastBoughtPrice
    cat(sprintf ("BUY: %f - LB: %f, G:%f \n",curr, lastBoughtPrice, totalgain))
}

triggerSell <- function(curr) {
    #       sell
    noOfSells = noOfSells + 1
    lastSoldPrice <- curr
    lastBoughtPrice <- 0
    totalgain = totalgain + lastSoldPrice
    prevTotalGain <- totalgain
    cat(sprintf ("SELL: %f - LSNC: %f, G:%f \n",curr, lastSoldPrice, totalgain))   
}



strategy <- function() {

for(i in 1:nrow(dg)) {
    curr <- as.numeric(dg[i,])
    currMinute <- i

    #Just once in a day - to initialize analytics data
    if(counter == 0){
        maxLoss <- curr*maxLossPcnt
        realTimeData <- tail(realTimeData, length(realTimeData) -1)
        realTimeDataMean <- tail(realTimeDataMean, length(realTimeDataMean) -1)
        buySellTrend <- tail(buySellTrend, length(buySellTrend) -1)
        gainTrend <- tail(gainTrend, length(gainTrend) -1)
        fullDayDataMean <- tail(fullDayDataMean, length(fullDayDataMean) -1)
    }

    #Control Buy and Sell Window - So that code doesnt mess up and we dont go on buying and loosing 
    if((noOfBuys-noOfSells) == 0){#ONLY BUY
        if(i < tradeStartMinute){# Learning period - No Buys
            doBuy <- FALSE
            doSell <- FALSE
        }else if(i >= tradeStartMinute && i <= noMoreBuyMinute){# bUYING ALLOWED ONLY BETWEEN 1Hr Post Start of Trading and 1.5 Hour Previous to End of Trading
            doBuy <- TRUE
            doSell <- FALSE
        }else if(i > noMoreBuyMinute && i <= onlySellLastBuyMinute){#Optimize Sale of Last bought Stock - No buys
            doBuy <- FALSE
            doSell <- FALSE
        }else if(i > onlySellLastBuyMinute){# bUYING ALLOWED ONLY BETWEEN 1Hr Post Start of Trading and 1.5 Hour Previous to End of Trading
            doBuy <- FALSE
            doSell <- FALSE
        }
    }else if((noOfBuys-noOfSells) > 0){#ONLY SELL
        if(i < tradeStartMinute){# Learning period - Condition Must Not come
            doBuy <- FALSE
            doSell <- FALSE
        }else if(i >= tradeStartMinute && i <= noMoreBuyMinute){# Selling ALLOWED 
            doBuy <- FALSE
            doSell <- TRUE
        }else if(i > noMoreBuyMinute && i <= onlySellLastBuyMinute){#Optimize Sale of Last bought Stock - No buys - Sale Allowed
            doBuy <- FALSE
            doSell <- TRUE
        }else if(i > onlySellLastBuyMinute){# Just SELL last bought stock
            doBuy <- FALSE
            doSell <- TRUE
        }
    }else if((noOfBuys-noOfSells) < 0){#CONDITION MUST NOT COME

    }

    #Analyse State
    realTimeData <- c(realTimeData, curr)
    counter <- counter + 1
    prevNMean <- mean(tail(realTimeData,localTrendDuration))
    realTimeDataMean <- c(realTimeDataMean, prevNMean)
    fullDayDataMean<- c(fullDayDataMean, mean(realTimeData))
    #prevNMean <- rollmean(realTimeData,10)
    #localPeaks = findPeaks(tail(realTimeData,10))
    #localValleys = findValleys(tail(realTimeData,10))
    #cat(sprintf ("CHANCE - C: %f - LB: %f, - LS: %f, M:%f ,Time:%s\n",curr, lastBoughtPrice, lastSoldPrice, prevNMean, i))
    localSlope = tail(realTimeDataMean, localTrendDuration)
    upwardTrend = FALSE
    downwardTrend = FALSE
    horizontalTrend = FALSE
    oscillatory = TRUE
    if(head(localSlope,1)<mean(localSlope) && mean(localSlope)<tail(localSlope,1)){
        upwardTrend = TRUE
    }else if(head(localSlope,1)>mean(localSlope) && mean(localSlope)>tail(localSlope,1)){
        downwardTrend = TRUE
    }else {

    }

    selllocalSlope = tail(realTimeDataMean, 2*localTrendDuration)
    if(head(selllocalSlope,1)>mean(selllocalSlope) && mean(selllocalSlope)>tail(selllocalSlope,1)){
        selldownwardTrend = TRUE
    }

    if(doBuy){
        cat(sprintf ("TREND: 1:%f - 2: %f, 3:%f, 4:%f\n",head(localSlope,1), mean(localSlope), tail(localSlope,1), i))
    
        if(upwardTrend){
            if(oscillatory){
                if(curr < as.numeric(dg[i-1,])){#Only 1 Trade(1 Buy must be sold first for any subsequent buy) at a time - Buy only 1 Share
                    triggerBuy(curr)
        #        }else if(curr < prevNMean && downwardTrend){#Only 1 Trade(1 Buy must be sold first for any subsequent buy) at a time - Buy only 1 Share
            #       buy
        #            noOfBuys = noOfBuys + 1
        #            numberOfTickCycles <- -1
        #            lastBoughtPrice <- curr
        #            totalgain = totalgain - lastBoughtPrice
        #            cat(sprintf ("BUY: %f - LB: %f, G:%f \n",curr, lastBoughtPrice, totalgain))
                }else if(curr < prevNMean && sd(localSlope) < 0.01){
                    triggerBuy(curr)
                }
            }else{

            }
        }else if(horizontalTrend){
            if(oscillatory){
            
            }else {

            }
        }else if(downwardTrend){
            if(oscillatory){
            
            }else {

            }
        }else{

        }
    }
    if(doSell){
        numberOfTickCycles <- numberOfTickCycles + 1
        if(curr > lastBoughtPrice){
            triggerSell(curr)    
        }

        if(i >= tradeStartMinute && i <= noMoreBuyMinute){# Selling ALLOWED 

        }else if(i > noMoreBuyMinute && i <= onlySellLastBuyMinute){
            if(curr < lastBoughtPrice - 0.8*prevTotalGain){# LIMIT TOTAL LOSS - Because 1 good trade(this final trade) cant cover ur gain u have made till now, so exit rather than losing more
                #       sell  - CAN BE CHANGED TO GIVE MORE CHANCE TO MAKE THIS LAST TRANSACTION PROFITABLE
                triggerSell(curr)                
            }
        }else if(i > onlySellLastBuyMinute){# IF COULDNT MAKE PROFIT in Optimization Window - JUST SELL AND LEAVE
            if(curr <= lastBoughtPrice){
                #       sell
                triggerSell(curr)                
            }
        }
    }
    buySellTrend <- c(buySellTrend, lastBoughtPrice)
    gainTrend <- c(gainTrend, prevTotalGain+lastBoughtPrice)
}

}


#Descriptives(testdataTs, plot = TRUE, r = 2, answer = 1, statistic = "ALL")
#attach(mtcars)
#par(mfrow=c(2,2))
plot.ts(realTimeData, xaxt = 'n')
#lines(buySellTrend,col="red")
lines(realTimeDataMean,col="blue")
lines(buySellTrend,col="red")
points(60,col="red")
axis(1, at=1:370)
#lines(fullDayDataMean,col="green")
#lines(CMA(realTimeData, 10),col="green")
#lines(CMA(realTimeData, 20),col="yellow")
#lines(EMA(realTimeData, 20),col="brown")

#plot.ts(diff(realTimeData))
noOfBuys
prevTotalGain
totalgain

strategy()