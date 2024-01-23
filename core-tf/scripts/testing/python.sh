sudo apt update
sudo apt install python
sudo apt install python3-pip
pip3 install google-datacatalog-sqlserver-connector
pip3 install virtualenv
virtualenv --python python3.9.2 myenv
source myenv/bin/activate
myenv/bin/pip install google-datacatalog-sqlserver-connector