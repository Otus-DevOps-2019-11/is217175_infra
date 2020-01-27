provider "google" {
  version = "3.4.0"
  project = var.project
  region  = var.region
}

module "app" {
  source           = "../modules/app"
  public_key_path  = var.public_key_path
  private_key_path = var.private_key_path
  zone             = var.zone
  app_disk_image   = var.app_disk_image
  deploy           = var.deploy
  db_addr          = module.db.db_addr
  labels           = {"ansible_group": "app"}
}

module "db" {
  source           = "../modules/db"
  public_key_path  = var.public_key_path
  zone             = var.zone
  db_disk_image    = var.db_disk_image
  private_key_path = var.private_key_path
  deploy           = var.deploy
  labels           = {"ansible_group": "db"}
}

module "vpc" {
  source        = "../modules/vpc"
  source_ranges = ["192.0.2.1/32"]
}
