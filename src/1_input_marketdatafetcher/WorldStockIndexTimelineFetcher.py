from bs4 import BeautifulSoup
import urllib2
from lxml import etree
import pandas as pd
import lxml.html
from datetime import datetime, timedelta
from pytz import timezone
import pytz
import redis
import json

r = redis.StrictRedis(host='127.0.0.1', port=6379, db=0)

fmt = '%Y-%m-%d %H:%M:%S'

url = 'http://www.worldtimezone.com/markets24.php'
url= 'https://en.wikipedia.org/wiki/List_of_stock_exchange_opening_times'
conn = urllib2.urlopen(url)

broken_html = conn.read()
corrected_html_root = lxml.html.fromstring(broken_html)
html = lxml.html.tostring(corrected_html_root)
#print html

soup = BeautifulSoup(html)
#table = soup.find("table", { "title" : "World Stock Exchanges with a corresponding time zone" })
table= soup.find("table", { "class" : "wikitable"})
df = pd.read_html(str(table))[0]
df = df[[0,1,2,10,11]]
df = df.ix[2:]
df.columns = ['WorldStockExchangeName', 'StockExchangeSymbol', 'Country', 'Open', 'Close']

utc = pytz.utc
ist = timezone('Asia/Calcutta')
df['Open'] = df.Open.apply(lambda x : utc.localize(x).astimezone(ist))
df['Close'] = df.Close.apply(lambda x : utc.localize(x).astimezone(ist))

def myconverter(o):
    if isinstance(o, datetime):
        return o.__str__()

df = df.sort(['Open'], ascending=True)
#print df
r.delete("WSI")
details = []
for index,row in df.iterrows():
	detail = {'WorldStockExchangeName': row["WorldStockExchangeName"], 'StockExchangeSymbol': row["StockExchangeSymbol"], 'Country': row["Country"], 'Open': row["Open"], 'Close': row["Close"],}	
	details.append(detail)
#	r.hset("WSI", row['StockExchangeSymbol'], json.dumps(details, default=myconverter))
r.set("WSI",json.dumps(details, default=myconverter))