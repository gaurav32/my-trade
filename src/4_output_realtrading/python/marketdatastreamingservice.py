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
	df = []
	for symbol in symbols :
		filename = "New_nifty50_"+symbol+".csv"
		print filename
		frames = pandas.read_csv(filename)
		df.append(frames)
	result = pandas.concat(df)		
	return result

def load90DayMinuteWiseData(symbols):
	df = []
	for symbol in symbols :
		filename = "Today_Yesterday_nifty50_"+symbol+".csv"
		print filename
		frames = pandas.read_csv(filename)
		df.append(frames)
	result = pandas.concat(df)		
	return result

os.chdir("../../2_datadump/datadump/daily/")
daywisedata = load365DayWiseData(symbols)
os.chdir("../minutewise/")
minutewisedata = load90DayMinuteWiseData(symbols)
os.chdir("../../../")
###############################################################################################################
def check_rule1(today_minute_data, symbol):
	#If Today's current_low falls below yesterday's low
	# & I know Today High Low would be atleast 1%
	# & with yesterday low - today-low correlation of .99 and 20 percent chance of diff being less than 0.5%
	# & today's high(today's predicted low + 1%) would come after today's low in chosen class
	# & I know even If Today's High is already higher than yesterday's low - I would cover 1% tommorow
	#yesterdate_date = 
	msg = ''
	yesterday_date = daywisedata[daywisedata.symbol == symbol].iloc[-1]['date'] 
	yesterday_low = float(daywisedata[daywisedata.symbol == symbol].iloc[-1]['low'])
	current_low = float(today_minute_data.iloc[-1]['low'])
	if yesterday_low*0.995 > current_low:
		print(yesterday_date, yesterday_low, current_low)
		msg = msg+'Rule 1 '+symbol
	return msg

def check_rule2(today_minute_data, symbol):
	#If Today's current_low falls below yesterday's low
	# & I know Today High Low would be atleast 1%
	# & with yesterday low - today-low correlation of .99 and 20 percent chance of diff being less than 0.5%
	# & I know even If Today's High is already higher than yesterday's low - I would cover 1% tommorow
	msg = 'Empty Rule Check'
	return msg

def performStreamingOperation(time):
	print("**********************************************************************")
	msg = ''
	for symbol in symbols :
		print "Get Data for "+symbol+" - for - "+datetime.datetime.strftime(time,'%d-%m-%Y-%H-%M')
		inputjson =  ghdp.GoogleIntradayQuote(symbol,60,1)
		x = [i.split(',') for i in inputjson.to_csv().split()]
		today_minute_data = pandas.DataFrame.from_records(x,columns=['symbol','date','time','open','high','low','close','volume'])
		msg = msg+check_rule1(today_minute_data, symbol)
		msg = msg+check_rule2(today_minute_data, symbol)
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