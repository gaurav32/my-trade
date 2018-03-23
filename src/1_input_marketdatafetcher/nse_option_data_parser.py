import requests
import pandas as pd
from bs4 import BeautifulSoup
from lxml import etree
from html_table_extractor.extractor import Extractor

def NseOptionsData():
	base_url = ("https://www.nseindia.com/live_market/dynaContent/live_watch/option_chain/optionKeys.jsp?symbolCode=-10003&symbol=NIFTY&symbol=NIFTY&instrument=OPTIDX&date=-&segmentLink=17&segmentLink=17")
	page=requests.get(base_url)
	print(page.status_code)

	soup = BeautifulSoup(page.content,'html.parser')
	table_it = soup.find_all(class_="opttbldata")
	table_cls_1 = soup.find_all(id='octable')
	col_list = []
	for mytable in table_cls_1:
		table_head = mytable.find('thead')
		tab_head = soup.find_all('thead')
		try:
			rows = table_head.find_all('tr')
			for tr in rows:
				cols = tr.find_all('th')
				for th in cols:
					er = th.text
					ee = er.encode('utf8')
					col_list.append(ee)
		except:
			print("no head")
	col_list= [e for e  in col_list if e not in ('CALLS','PUTS','Chart','\xc2\xa0')]
	col_list_fn1 = []
	for col in col_list[0:10]:
	        col_list_fn1.append('CALL_'+col)
	col_list_fn1.append('Strike Price')
	for col in col_list[11:21]:
	        col_list_fn1.append('PUT_'+col)

	table_cls_2 = soup.find(id="octable")
	all_trs = table_cls_2.find_all('tr')
	req_row=table_cls_2.find_all('tr')
	new_table = pd.DataFrame(index=range(0,len(req_row)-3), columns=col_list_fn1)
	row_marker = 0
	for row_number, tr_nos in enumerate(req_row):
		if row_number <=1  or row_number == len(req_row)-1:
			continue

		td_columns = tr_nos.find_all('td')
		
		select_cols = td_columns[1:22]
		cols_horizontal = range(0, len(select_cols))
		
		for nu, column in enumerate(select_cols):
		
			utf_string = column.get_text()
			utf_string = utf_string.strip('"\n\r\t": ')
			tr = utf_string.encode('utf8')
			tr = tr.replace(',','')
			new_table.ix[row_marker,[nu]] = tr
	
		row_marker +=1
	relevant_options_data = new_table[['Strike Price','CALL_BidPrice','CALL_BidQty','CALL_AskPrice','CALL_AskQty','CALL_Net Chng','CALL_LTP','CALL_Volume','PUT_BidPrice','PUT_BidQty','PUT_AskPrice','PUT_AskQty','PUT_Net Chng','PUT_LTP','PUT_Volume']]
	relevant_options_data['Strike Price'] = relevant_options_data[['Strike Price']].astype(float)

	return relevant_options_data
