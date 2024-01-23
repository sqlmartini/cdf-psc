/******************************************
Local variables declaration
 *****************************************/

locals {
project_id                  = "${var.project_id}"
project_nbr                 = "${var.project_number}"
admin_upn_fqn               = "${var.gcp_account_name}"
location                    = "${var.gcp_region}"
umsa                        = "cdf-lab-sa"
umsa_fqn                    = "${local.umsa}@${local.project_id}.iam.gserviceaccount.com"
vpc_nm                      = "vpc-main"
spark_subnet_nm             = "spark-snet"
spark_subnet_cidr           = "10.0.0.0/16"
composer_subnet_nm          = "composer-snet"
composer_subnet_cidr        = "10.1.0.0/16"
compute_subnet_nm           = "compute-snet"
compute_subnet_cidr         = "10.2.0.0/16"
cdf_name                    = "${var.cdf_name}"
cdf_version                 = "${var.cdf_version}"
cdf_release                 = "${var.cdf_release}"
bq_datamart_ds              = "adventureworks"
CDF_GMSA_FQN                = "serviceAccount:service-${local.project_nbr}@gcp-sa-datafusion.iam.gserviceaccount.com"
GCE_GMSA_FQN                = "${local.project_nbr}-compute@developer.gserviceaccount.com"
cloudsql_bucket_nm          = "${local.project_id}-cloudsql-backup"
}

/******************************************
1. User Managed Service Account Creation
 *****************************************/
module "umsa_creation" {
  source     = "terraform-google-modules/service-accounts/google"
  project_id = local.project_id
  names      = ["${local.umsa}"]
  display_name = "User Managed Service Account"
  description  = "User Managed Service Account for CDF"
}

/******************************************
2a. IAM role grants to User Managed Service Account
 *****************************************/

module "umsa_role_grants" {
  source                  = "terraform-google-modules/iam/google//modules/member_iam"
  service_account_address = "${local.umsa_fqn}"
  prefix                  = "serviceAccount"
  project_id              = local.project_id
  project_roles = [    
    "roles/iam.serviceAccountUser",
    "roles/iam.serviceAccountTokenCreator",
    "roles/storage.objectViewer",
    "roles/storage.admin",
    "roles/dataproc.worker",
    "roles/dataproc.editor",
    "roles/bigquery.dataEditor",
    "roles/bigquery.admin",
    "roles/datafusion.runner",
    "roles/iam.serviceAccountUser",
    "roles/cloudsql.client"
  ]
  depends_on = [module.umsa_creation]
}

/******************************************
2b. IAM role grants to Google Managed 
Service Account for Cloud Data Fusion
 *****************************************/

resource "google_project_iam_binding" "gmsa_role_grants_serviceagent" {
  project = local.project_id
  role    = "roles/datafusion.serviceAgent"
  members = [
    "${local.CDF_GMSA_FQN}"
  ]
}

resource "google_project_iam_binding" "gmsa_role_grants_serviceaccountuser" {
  project = local.project_id
  role    = "roles/iam.serviceAccountUser"
  members = [
    "${local.CDF_GMSA_FQN}"
  ]
}

resource "google_project_iam_binding" "gmsa_role_grants_cloudsqlclient" {
  project = local.project_id
  role    = "roles/cloudsql.client"
  members = [
    "${local.CDF_GMSA_FQN}"
  ]
}

resource "google_project_iam_binding" "gmsa_role_grants_datalineageproducer" {
  project = local.project_id
  role    = "roles/datalineage.producer"
  members = [
    "${local.CDF_GMSA_FQN}"
  ]
}

resource "google_project_iam_binding" "gmsa_role_grants_networkviewer" {
  project = local.project_id
  role    = "roles/compute.networkViewer"
  members = [
    "${local.CDF_GMSA_FQN}"
  ]
}

/******************************************************
3. Service Account Impersonation Grants to Admin User
 ******************************************************/

module "umsa_impersonate_privs_to_admin" {
  source  = "terraform-google-modules/iam/google//modules/service_accounts_iam/"

  service_accounts = ["${local.umsa_fqn}"]
  project          = local.project_id
  mode             = "additive"
  bindings = {
    "roles/iam.serviceAccountUser" = [
      "user:${local.admin_upn_fqn}"
    ],
    "roles/iam.serviceAccountTokenCreator" = [
      "user:${local.admin_upn_fqn}"
    ]
  }
  depends_on = [
    module.umsa_creation
  ]
}

/******************************************************
4. IAM role grants to Admin User
 ******************************************************/

module "administrator_role_grants" {
  source   = "terraform-google-modules/iam/google//modules/projects_iam"
  projects = ["${local.project_id}"]
  mode     = "additive"

  bindings = {
    "roles/storage.admin" = [
      "user:${local.admin_upn_fqn}",
    ]
    "roles/metastore.admin" = [

      "user:${local.admin_upn_fqn}",
    ]
    "roles/dataproc.admin" = [
      "user:${local.admin_upn_fqn}",
    ]
    "roles/bigquery.admin" = [
      "user:${local.admin_upn_fqn}",
    ]
    "roles/bigquery.user" = [
      "user:${local.admin_upn_fqn}",
    ]
    "roles/bigquery.dataEditor" = [
      "user:${local.admin_upn_fqn}",
    ]
    "roles/bigquery.jobUser" = [
      "user:${local.admin_upn_fqn}",
    ]
    "roles/composer.environmentAndStorageObjectViewer" = [
      "user:${local.admin_upn_fqn}",
    ]
    "roles/iam.serviceAccountUser" = [
      "user:${local.admin_upn_fqn}",
    ]
    "roles/iam.serviceAccountTokenCreator" = [
      "user:${local.admin_upn_fqn}",
    ]
    "roles/composer.admin" = [
      "user:${local.admin_upn_fqn}",
    ]
    "roles/compute.networkAdmin" = [
      "user:${local.admin_upn_fqn}",
    ]
    "roles/datafusion.admin" = [
      "user:${local.admin_upn_fqn}",
    ]    
  }
  depends_on = [
    module.umsa_role_grants,
    module.umsa_impersonate_privs_to_admin
  ]

  }

/*******************************************
Introducing sleep to minimize errors from
dependencies having not completed
********************************************/
resource "time_sleep" "sleep_after_identities_permissions" {
  create_duration = "120s"
  depends_on = [
    module.umsa_creation,
    module.umsa_role_grants,
    module.umsa_impersonate_privs_to_admin,
    module.administrator_role_grants,
    google_project_iam_binding.gmsa_role_grants_serviceagent,
    google_project_iam_binding.gmsa_role_grants_serviceaccountuser,
    google_project_iam_binding.gmsa_role_grants_cloudsqlclient,
    google_project_iam_binding.gmsa_role_grants_datalineageproducer
  ]
}

/******************************************
5. VPC Network & Subnet Creation & Network Attachment
 *****************************************/
module "vpc_creation" {
  source                                 = "terraform-google-modules/network/google"
  version                                = "~> 9.0"
  project_id                             = local.project_id
  network_name                           = local.vpc_nm
  routing_mode                           = "REGIONAL"

  subnets = [
    {
      subnet_name           = "${local.spark_subnet_nm}"
      subnet_ip             = "${local.spark_subnet_cidr}"
      subnet_region         = "${local.location}"
      subnet_range          = local.spark_subnet_cidr
      subnet_private_access = true
    }
    ,
    {
      subnet_name           = "${local.composer_subnet_nm}"
      subnet_ip             = "${local.composer_subnet_cidr}"
      subnet_region         = "${local.location}"
      subnet_range          = local.composer_subnet_cidr
      subnet_private_access = true
    }    
    ,
    {
      subnet_name           = "${local.compute_subnet_nm}"
      subnet_ip             = "${local.compute_subnet_cidr}"
      subnet_region         = "${local.location}"
      subnet_range          = local.compute_subnet_cidr
      subnet_private_access = true
    }    
  ]
  depends_on = [time_sleep.sleep_after_identities_permissions]
}

output "subnet" {
  value = tolist(module.vpc_creation.subnet_ids)[2]
}

/*
resource "google_compute_network_attachment" "default" {
    provider = google-beta
    name = "basic-network-attachment"
    region = "us-central1"
    description = "basic network attachment description"
    connection_preference = "ACCEPT_MANUAL"

    subnetworks = [
        #google_compute_subnetwork.default.self_link
        vpc_creation.su
    ]

    producer_accept_lists = [
        google_project.accepted_producer_project.project_id
    ]
}
*/