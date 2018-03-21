#######################################################################################################################################

getsureshotprofitstocks <- function(finalallstocklow, finalallstockhigh, gainpercent){
	#######################################################################################################################################
	#symbols <- as.list("BHEL")
	final_prevdaylow_to_nextdayhigh <- data.frame(1)
	for (symbol in symbols){
		tryCatch({
			lowdata <- as.list(finalallstocklow[,paste("MIN_",symbol,sep="")])
			highdata <- as.list(finalallstockhigh[,paste("MAX_",symbol,sep="")])
			lowrecords <- length(lowdata)
			highrecords <- length(highdata)
			for (lowrowIndx in 1:lowrecords){
				final_prevdaylow_to_nextdayhigh[lowrowIndx,symbol] <- 0
				baseprice <- as.double(1+gainpercent)*as.double(lowdata[lowrowIndx])
				for (highrowIndx in (lowrowIndx+1):highrecords){
					if(highrowIndx > highrecords)
						final_prevdaylow_to_nextdayhigh[lowrowIndx,symbol] <- 1
					price <- as.double(highdata[highrowIndx])
					if (price > baseprice){
						#print(c("found compare", lowrowIndx, highrowIndx, "Prices : ",baseprice, price))
						final_prevdaylow_to_nextdayhigh[lowrowIndx,symbol] <- 1
						break
					} else{
						#print(c("not found compare", lowrowIndx, highrowIndx, "Prices : ",baseprice, price))
						final_prevdaylow_to_nextdayhigh[lowrowIndx,symbol] <- final_prevdaylow_to_nextdayhigh[lowrowIndx,symbol] + 1
					}
				}
			}
		}, warning = function(war) {

		}, error = function(err) {
    		
		}, finally = {
			next
		}) # END tryCatch
	}
	final_prevdaylow_to_nextdayhigh[,1] <- NULL
	executesureshotprofitstocksdefinition(final_prevdaylow_to_nextdayhigh)
}

executesureshotprofitstocksdefinition <- function(final_prevdaylow_to_nextdayhigh){
	for (symbol in symbols){
		#for (lowrowIndx in 1:lowrecords){
			#	if(!is.na(final_prevdaylow_to_nextdayhigh[lowrowIndx,symbol])){
			#		val <- as.numeric(final_prevdaylow_to_nextdayhigh[lowrowIndx,symbol])
			#		if(val != 1){
			#			final_prevdaylow_to_nextdayhigh[,symbol] <- NULL
			#			break
			#		}
			#	}
		#}
		#print(result)
	}
	final_prevdaylow_to_nextdayhigh
}


geteverydayhighlowdiffpercent <- function(finalallstocklow, finalallstockhigh, gainpercent){
	#######################################################################################################################################
	#symbols <- as.list("BHEL")
	final_daylow_to_dayhigh <- data.frame(1)
	for (symbol in symbols){
		tryCatch({
			lowdata <- as.list(finalallstocklow[,paste("MIN_",symbol,sep="")])
			highdata <- as.list(finalallstockhigh[,paste("MAX_",symbol,sep="")])
			lowrecords <- length(lowdata)
			for (lowrowIndx in 1:lowrecords){
				baseprice <- as.double(lowdata[lowrowIndx])
				price <- as.double(highdata[lowrowIndx])
				diffpercent <- as.double((price - baseprice)*(100/baseprice))
				final_daylow_to_dayhigh[lowrowIndx,symbol] <- diffpercent
			}
		}, warning = function(war) {

		}, error = function(err) {
    		
		}, finally = {
			next
		}) # END tryCatch
	}
	final_daylow_to_dayhigh[,1] <- NULL
	final_daylow_to_dayhigh
}

getyesterdaylowtotodaydhighdiffpercent <- function(finalallstocklow, finalallstockhigh, gainpercent){
	#######################################################################################################################################
	#symbols <- as.list("BHEL")
	final_yesterdaylow_to_todayhigh <- data.frame(1)
	for (symbol in symbols){
		tryCatch({
			lowdata <- as.list(finalallstocklow[,paste("MIN_",symbol,sep="")])
			highdata <- as.list(finalallstockhigh[,paste("MAX_",symbol,sep="")])
			highrecords <- length(highdata)
			for (highrowIndx in 2:highrecords){
				baseprice <- as.double(lowdata[highrowIndx-1])
				price <- as.double(highdata[highrowIndx])
				diffpercent <- as.double((price - baseprice)*(100/baseprice))
				final_yesterdaylow_to_todayhigh[highrowIndx,symbol] <- diffpercent
			}
			final_yesterdaylow_to_todayhigh[1,symbol] <- final_yesterdaylow_to_todayhigh[2,symbol] #set value for 1st day
		}, warning = function(war) {

		}, error = function(err) {
    		
		}, finally = {
			next
		}) # END tryCatch
	}
	final_yesterdaylow_to_todayhigh[,1] <- NULL
	final_yesterdaylow_to_todayhigh
}

gettodaylowtoyesterdaydhighdiffpercent <- function(finalallstocklow, finalallstockhigh, gainpercent){
	#######################################################################################################################################
	#symbols <- as.list("BHEL")
	final_todaylow_to_yesterdayhigh <- data.frame(1)
	for (symbol in symbols){
		tryCatch({
			lowdata <- as.list(finalallstocklow[,paste("MIN_",symbol,sep="")])
			highdata <- as.list(finalallstockhigh[,paste("MAX_",symbol,sep="")])
			lowrecords <- length(lowdata)
			for (lowrowIndx in 2:lowrecords){
				baseprice <- as.double(lowdata[lowrowIndx])
				price <- as.double(highdata[lowrowIndx-1])
				diffpercent <- as.double((price - baseprice)*(100/baseprice))
				final_todaylow_to_yesterdayhigh[lowrowIndx,symbol] <- diffpercent
			}
			final_todaylow_to_yesterdayhigh[1,symbol] <- final_todaylow_to_yesterdayhigh[2,symbol] #set value for 1st day
		}, warning = function(war) {

		}, error = function(err) {
    		
		}, finally = {
			next
		}) # END tryCatch
	}
	final_todaylow_to_yesterdayhigh[,1] <- NULL
	final_todaylow_to_yesterdayhigh
}

getprofitpercentageprobability <- function(finalallstocklow, finalallstockhigh, gainpercent){
	#######################################################################################################################################
	#symbols <- as.list("BHEL")
	final_profitpercentageprobability <- data.frame(1)
	for (symbol in symbols){
		tryCatch({
			lowdata <- as.list(finalallstocklow[,paste("MIN_",symbol,sep="")])
			highdata <- as.list(finalallstockhigh[,paste("MAX_",symbol,sep="")])
			lowrecords <- length(lowdata)
			for (lowrowIndx in 1:lowrecords-1){
				basehighprice <- as.double(highdata[lowrowIndx])
				baselowprice <- as.double(lowdata[lowrowIndx])

				predicttommmorowhighprice <- baselowprice + as.double(baselowprice*0.0075)
				predicttommmorowlowprice <- basehighprice - as.double(basehighprice*0.0075)
				diffpercent <- as.double((predicttommmorowhighprice - predicttommmorowlowprice)*(100/predicttommmorowlowprice))

				actualtommmorowhighprice <- as.double(highdata[lowrowIndx+1])
				actualtommmorowlowprice <- as.double(lowdata[lowrowIndx+1])
				dif <- as.double(actualtommmorowhighprice-predicttommmorowhighprice)
				#print(dif)
				#if(dif > 0 ){print("H")}
				#if(as.double(dif) > 0){
				#	final_profitpercentageprobability[lowrowIndx,symbol] <- as.double(1)	
				#}#else {
				#	final_profitpercentageprobability[lowrowIndx,symbol] <- as.double(0)	
				#}
				final_profitpercentageprobability[lowrowIndx,symbol] <- as.double(1)
				#if(predicttommmorowhighprice <= actualtommmorowhighprice && predicttommmorowlowprice >= actualtommmorowlowprice && diffpercent >= 1){
				#	final_profitpercentageprobability[lowrowIndx,symbol] <- 1
				#}else {
				#	final_profitpercentageprobability[lowrowIndx,symbol] <- 0
				#}
			}
			final_profitpercentageprobability[lowrowIndx+1,symbol] <- 1
		}, warning = function(war) {

		}, error = function(err) {
    		
		}, finally = {
			next
		}) # END tryCatch
	}
	final_profitpercentageprobability[,1] <- NULL
	final_profitpercentageprobability
}

getnextdaychangeclassification <- function(finalallstocklow, finalallstockhigh, symbols){
	#######################################################################################################################################
	final_nextdaychangeclassification <- data.frame(1)
	yes_highlow_to_highlow <- data.frame("class"=double(),"basehighprice"=double(), "actualtommmorowlowprice"=double(), "baselowprice"=double(), "actualtommmorowhighprice"=double())
	for (symbol in symbols){
		tryCatch({
			lowdata <- as.list(finalallstocklow[,paste("MIN_",symbol,sep="")])
			highdata <- as.list(finalallstockhigh[,paste("MAX_",symbol,sep="")])
			lowrecords <- length(lowdata)
			for (lowrowIndx in 1:lowrecords-1){
				basehighprice <- as.double(highdata[lowrowIndx])
				baselowprice <- as.double(lowdata[lowrowIndx])

				actualtommmorowhighprice <- as.double(highdata[lowrowIndx+1])
				actualtommmorowlowprice <- as.double(lowdata[lowrowIndx+1])
				highhighr <- as.integer(sign(actualtommmorowhighprice-basehighprice))
				lowlowr <- as.integer(sign(actualtommmorowlowprice-baselowprice))#Signvalue -1 1 0
				highlowr <- as.integer(sign(actualtommmorowhighprice-baselowprice))
				lowhighr <- as.integer(sign(actualtommmorowlowprice-basehighprice))#Signvalue -1 1 0
				if(!is.null(basehighprice) && length(basehighprice)>0
					&& !is.null(baselowprice) && length(baselowprice)>0
					&& !is.null(actualtommmorowhighprice) && length(actualtommmorowhighprice)>0
					&& !is.null(actualtommmorowlowprice) && length(actualtommmorowlowprice)>0){

					if(highhighr == 1 && highlowr ==1 && lowlowr == 1 && lowhighr == 1) {
    					final_nextdaychangeclassification[lowrowIndx,symbol] <- as.double(5)
yes_highlow_to_highlow <- rbind(yes_highlow_to_highlow, c(5, basehighprice, actualtommmorowlowprice, baselowprice, actualtommmorowhighprice))    					
					}else if(highhighr == 1 && highlowr == 1 && lowlowr == 1 && lowhighr == -1) {
						final_nextdaychangeclassification[lowrowIndx,symbol] <- as.double(0)
yes_highlow_to_highlow <- rbind(yes_highlow_to_highlow, c(0, basehighprice, actualtommmorowlowprice, baselowprice, actualtommmorowhighprice))
					}else if(highhighr == 1 && highlowr == 1 && lowlowr == -1 && lowhighr == -1) {
						final_nextdaychangeclassification[lowrowIndx,symbol] <- as.double(3)
yes_highlow_to_highlow <- rbind(yes_highlow_to_highlow, c(3, basehighprice, actualtommmorowlowprice, baselowprice, actualtommmorowhighprice))
					}else if(highhighr == -1 && highlowr == 1 && lowlowr == 1 && lowhighr == -1) {
						final_nextdaychangeclassification[lowrowIndx,symbol] <- as.double(2)
yes_highlow_to_highlow <- rbind(yes_highlow_to_highlow, c(2, basehighprice, actualtommmorowlowprice, baselowprice, actualtommmorowhighprice))						
					}else if(highhighr == -1 && highlowr == 1 && lowlowr == -1 && lowhighr == -1) {
						final_nextdaychangeclassification[lowrowIndx,symbol] <- as.double(1)	
yes_highlow_to_highlow <- rbind(yes_highlow_to_highlow, c(1, basehighprice, actualtommmorowlowprice, baselowprice, actualtommmorowhighprice))
					}else if(highhighr == -1 && highlowr == -1 && lowlowr == -1 && lowhighr == -1) {
						final_nextdaychangeclassification[lowrowIndx,symbol] <- as.double(4)		
yes_highlow_to_highlow <- rbind(yes_highlow_to_highlow, c(4, basehighprice, actualtommmorowlowprice, baselowprice, actualtommmorowhighprice))				
					} else {
	    				final_nextdaychangeclassification[lowrowIndx,symbol] <- as.double(6)
yes_highlow_to_highlow <- rbind(yes_highlow_to_highlow, c(6, basehighprice, actualtommmorowlowprice, baselowprice, actualtommmorowhighprice))	    				
					}
				}
			}
			final_nextdaychangeclassification[lowrowIndx+1,symbol] <- 1
		}, warning = function(war) {

		}, error = function(err) {
    		print(err)
		}, finally = {
			next
		}) # END tryCatch
	}
	final_nextdaychangeclassification[,1] <- NULL
	#yes_highlow_to_highlow[,1] <- NULL
	colnames(yes_highlow_to_highlow) <- c("class","basehighprice", "actualtommmorowlowprice", "baselowprice", "actualtommmorowhighprice") 
	newList <- list("nextdaychangeclassification" = final_nextdaychangeclassification, "yes_highlow_to_highlow" = yes_highlow_to_highlow)
}

printchangeclassdistribution <- function(finalallstockchangeclass, symbol){
	#######################################################################################################################################
	changeclassdata <- as.list(finalallstockchangeclass[symbol])
	df <- as.data.frame(table(changeclassdata))
	totalentries <- length(unlist(changeclassdata))
	df["DistrPercentage"] <- df["Freq"]*100/totalentries
	if((df[1,"DistrPercentage"] + df[2,"DistrPercentage"] + df[4,"DistrPercentage"]) > 80){
		print(symbol)
		print(df)
	}
}

testneuralnet <- function(finalallstockchangeclass){
	#######################################################################################################################################
	#from matplotlib import pyplot
	series = finalallstockchangeclass
	X = series.values
	#train, test = X[0:-12], X[-12:]
	#series.plot()
	#pyplot.show()
}

getConfidentPredictionGoodStocks <- function(everydayhighlowdiffpercent, finalallstocklow, finalallstockhigh, symbols){
	#######################################################################################################################################
	for (symbol in symbols){
		tryCatch({
			result <- getnextdaychangeclassification(finalallstocklow, finalallstockhigh, symbol)
			nextdaychangeclassification <- result$nextdaychangeclassification
			yes_highlow_to_highlow_data <- result$yes_highlow_to_highlow

			sample <- tail(yes_highlow_to_highlow_data,1)
			sample$basehighprice <- tail(finalallstockhigh[paste("MAX_",symbol,sep="")],1)[1,]
			sample$baselowprice <- tail(finalallstocklow[paste("MIN_",symbol,sep="")],1)[1,]

			print("Class Wise Distribution of Stock Trend - 0,1,3 bettable, 2 dont bet- must be ~10%, 4,5 dont bet, must be ~1%")
			printchangeclassdistribution(nextdaychangeclassification, symbol)
			
			print("Shows Confidence of minimum Indtraday Change for a stock")
			ds <- everydayhighlowdiffpercent[symbol]
			print(summary(ds))
			print(quantile(ds[order(ds[symbol]),], c(.01, .02, .03, .04, .05, .10, .15, .20)))

			case0 <- subset(yes_highlow_to_highlow_data, class == 0)
			case1 <- subset(yes_highlow_to_highlow_data, class == 1)

			print("Case 0 stats")
			correlation <- cor(case0$basehighprice, case0$actualtommmorowlowprice)
			train <- head(case0, nrow(case0)*0.8)
			test <- tail(case0, nrow(case0)*0.2)
			lmMod0 <- lm(actualtommmorowlowprice ~ basehighprice, data=train)# build the model
			distPred <- predict(lmMod0, test)
			actuals_preds <- data.frame(cbind(actuals=test$actualtommmorowlowprice, predictedslow=distPred))
			correlation_accuracy <- cor(actuals_preds)
			print(paste0("Correlation - ",correlation, " PredictionAccuracy - below --"))
			#print(correlation_accuracy)
			#print(actuals_preds)

			print("Case 1 stats")
			correlation <- cor(case1$baselowprice, case1$actualtommmorowhighprice)
			train <- head(case1, nrow(case1)*0.8)
			test <- tail(case1, nrow(case1)*0.2)
			lmMod1 <- lm(actualtommmorowhighprice ~ baselowprice, data=train)# build the model
			distPred <- predict(lmMod1, test)
			actuals_preds <- data.frame(cbind(actuals=test$actualtommmorowhighprice, predictedshigh=distPred))
			correlation_accuracy <- cor(actuals_preds)
			print(paste0("Correlation - ",correlation, " PredictionAccuracy - below --"))
			#print(correlation_accuracy)
			#print(actuals_preds)

			correlation_s <- cor(case1$baselowprice, case1$actualtommmorowlowprice)
			case1$lowdiff <- case1$baselowprice - case1$actualtommmorowlowprice
			da <- case1$lowdiff
			print(summary(da))
			print(quantile(da[order(da)], c(.01, .02, .03, .04, .05, .10, .15, .20)))
			print(paste0("See this Confidence yeslow to tomlow ",correlation_s))

			tomlowPred <- predict(lmMod0, sample)
			tomhighPred <- predict(lmMod1, sample)
			#print(sample)
			print(paste0("Yesterday High-",sample$basehighprice," Yesterday Low-",sample$baselowprice))
			print(paste0("Short-Sell-",1.01*tomlowPred," Short-Buy-",tomlowPred," Sell-",tomhighPred," Buy-",0.99* tomhighPred))

		}, warning = function(war) {

		}, error = function(err) {
    		print(err)
		}, finally = {
			next
		}) # END tryCatch
	}
}