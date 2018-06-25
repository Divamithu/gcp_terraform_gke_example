variable "project" {}
// Configure the Google Cloud provider
provider "google" {
  project     = "${var.project}"
  region      = "us-central1"
}

terraform {
  backend "gcs" {
    bucket  = "<SHARED_BUCKET_NAME>"
    prefix  = "sm"
  }
}
