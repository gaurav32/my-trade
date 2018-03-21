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

dg <<- dataframe

############################################################################################
#******************************** ALGORITHM
############################################################################################

#Permanent Variables
realTimeData <<- ts(numeric(1))
realTimeData <<- tail(realTimeData, length(realTimeData) -1)
buySellTrend <<- ts(numeric(1))
buySellTrend <<- tail(buySellTrend, length(buySellTrend) -1)
gainTrend <<- ts(numeric(1))
gainTrend <<- tail(gainTrend, length(gainTrend) -1)
realTimeDataMean <<- ts(numeric(1))
realTimeDataMean <<- tail(realTimeDataMean, length(realTimeDataMean) -1)
fullDayDataMean <<- ts(numeric(1))
fullDayDataMean <<- tail(fullDayDataMean, length(fullDayDataMean) -1)

noOfBuys <<- 0
noOfSells <<- 0
prevTotalGain <<- 0
totalgain <<- 0
totalTicks <<- 0

#Constants
brokerage <<- 0.0001
maxLossPcnt <<- 0.05
maxLoss <<- 0
marketOpenMinute <<- 0
tradeStartMinute <<- marketOpenMinute+60
noMoreBuyMinute <<- marketOpenMinute + nrow(dg) - 90
onlySellLastBuyMinute <<- marketOpenMinute + nrow(dg) - 60
marketEndMinute <<- 0

#Temporary Variables
numberOfTickCycles <<- -1
lastBoughtPrice <<- 0
lastSoldPrice <<- 0
currentPrice <<- 0
currMinute <<- 0

triggerBuy<- function() {
    #       buy
    noOfBuys <<- noOfBuys + 1
    numberOfTickCycles <<- -1
    lastBoughtPrice <<- currentPrice
    totalgain <<- totalgain - lastBoughtPrice
    cat(sprintf ("BUY: %f - LB: %f, G:%f \n",currentPrice, lastBoughtPrice, totalgain))
}

triggerSell <- function() {
    #       sell
    noOfSells <<- noOfSells + 1
    lastSoldPrice <<- currentPrice
    lastBoughtPrice <<- 0
    totalgain <<- totalgain + lastSoldPrice
    prevTotalGain <<- totalgain
    cat(sprintf ("SELL: %f - LSNC: %f, G:%f \n",currentPrice, lastSoldPrice, totalgain))   
}

getCurrentMinute <- function(tick, actualTime=FALSE) {
	if(actualTime){
		0
	}else{
		tick
	}
}

init <- function(){

}

strategy <- function() {

	init()

	for(i in 1:nrow(dg)) {

    	currentPrice <<- as.numeric(dg[i,])
    	currMinute <<- getCurrentMinute(i)

		if(totalTicks == 0){
			maxLoss <<- currentPrice*maxLossPcnt
		}

		totalTicks <<- totalTicks + 1
    	realTimeData <<- c(realTimeData, currentPrice)


	    #Control BUY and SELL WINDOW - So that code doesnt mess up and we dont go on buying and loosing 
	        if(i <= tradeStartMinute){# Learning period - No Buys
	        	if((noOfBuys-noOfSells) == 0){
	            	doBuy <- FALSE
	            	doSell <- FALSE
	        	}else if((noOfBuys-noOfSells) > 0){#CONDITION MUST NOT COME
	            	quit("yes")
	          	}else if((noOfBuys-noOfSells) < 0){#CONDITION MUST NOT COME
	          		quit("yes")
	        	}
	        }else if(i > tradeStartMinute && i <= noMoreBuyMinute){# bUYING ALLOWED ONLY BETWEEN 1Hr Post Start of Trading and 1.5 Hour Previous to End of Trading
	       	    if((noOfBuys-noOfSells) == 0){#ONLY BUY
	            	doBuy <- TRUE
	            	doSell <- FALSE
	        	}else if((noOfBuys-noOfSells) > 0){#ONLY SELL
		            doBuy <- FALSE
		            doSell <- TRUE
	        	}else if((noOfBuys-noOfSells) < 0){#CONDITION MUST NOT COME
	          		quit("yes")
	        	}
	        }else if(i > noMoreBuyMinute && i <= onlySellLastBuyMinute){#Optimize Sale of Last bought Stock - No buys
	           	if((noOfBuys-noOfSells) == 0){#ONLY BUY
					doBuy <- FALSE
	            	doSell <- FALSE
	            }else if((noOfBuys-noOfSells) > 0){#ONLY SELL
		            doBuy <- FALSE
		            doSell <- TRUE
	        	}else if((noOfBuys-noOfSells) < 0){#CONDITION MUST NOT COME
	        		quit("yes")
	        	}
	        }else if(i > onlySellLastBuyMinute){# bUYING ALLOWED ONLY BETWEEN 1Hr Post Start of Trading and 1.5 Hour Previous to End of Trading
	           	if((noOfBuys-noOfSells) == 0){#ONLY BUY
	            	doBuy <- FALSE
	            	doSell <- FALSE
	        	}else if((noOfBuys-noOfSells) > 0){#ONLY SELL
		            doBuy <- FALSE
		            doSell <- TRUE
	        	}else if((noOfBuys-noOfSells) < 0){#CONDITION MUST NOT COME
	        		quit("yes")
	        	}
	        }


	    #Analyse State
	    localTrendDuration <- 5
        prevNMean <- mean(tail(realTimeData,localTrendDuration))
    	#prevNMean <- rollmean(realTimeData,10)
    	#localPeaks = findPeaks(tail(realTimeData,10))
    	#localValleys = findValleys(tail(realTimeData,10))
    	#cat(sprintf ("CHANCE - C: %f - LB: %f, - LS: %f, M:%f ,Time:%s\n",curr, lastBoughtPrice, lastSoldPrice, prevNMean, i))

    	localSlope = tail(realTimeDataMean, localTrendDuration)
    	upwardTrend = FALSE
    	downwardTrend = FALSE
    	horizontalTrend = FALSE
    	oscillatory = TRUE
    	#if(head(localSlope,1)<mean(localSlope) && mean(localSlope)<tail(localSlope,1)){
        #	upwardTrend = TRUE
	    #}else if(head(localSlope,1)>mean(localSlope) && mean(localSlope)>tail(localSlope,1)){
	    #    downwardTrend = TRUE
    	#}else {

	    #}

    	#selllocalSlope = tail(realTimeDataMean, 2)#(localTrendDuration)
    	#if(head(selllocalSlope,1)>mean(selllocalSlope) && mean(selllocalSlope)>tail(selllocalSlope,1)){
        #	selldownwardTrend = TRUE
    	#}


	    if(doBuy){
        	cat(sprintf ("TREND: 1:%f - 2: %f, 3:%f, 4:%f\n",head(localSlope,1), mean(localSlope), tail(localSlope,1), i))
    
        	if(upwardTrend){
            	if(oscillatory){
					if(currentPrice < as.numeric(dg[i-1,])){#Only 1 Trade(1 Buy must be sold first for any subsequent buy) at a time - Buy only 1 Share
                    	triggerBuy(currentPrice)
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
        	numberOfTickCycles <<- numberOfTickCycles + 1
        	if(currentPrice > lastBoughtPrice){
	            triggerSell(currentPrice)    
        	}

        	if(i > tradeStartMinute && i <= noMoreBuyMinute){# Selling ALLOWED 

        	}else if(i > noMoreBuyMinute && i <= onlySellLastBuyMinute){
            	if(currentPrice < lastBoughtPrice - 0.8*prevTotalGain){# LIMIT TOTAL LOSS - Because 1 good trade(this final trade) cant cover ur gain u have made till now, so exit rather than losing more
	                #CAN BE CHANGED TO GIVE MORE CHANCE TO MAKE THIS LAST TRANSACTION PROFITABLE
                	triggerSell(currentPrice)                
            	}
        	}else if(i > onlySellLastBuyMinute){# IF COULDNT MAKE PROFIT in Optimization Window - JUST SELL AND LEAVE
            	if(currentPrice <= lastBoughtPrice){
                	triggerSell(currentPrice)                
            	}
        	}
    	}
    	buySellTrend <<- c(buySellTrend, lastBoughtPrice)
    	gainTrend <<- c(gainTrend, prevTotalGain+lastBoughtPrice)
       	realTimeDataMean <<- c(realTimeDataMean, prevNMean)
    	fullDayDataMean <<- c(fullDayDataMean, mean(realTimeData))
	}
}


visualize <- function() {
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

}

strategy()
visualize()
