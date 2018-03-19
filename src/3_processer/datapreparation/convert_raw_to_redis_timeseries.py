import pandas as pd
import json
import time
import glob
import os
import redis
from time import mktime
from datetime import datetime

r = redis.StrictRedis(host='localhost', port=6379, db=0)
#df = pd.DataFrame({'A': 'foo bar foo bar foo bar foo foo'.split(), 'B': 'one one two three two two one three'.split()})
os.chdir("../../2_datadump/datadump/")
filenamepattern = ("nifty*.csv")
for files in glob.glob(filenamepattern):
    print files
    df = pd.read_csv(files)
    for index, row in df.iterrows():
	#timeKey = time.strftime("%Y-%m-%d_%H:%M:%S",time.strptime(row['LastTradeDateTime'], '%Y-%m-%dT%H:%M:%SZ'))
	timeKey = time.strftime("%Y-%m-%d_%H:%M",time.strptime(row['LastTradeDateTime'], '%Y-%m-%dT%H:%M:%SZ'))
	dt = datetime.fromtimestamp(mktime(time.strptime(row['LastTradeDateTime'], '%Y-%m-%dT%H:%M:%SZ')))
	millis = mktime(time.strptime(row['LastTradeDateTime'], '%Y-%m-%dT%H:%M:%SZ'))
	#r.hset(row['StockSymbol'], millis, row['LastTradePrice'])
	r.hset(row['StockSymbol'], timeKey, row['LastTradePrice'])
	#r.delete(row['StockSymbol'])

