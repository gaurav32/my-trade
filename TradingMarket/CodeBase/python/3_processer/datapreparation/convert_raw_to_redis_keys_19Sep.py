import pandas as pd
import json
import time
import glob
import os
import redis
from time import mktime
from datetime import datetime

r = redis.StrictRedis(host='localhost', port=6379, db=0)

keys = r.keys()
for key in keys:
    r.delete(key)

#df = pd.DataFrame({'A': 'foo bar foo bar foo bar foo foo'.split(), 'B': 'one one two three two two one three'.split()})
os.chdir("../../2_datadump/datadump/daily/")
filenamepattern = ("New_nifty*.csv")
for files in glob.glob(filenamepattern):
    print files
    df = pd.read_csv(files)
    for index, row in df.iterrows():
	#timeKey = time.strftime("%Y-%m-%d_%H:%M:%S",time.strptime(row['LastTradeDateTime'], '%Y-%m-%dT%H:%M:%SZ'))
	#print row
	timeKey = time.strftime("%Y-%m-%d",time.strptime(row['date'], '%Y-%m-%d'))
	#------dt = datetime.fromtimestamp(mktime(time.strptime(row['LastTradeDateTime'], '%Y-%m-%dT%H:%M:%SZ')))
	#------millis = mktime(time.strptime(row['LastTradeDateTime'], '%Y-%m-%dT%H:%M:%SZ'))
	#r.hset(row['StockSymbol'], millis, row['LastTradePrice'])
	r.hset("SYMBOL", row['symbol'], timeKey)
	r.hset("CLOSE_"+row['symbol'], timeKey, row['close'])
	r.hset("MAX_"+row['symbol'], timeKey, row['high'])
	r.hset("MIN_"+row['symbol'], timeKey, row['low'])
	#r.delete(row['StockSymbol'])

 
