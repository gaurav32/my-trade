cd ../src/1_input_marketdatafetcher
echo "################################## Fetching Market Data..Please wait ###########################"
python marketdatafetcherdaily19sep.py
cd ../../bin
cd ../src/3_processer/datapreparation
python convert_raw_to_redis_keys_19Sep.py
cd ../../../bin
cd ../src/1_input_marketdatafetcher
python WorldStockIndexTimelineFetcher.py
cd ../../bin