variable "project_id" {
  type        = string
  description = "project id required"
}
variable "project_number" {
 type        = string
 description = "project number"
}
variable "gcp_account_name" {
 type        = string    
 description = "lab user's FQN"
}
variable "cdf_name" {
 type        = string    
 description = "Name of Cloud Data Fusion instance to use"
}
variable "cdf_version" {
 type        = string    
 description = "Version of Cloud Data Fusion to use"
}
variable "cdf_release" {
 type        = string    
 description = "Release of Cloud Data Fusion to use"
}
variable "gcp_region" {
 type        = string    
 description = "The GCP region you want to use"
}