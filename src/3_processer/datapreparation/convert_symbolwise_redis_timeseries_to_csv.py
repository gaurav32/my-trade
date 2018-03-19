import pandas as pd
import json
import time
import glob
import os
import redis
from time import mktime
from datetime import datetime

r = redis.StrictRedis(host='localhost', port=6379, db=0)
symbol = "BHEL"
os.chdir("../../2_datadump/datadump/")
data = r.hgetall(symbol)
rows_list = []
for rec in data :
	timestamp = time.strptime(rec, '%Y-%m-%d_%H:%M')
	#rows_list.append((timestamp, r.hget(symbol,rec)))
	rows_list.append((rec, r.hget(symbol,rec)))

df = pd.DataFrame(rows_list,columns=['Timestamp', 'Price']).sort(['Timestamp'])
filenamepattern = (symbol+".csv")
df.to_csv(filenamepattern)
