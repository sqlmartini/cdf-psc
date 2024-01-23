# Ingest data with Cloud Data Fusion from Cloud SQL and load to BigQuery

## About the lab

This repo demonstrates the configuration of a data ingestion process that connects a private Cloud Data Fusion instance to a private Cloud SQL instance.

### Prerequisites

- A pre-created project
- You need to have organization admin rights, and project owner privileges or work with privileged users to complete provisioning.

## 1. Clone this repo in Cloud Shell

```
cd ~
mkdir repos
cd repos
git clone https://github.com/sqlmartini/cdf-psc.git
```

## 2. Foundational provisioning automation with Terraform 
The Terraform in this section updates organization policies and enables Google APIs.<br>

1. Configure project you want to deploy to by running the following in Cloud Shell

```
export PROJECT_ID="enter your project id here"
cd ~/repos/cdf-psc/core-tf/scripts
source 1-config.sh
```

2. Run Terraform for organization policy edits and enabling Google APIs

```
cd ~/repos/cdf-psc/foundations-tf
terraform init
terraform apply \
  -var="project_id=${PROJECT_ID}" \
  -auto-approve
```

**Note:** Wait till the provisioning completes (~5 minutes) before moving to the next section.

## 3. Core resource provisioning automation with Terraform 

### 3.1. Resources provisioned
In this section, we will provision:
1. User Managed Service Account and role grants
2. Network, subnets, firewall rules
3. Private IP allocation for Cloud Data Fusion
4. Data Fusion instance and VPC peering connection
5. BigQuery dataset
6. Cloud SQL instance
7. GCE SQL proxy VM with static private IP

### 3.2. Run the terraform scripts

1. Paste this in Cloud Shell after editing the GCP region variable to match your nearest region-

```
cd ~/repos/cdf-psc/core-tf
PROJECT_NBR=`gcloud projects describe $PROJECT_ID | grep projectNumber | cut -d':' -f2 |  tr -d "'" | xargs`
GCP_ACCOUNT_NAME=`gcloud auth list --filter=status:ACTIVE --format="value(account)"`
GCP_REGION="us-central1"
CDF_NAME="cdf1"
CDF_VERSION="BASIC"
CDF_RELEASE="6.10.0"
```

2. Run the Terraform for provisioning the rest of the environment

```
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
```

**Note:** Takes ~20 minutes to complete.

## 4. Download and import Cloud SQL- SQL Server sample database

### 4.1 Download AdventureWorks sample database

```
mkdir ~/repos/cdf-psc/core-tf/database
cd ~/repos/cdf-psc/core-tf/database
curl -LJO https://github.com/Microsoft/sql-server-samples/releases/download/adventureworks/AdventureWorks2022.bak
```

### 4.2 Import sample database to Cloud SQL 

```
cd ~/repos/cdf-psc/core-tf/scripts
source 2-cloudsql.sh
```

## 5. Modify CDF compute profile, pipeline, and deploy

### 5.1. Modify compute profile

Use sed to find/replace in test-computeprofile.json to appropriately set the serviceAccount

```
cd ~/repos/cdf-psc/core-tf/profiles
sed -i "s/<PROJECT_ID>/$PROJECT_ID/g" test-computeprofile.json
```

### 5.2. Modify pipeline

Use sed to find/replace in test-cdap-data-pipeline.json to appropriately set the static IP address of the cloud sql proxy VM

```
cd ~/repos/cdf-psc/core-tf/
IP=$(terraform output -json | jq -r '.sql_proxy_ip.value')

cd ~/repos/cdf-psc/core-tf/pipelines
sed -i "s/<SQL-PROXY-IP>/$IP/g" test-cdap-data-pipeline.json
```

### 5.3 Deploy
Run the shell script to deploy driver, compute profile, and pipeline to Cloud Data Fusion

```
cd ~/repos/cdf-psc/core-tf/scripts
source 3-datafusion.sh
```

## 6. Run the Cloud Data Fusion pipeline
TO-DO create instructions to do this or call by API
