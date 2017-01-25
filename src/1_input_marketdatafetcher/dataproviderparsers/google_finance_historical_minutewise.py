import json
import sys
import demjson

try:
    from urllib.request import Request, urlopen
except ImportError:  # python 2
    from urllib2 import Request, urlopen

__author__ = 'Gaurav Sharma'


googleFinanceKeyToFullName = {
    u'id'     : u'ID',
    u't'      : u'StockSymbol',
    u'e'      : u'Index',
    u'l'      : u'LastTradePrice',
    u'l_cur'  : u'LastTradeWithCurrency',
    u'ltt'    : u'LastTradeTime',
    u'lt_dts' : u'LastTradeDateTime',
    u'lt'     : u'LastTradeDateTimeLong',
    u'div'    : u'Dividend',
    u'yld'    : u'Yield',
    u's'      : u'LastTradeSize',
    u'c'      : u'Change',
    u'c'      : u'ChangePercent',
    u'el'     : u'ExtHrsLastTradePrice',
    u'el_cur' : u'ExtHrsLastTradeWithCurrency',
    u'elt'    : u'ExtHrsLastTradeDateTimeLong',
    u'ec'     : u'ExtHrsChange',
    u'ecp'    : u'ExtHrsChangePercent',
    u'pcls_fix': u'PreviousClosePrice'
}

def buildUrl(symbol):
    # a deprecated but still active & correct api
    return 'http://www.google.com/finance/getprices?q=' \
        + symbol \
        + '&x=NSE&i=60&p=1d&f=d,o,h,l,c,v'

def request(symbol):
    url = buildUrl(symbol)
    req = Request(url)
    resp = urlopen(req)
    # remove special symbols such as the pound symbol
    content = resp.read().splitlines()#.decode('ascii', 'ignore').strip()
    #content = content[3:]
    return content

def replaceKeys(quotes):
    global googleFinanceKeyToFullName
    quotesWithReadableKey = []
    for q in quotes:
        qReadableKey = {}
        for k in googleFinanceKeyToFullName:
            if k in q:
                qReadableKey[googleFinanceKeyToFullName[k]] = q[k]
        quotesWithReadableKey.append(qReadableKey)
    return quotesWithReadableKey

def getQuotes(symbol):
    if type(symbol) == type('str'):
        symbol = [symbol]
    content = json.loads(request(symbol))
    return replaceKeys(content);

if __name__ == '__main__':
    try:
        symbols = sys.argv[1]
    except:
        #symbols = "GOOG,AAPL"
	symbols = "ACC,ADANIPORTS,AMBUJACEM,ASIANPAINT,AXISBANK,BAJAJ-AUTO,BANKBARODA,BHEL,BPCL,BHARTIARTL,BOSCHLTD,CAIRN,CIPLA,COALINDIA,DRREDDY,GAIL,GRASIM,HCLTECH,HDFCBANK,HEROMOTOCO,HINDALCO,HINDUNILVR,HDFC,ITC,ICICIBANK,IDEA,INDUSINDBK,INFY,KOTAKBANK,LT,LUPIN,M&M,MARUTI,NTPC,ONGC,POWERGRID,PNB,RELIANCE,SBIN,SUNPHARMA,TCS,TATAMOTORS,TATAPOWER,TATASTEEL,TECHM,ULTRACEMCO,VEDL,WIPRO,YESBANK,ZEEL"

    symbols = symbols.split(',')

    #print(json.dumps(getNews("BHEL"), indent=2))
    #print(json.dumps(getQuotes(symbols), indent=2))       
    json.dumps(getQuotes("BHEL"))