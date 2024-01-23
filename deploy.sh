#Configure project you want to deploy to
export PROJECT_ID="cdf-amm"
cd ~/repos/cdf-psc/core-tf/scripts
source 1-config.sh

#Run Terraform for organization policy edits and enabling Google APIs
cd ~/repos/cdf-psc/foundations-tf
terraform init
terraform apply \
  -var="project_id=${PROJECT_ID}" \
  -auto-approve

#Set Terraform variables
cd ~/repos/cdf-psc/core-tf
PROJECT_NBR=`gcloud projects describe $PROJECT_ID | grep projectNumber | cut -d':' -f2 |  tr -d "'" | xargs`
GCP_ACCOUNT_NAME=`gcloud auth list --filter=status:ACTIVE --format="value(account)"`
GCP_REGION="us-central1"
CDF_NAME="cdf1"
CDF_VERSION="BASIC"
CDF_RELEASE="6.9.2"

#Run the Terraform for provisioning the rest of the environment
terraform init
terraform apply \
  -var="project_id=${PROJECT_ID}" \
  -var="project_number=${PROJECT_NBR}" \
  -var="gcp_account_name=${GCP_ACCOUNT_NAME}" \
  -var="gcp_region=${GCP_REGION}" \
  -var="cdf_name=${CDF_NAME}" \
  -var="cdf_version=${CDF_VERSION}" \
  -var="cdf_release=${CDF_RELEASE}" \
  -auto-approve

#Download AdventureWorks sample database
mkdir ~/repos/cdf-psc/core-tf/database
cd ~/repos/cdf-psc/core-tf/database
curl -LJO https://github.com/Microsoft/sql-server-samples/releases/download/adventureworks/AdventureWorks2022.bak

#Import sample database to Cloud SQL
cd ~/repos/cdf-psc/core-tf/scripts
source 2-cloudsql.sh

#Modify compute profile
cd ~/repos/cdf-psc/core-tf/profiles
sed -i "s/<PROJECT_ID>/$PROJECT_ID/g" test-computeprofile.json

#Modify pipeline
cd ~/repos/cdf-psc/core-tf/
IP=$(terraform output -json | jq -r '.sql_proxy_ip.value')

cd ~/repos/cdf-psc/core-tf/pipelines
sed -i "s/<SQL-PROXY-IP>/$IP/g" test-cdap-data-pipeline.json

#Deploy
cd ~/repos/cdf-psc/core-tf/scripts
source 3-datafusion.sh