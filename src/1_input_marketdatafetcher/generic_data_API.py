import json
from googlefinance import getQuotes
#from googlefinance import getNews
from yahoo_finance import Share
from yahoo_finance import Currency


print json.dumps(getQuotes('ONGC'), indent=2)
#print(json.dumps(getNews("GOOG"), indent=2))
#print json.dumps(getNews('ONGC'), indent=2)

yahoo = Share('ONGC')
print yahoo.get_open()
print yahoo.get_price()
print yahoo.get_trade_datetime()

yahoo.refresh()

print yahoo.get_price()
print yahoo.get_trade_datetime()


