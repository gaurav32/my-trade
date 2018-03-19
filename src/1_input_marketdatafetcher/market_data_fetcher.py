import pandas
import json
from googlefinance import getQuotes
import time

filename = "/home/gaurav/Harddisk/Office/TradingMarket/CodeBase/python/1_input_marketdatafetcher/../2_datadump/datadump/nifty50_"+time.strftime("%Y-%m-%d_%H:%M:%S")+".csv"
symbols = "ACC,ADANIPORTS,AMBUJACEM,ASIANPAINT,AXISBANK,BAJAJ-AUTO,BANKBARODA,BHEL,BPCL,BHARTIARTL,BOSCHLTD,CAIRN,CIPLA,COALINDIA,DRREDDY,GAIL,GRASIM,HCLTECH,HDFCBANK,HEROMOTOCO,HINDALCO,HINDUNILVR,HDFC,ITC,ICICIBANK,IDEA,INDUSINDBK,INFY,KOTAKBANK,LT,LUPIN,MARUTI,NTPC,ONGC,POWERGRID,PNB,RELIANCE,SBIN,SUNPHARMA,TCS,TATAMOTORS,TATAPOWER,TATASTEEL,TECHM,ULTRACEMCO,VEDL,WIPRO,YESBANK,ZEEL,M&M"

inputjson =  json.dumps(getQuotes(symbols), indent=2)
print inputjson
df = pandas.read_json(inputjson)
print df
df.to_csv(filename)