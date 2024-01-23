terraform {
  #required_version = ">= 0.13"
  required_version = ">= 1.3.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      #version = ">=4.45.0"
      version = ">=5.1.0"
    }

    google-beta = {
      source = "hashicorp/google-beta"
      version = ">=5.1.0"
    }
  }
}