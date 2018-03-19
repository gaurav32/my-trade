import datetime
from datetime import date, timedelta
import pandas
import json
import os
import sys
sys.path.append('../../1_input_marketdatafetcher/')
import google_history_data_parser as ghdp

today_time = datetime.datetime.now()
today_daystart_time = today_time.replace(hour=0, minute=0, second=0, microsecond=0)
market_start = today_time.replace(hour=9, minute=15, second=0, microsecond=0)
market_intraday_end = today_time.replace(hour=14, minute=55, second=0, microsecond=0)
market_interday_end = today_time.replace(hour=15, minute=15, second=0, microsecond=0)

print("Market Opens at - ", market_start)
print("Market Intraday Closes at - ", market_intraday_end)
print("Market Interday closes at - ", market_interday_end)

def performStreamingOperation(time):
	for symbol in symbols :
		print symbol
		print "Get Data for "+datetime.datetime.strftime(time,'%d-%m-%Y-%H-%M')
		inputjson =  ghdp.GoogleIntradayQuote(symbol,60,1)
		x = [i.split(',') for i in inputjson.to_csv().split()]
		df = pandas.DataFrame.from_records(x,columns=['symbol','date','time','open','high','low','close','volume'])
		print(df.head(3))

def getTradingMarketMinute(time):
	diff = time - today_daystart_time
	elapsed_ms = (diff.days * 86400000) + (diff.seconds * 1000) + (diff.microseconds / 1000)
	return int(elapsed_ms/(1000*60))

#sample_time = today_time.replace(hour=1, minute=2, second=59, microsecond=0)
#print(getTradingMarketMinute(sample_time))

symbols = ["NIFTY","BHEL"]

current_time = datetime.datetime.now()
last_minute_handled = -1
counter = 0
while ((current_time >= market_start) & (current_time >= market_interday_end)):
	if current_time == market_start:
		print "Market Opened for trading"
	if current_time == market_intraday_end:
		print "Market Closing for Intradday trading"
		break
	if current_time == market_interday_end:
		print "Market Closing for Interday trading"
		break

	if counter > last_minute_handled:
		try:
			performStreamingOperation(current_time)
			last_minute_handled = getTradingMarketMinute(current_time)
		except ValueError:
	    		print("Oops!  That was no valid number.  Try again...")

	#reset time
	current_time = datetime.datetime.now()
	counter = getTradingMarketMinute(current_time)

