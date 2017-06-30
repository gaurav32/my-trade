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