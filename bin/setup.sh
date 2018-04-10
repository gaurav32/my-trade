#!/bin/bash
#Set the Environment Variable for Project my-trade
SCRIPTPATH="$( cd "$(dirname "$0")/../" ; pwd -P )"
TRADING_SOFTWARE=$SCRIPTPATH
echo 'export TRADING_SOFTWARE='$TRADING_SOFTWARE >> ~/.bashrc
echo Installing TradingSoftware at $TRADING_SOFTWARE

sudo apt-get install redis-server
sudo apt-get install python-pip
pip install pandas
pip install requests
pip install bs4
pip install lxml
pip install html_table_extractor
pip install redis
