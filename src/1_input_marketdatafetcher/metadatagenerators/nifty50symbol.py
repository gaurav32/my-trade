#https://www.nseindia.com/content/indices/ind_nifty50list.csv

import csv
import urllib2
import ssl

#ctx = ssl.create_default_context(Purpose.CLIENT_AUTH)
ctx  = ssl.load_default_certs()
ctx.check_hostname = False
ctx.verify_mode = ssl.CERT_NONE

url = 'https://www.nseindia.com/content/indices/ind_nifty50list.csv'

response = urllib2.urlopen(url, context=ctx)
cr = csv.reader(response)

for row in cr:
    print (row)
