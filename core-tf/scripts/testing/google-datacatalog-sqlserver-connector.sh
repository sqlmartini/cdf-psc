export GOOGLE_APPLICATION_CREDENTIALS=cdf-amm-b9bd0bbc824d.json
export SQLSERVER2DC_DATACATALOG_PROJECT_ID=cdf-amm
export SQLSERVER2DC_DATACATALOG_LOCATION_ID=us-central1
export SQLSERVER2DC_SQLSERVER_SERVER=10.2.0.2
export SQLSERVER2DC_SQLSERVER_USERNAME=sqlserver
export SQLSERVER2DC_SQLSERVER_PASSWORD=P@ssword@111
export SQLSERVER2DC_SQLSERVER_DATABASE=AdventureWorks2022

google-datacatalog-sqlserver-connector \
--datacatalog-project-id=$SQLSERVER2DC_DATACATALOG_PROJECT_ID \
--datacatalog-location-id=$SQLSERVER2DC_DATACATALOG_LOCATION_ID \
--sqlserver-host=$SQLSERVER2DC_SQLSERVER_SERVER \
--sqlserver-user=$SQLSERVER2DC_SQLSERVER_USERNAME \
--sqlserver-pass=$SQLSERVER2DC_SQLSERVER_PASSWORD \
--sqlserver-database=$SQLSERVER2DC_SQLSERVER_DATABASE  
