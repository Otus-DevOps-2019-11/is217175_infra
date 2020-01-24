terraform {
  required_version = ">= 0.12.8"
  backend "gcs" {
    bucket = "tfstate_bucket"
    prefix = "terraform/prod"
  }
}
