import pandas
import json
import time
import sys
import os
sys.path.append(os.environ.get('TRADING_SOFTWARE')+'/src/1_input_marketdatafetcher/dataparsers/')
import google_history_data_parser as ghdp
import WorldStockIndexTimelineFetcher as wsit

############################################################################################################
#Fetch All WorldStockIndex open close timings
############################################################################################################
wsit.getworldstocktimings()
############################################################################################################

#symboldetailpath = os.environ.get('TRADING_SOFTWARE')+"/src/2_datadump/metadata/"
#print(symboldetailpath)
#os.chdir(symboldetailpath)
#symbols = pandas.read_csv("NIFTY_50_SYMBOLS.csv")
#print(symbols)
symbols = ["NIFTY","ACC","ADANIPORTS","AMBUJACEM","ASIANPAINT","AUROPHARMA","AXISBANK","BAJAJ-AUTO","BANKBARODA","BHEL","BPCL","BHARTIARTL","INFRATEL","BOSCHLTD","CIPLA","COALINDIA","DRREDDY","EICHERMOT","GAIL","GRASIM","HCLTECH","HDFCBANK","HEROMOTOCO","HINDALCO","HINDUNILVR","HDFC","ITC","ICICIBANK","IDEA","INDUSINDBK","INFY","KOTAKBANK","LT","LUPIN","M&M","MARUTI","NTPC","ONGC","POWERGRID","RELIANCE","SBIN","SUNPHARMA","TCS","TATAMTRDVR","TATAMOTORS","TATAPOWER","TATASTEEL","TECHM","ULTRACEMCO","WIPRO","YESBANK","ZEEL","PNB","TCS"]

datadumppath = os.environ.get('TRADING_SOFTWARE')+"/src/2_datadump/datadump/daily/"
datadumpminutewisepath = os.environ.get('TRADING_SOFTWARE')+"/src/2_datadump/datadump/minutewise/"

############################################################################################################
#DayWise Data for past 1 Year
############################################################################################################
filelist = [ f for f in os.listdir(datadumppath) if f.endswith(".csv") ]
for f in filelist:
    print datadumppath+f
    os.remove(datadumppath+f)

for symbol in symbols :
	#print symbol
	filename = datadumppath+"New_nifty50_"+symbol+".csv"
	#inputjson =  ghdp.GoogleIntradayQuote(symbol,86400,360)
	inputjson =  ghdp.GoogleInterdayQuote(symbol,86400,1)
	inputjson.write_csv(filename)

############################################################################################################
#MinuteWise Data for past 90 days
############################################################################################################
filelist = [ f for f in os.listdir(datadumpminutewisepath) if f.endswith(".csv") ]
for f in filelist:
    print datadumpminutewisepath+f
    os.remove(datadumpminutewisepath+f)
    
for symbol in symbols :
	#print symbol
	filename = datadumpminutewisepath+"Today_Yesterday_nifty50_"+symbol+".csv"
	#inputjson =  ghdp.GoogleIntradayQuote(symbol,86400,360)
	inputjson =  ghdp.GoogleIntradayQuote(symbol,60,90)
	inputjson.write_csv(filename)
############################################################################################################
