import pandas as pd
import json
import time
import glob
import os
import redis
from time import mktime
from datetime import datetime

r = redis.StrictRedis(host='localhost', port=6379, db=0)
os.chdir("../../../2_datadump/datadump/")

merged_df = pd.DataFrame(columns=['Timestamp'])

def prepare_symbol_dataframe( symbol ):
	data = r.hgetall(symbol)
	rows_list = []
	for rec in data :
        	try:
			timestamp = time.strptime(rec, '%Y-%m-%d_%H:%M')
        		#rows_list.append((timestamp, r.hget(symbol,rec)))
			rows_list.append((rec, r.hget(symbol,rec)))
		except:
			print("Unexpected error:")
	df = pd.DataFrame(rows_list,columns=['Timestamp', symbol])
	temp_merged_df = merged_df.merge(df,on="Timestamp", how='outer')
	return temp_merged_df

all_keys = r.keys("*")

for symbol in all_keys:
	merged_df = prepare_symbol_dataframe(symbol)

filenamepattern = ("nifty50.csv")
merged_df.to_csv(filenamepattern)
