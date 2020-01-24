provider "google" {
  version = "3.4.0"
  project = var.project
  region  = var.region
}

resource "google_storage_bucket" "tfstate_storage" {
  name     = "tfstate_bucket"
  location = var.region
}

output "storage-bucket-url" {
  value = google_storage_bucket.tfstate_storage.url
}
