import pandas
import json
from googlefinance import getQuotes
import time
import google_history_data_parser as ghdp
import os

symbols = ["ACC","ADANIPORTS","AMBUJACEM","ASIANPAINT","AUROPHARMA","AXISBANK","BAJAJ-AUTO","BANKBARODA","BHEL","BPCL","BHARTIARTL","INFRATEL","BOSCHLTD","CIPLA","COALINDIA","DRREDDY","EICHERMOT","GAIL","GRASIM","HCLTECH","HDFCBANK","HEROMOTOCO","HINDALCO","HINDUNILVR","HDFC","ITC","ICICIBANK","IDEA","INDUSINDBK","INFY","KOTAKBANK","LT","LUPIN","M&M","MARUTI","NTPC","ONGC","POWERGRID","RELIANCE","SBIN","SUNPHARMA","TCS","TATAMTRDVR","TATAMOTORS","TATAPOWER","TATASTEEL","TECHM","ULTRACEMCO","WIPRO","YESBANK","ZEEL","PNB","TCS"]
#symbol = "BHEL"

datadumppath = "../2_datadump/datadump/daily/"
datadumpminutewisepath = "../2_datadump/datadump/minutewise/"

filelist = [ f for f in os.listdir(datadumppath) if f.endswith(".csv") ]
for f in filelist:
    print datadumppath+f
    os.remove(datadumppath+f)

for symbol in symbols :
	print symbol
	filename = datadumppath+"New_nifty50_"+symbol+".csv"
	#filename = "/home/gaurav/Harddisk/Office/TradingMarket/CodeBase/python/1_input_marketdatafetcher/../2_datadump/datadump/daily/New_nifty50_"+symbol+".csv"
	#inputjson =  ghdp.GoogleIntradayQuote(symbol,86400,360)
	inputjson =  ghdp.GoogleInterdayQuote(symbol,86400,1)
	inputjson.write_csv(filename)
#df = pandas.read_json(inputjson)
#print df
#df.to_csv(filename)

filelist = [ f for f in os.listdir(datadumpminutewisepath) if f.endswith(".csv") ]
for f in filelist:
    print datadumpminutewisepath+f
    os.remove(datadumpminutewisepath+f)
    
for symbol in symbols :
	print symbol
	filename = datadumpminutewisepath+"Today_Yesterday_nifty50_"+symbol+".csv"
	#filename = "/home/gaurav/Harddisk/Office/TradingMarket/CodeBase/python/1_input_marketdatafetcher/../2_datadump/datadump/daily/New_nifty50_"+symbol+".csv"
	#inputjson =  ghdp.GoogleIntradayQuote(symbol,86400,360)
	inputjson =  ghdp.GoogleIntradayQuote(symbol,60,2)
	inputjson.write_csv(filename)