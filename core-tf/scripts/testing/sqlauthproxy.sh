sudo apt-get install wget

wget https://storage.googleapis.com/cloud-sql-connectors/cloud-sql-proxy/v2.0.0/cloud-sql-proxy.linux.amd64 \
-O cloud-sql-proxy

chmod +x cloud-sql-proxy

./cloud-sql-proxy --address 0.0.0.0 --port 1433 --private-ip cdf-psc-sql1:us-central1:cdf-psc-sql1

sqlcmd -S 10.2.0.2 -U sqlserver -C -P P@ssword@111
sqlcmd -S 10.2.0.5 -U sqlserver -C -P P@ssword@111