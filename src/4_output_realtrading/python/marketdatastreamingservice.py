import datetime
from datetime import date, timedelta
import pandas
import json
import os
import way2sms
import sys
sys.path.append('../../1_input_marketdatafetcher/')
import google_history_data_parser as ghdp
###############################################################################################################
today_time = datetime.datetime.now()
today_daystart_time = today_time.replace(hour=0, minute=0, second=0, microsecond=0)
market_start = today_time.replace(hour=9, minute=15, second=0, microsecond=0)
market_intraday_end = today_time.replace(hour=14, minute=55, second=0, microsecond=0)
market_interday_end = today_time.replace(hour=15, minute=25, second=0, microsecond=0)

print("Market Opens at - ", market_start)
print("Market Intraday Closes at - ", market_intraday_end)
print("Market Interday closes at - ", market_interday_end)

phone_number = '8447240641'
q=way2sms.sms(phone_number,'freesms')
enable_sms = False
bypass_trading_window = True

symbols = ["NIFTY","BHEL","BANKBARODA"]
###############################################################################################################
def load365DayWiseData(symbols):
	return 0

def load90DayMinuteWiseData(symbols):
	return 0

daywisedata = load365DayWiseData(symbols)
minutewisedata = load90DayMinuteWiseData(symbols)
###############################################################################################################
def check_rule1(today_minute_data):
	#If Today's current_low falls below yesterday's low
	# & I know Today High Low would be atleast 1%
	# & with yesterday low - today-low correlation of .99 and 20 percent chance of diff being less than 0.5%
	# & I know even If Today's High is already higher than yesterday's low - I would cover 1% tommorow
	yesterday_low = 0
	current_low = float(today_minute_data.iloc[0]['low'])
	print(yesterday_low, current_low)

def performStreamingOperation(time):
	msg = ''
	for symbol in symbols :
		print "Get Data for "+symbol+" - for - "+datetime.datetime.strftime(time,'%d-%m-%Y-%H-%M')
		inputjson =  ghdp.GoogleIntradayQuote(symbol,60,1)
		x = [i.split(',') for i in inputjson.to_csv().split()]
		today_minute_data = pandas.DataFrame.from_records(x,columns=['symbol','date','time','open','high','low','close','volume'])
		check_rule1(today_minute_data)
	if enable_sms:
		q.send( phone_number, msg )
###############################################################################################################
def getTradingMarketMinute(time):
	diff = time - today_daystart_time
	elapsed_ms = (diff.days * 86400000) + (diff.seconds * 1000) + (diff.microseconds / 1000)
	return int(elapsed_ms/(1000*60))

current_time = datetime.datetime.now()
last_minute_handled = -1
counter = 0

while(True) :
	while ((current_time >= market_start) & (current_time <= market_interday_end) or bypass_trading_window):
		if current_time == market_start:
			print "Market Opened for trading"
			if enable_sms:
				q.send( phone_number, 'Market Opened for trading' )
		if current_time == market_intraday_end:
			print "Market Closing for Intradday trading"
			if enable_sms:
				q.send( phone_number, 'Market Closing for Intradday trading' )
			break
		if current_time == market_interday_end:
			print "Market Closing for Interday trading"
			if enable_sms:
				q.send( phone_number, 'Market Closing for Interday trading' )
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
	if current_time > market_interday_end :
		break

q.logout()
###############################################################################################################