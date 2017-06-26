
getsureshotprofitstocks <- function(allstockhighlowdata){
	#######################################################################################################################################
	symbols <- as.list("PNB")
	final_prevdaylow_to_nextdayhigh <- data.frame(1)
	records <- nrow(final_low_high)
	for (symbol in symbols){
		for (lowrowIndx in 1:records){
			baseprice <- allstockhighlowdata[lowrowIndx,symbol]
			for (highrowIndx in lowrowIndx+1:records){
				price <- allstockhighlowdata[highrowIndx,symbol]
				#if(baseprice < 1.01*price){
				#	final_prevdaylow_to_nextdayhigh[lowrowIndx] = 1
				#}else{
				#	final_prevdaylow_to_nextdayhigh[lowrowIndx] = final_prevdaylow_to_nextdayhigh[lowrowIndx] + 1
				#}
			}
		}
	}
	final_prevdaylow_to_nextdayhigh
	#######################################################################################################################################
}
