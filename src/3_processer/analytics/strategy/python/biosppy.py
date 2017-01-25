import numpy as np
from biosppy.signals import ecg
import pandas as pd
import json
import time
import glob
import os
import redis
from time import mktime
from datetime import datetime

r = redis.StrictRedis(host='localhost', port=6379, db=0)
# load raw ECG signal
dates = r.hkeys("HINDALCO")
s = [10,15,20,25,20,15,10,10,15,20,25,20,15,10,10,15,20,25,20,15,10]
#for date in dates:        # Second Example
#   print 'Current fruit :', s.append(r.hget("HINDALCO",date))
signal = s

# process it and plot
out = ecg.ecg(signal=signal, sampling_rate=1000., show=True)
