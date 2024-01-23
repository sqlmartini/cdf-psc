terraform {
  required_version = ">= 1.7"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">=5.13.0"
    }

    google_beta = {
      source = "hashicorp/google-beta"
      version = ">=5.13.0"
    }
  }
}