import datetime
from datetime import date, timedelta
import pandas
import json
import os
import way2sms
import sys
sys.path.append(os.environ.get('TRADING_SOFTWARE')+'/src/1_input_marketdatafetcher/dataparsers/')
import google_history_data_parser as ghdp
import nse_option_data_parser as nodp
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
call_option_chosen = 10000
put_option_chosen = 7000
starting_strikeprice_chosen = True
def options_check_rule1(options_current_data):
	#If Today's current_low falls below yesterday's low
	# & I know Today High Low would be atleast 1%
	# & with yesterday low - today-low correlation of .99 and 20 percent chance of diff being less than 0.5%
	# & I know even If Today's High is already higher than yesterday's low - I would cover 1% tommorow
	global starting_strikeprice_chosen 

	if starting_strikeprice_chosen :
		starting_strikeprice_chosen = False
		#call_option_chosen = options_current_data.head(1)['CALL_LTP']
		print("Today OPTIONS Trade -Start- CALL_StrikePrice:{0} PUT_StrikePrice:{1}".format(call_option_chosen,put_option_chosen))
	#print(options_current_data[options_current_data['Strike Price'] == 9800][['Strike Price','PUT_LTP']])
	#print(options_current_data[options_current_data['Strike Price'] == 10300][['Strike Price','CALL_LTP']])
	msg = ''
	return msg

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
	print(" Rule1 ",yesterday_date, yesterday_low, current_low)
	if yesterday_low*0.995 > current_low:
		#print(yesterday_date, yesterday_low, current_low)
		msg = msg+' Rule1 - BuyNow -'+symbol+","
	return msg

def check_rule2(today_minute_data, symbol):
	#If Today's current_low falls below yesterday's low
	# & I know Today High Low would be atleast 1%
	# & with yesterday low - today-low correlation of .99 and 20 percent chance of diff being less than 0.5%
	# & I know even If Today's High is already higher than yesterday's low - I would cover 1% tommorow
	print(today_minute_data.tail(1))
	msg = ''
	return msg
###############################################################################################################
def performStreamingOperation(time):
	print("**********************************************************************")
	msg = ''
	############################################################################
	options_current_data = nodp.NseOptionsData()
	msg = msg+options_check_rule1(options_current_data)
	############################################################################
	for symbol in symbols :
		print "Get Data for "+symbol+" - for - "+datetime.datetime.strftime(time,'%d-%m-%Y-%H-%M')
		inputjson =  ghdp.GoogleIntradayQuote(symbol,60,1)
		x = [i.split(',') for i in inputjson.to_csv().split()]
		today_minute_data = pandas.DataFrame.from_records(x,columns=['symbol','date','time','open','high','low','close','volume'])
		msg = msg+check_rule1(today_minute_data, symbol)
		msg = msg+check_rule2(today_minute_data, symbol)
	############################################################################
	print(msg)
	if enable_sms:
		q.send( phone_number, msg )

def getTradingMarketMinute(time):
	diff = time - today_daystart_time
	elapsed_ms = (diff.days * 86400000) + (diff.seconds * 1000) + (diff.microseconds / 1000)
	return int(elapsed_ms/(1000*60))

def startStreamingApp():

	current_time = datetime.datetime.now()
	last_minute_handled = -1
	counter = 0

	trading_started = False
	intraday_ended = False
	interday_ended = False

	while(True) :
		while ((current_time >= market_start) & (current_time <= market_interday_end) or bypass_trading_window):
			if current_time >= market_start:
				if not trading_started & (not interday_ended):
					trading_started = True
					print "Market Opened for trading"
					if enable_sms:
						q.send( phone_number, 'Market Opened for trading' )
			if current_time >= market_intraday_end:
				if trading_started & (not intraday_ended):
					intraday_ended = True
					print "Market Closing for Intradday trading"
					if enable_sms:
						q.send( phone_number, 'Market Closing for Intradday trading' )
			if current_time >= market_interday_end:
				if trading_started & (not interday_ended):
					interday_ended = True
					intraday_ended = True
					trading_started = True
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
if __name__ == '__main__':
  	startStreamingApp()
###############################################################################################################
