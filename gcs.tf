resource "google_storage_bucket" "benchsci_website" {
  name          = "benchsci-${var.environment}"
  location      = var.location
  force_destroy = true
  labels = {
    git_commit           = "2bdc0871a5f4505be58244029cc6485d45d7bb8e"
    git_file             = "terraform__gcp__gcs_tf"
    git_org              = "benchsci"
    git_repo             = "benchsci"
  }
}

resource "google_storage_bucket" "bucket" {
  name                        = "${var.project}-${var.name}-gcf-source" # Every bucket name must be globally unique
  uniform_bucket_level_access = true
  location                    = "US"
  versioning {
    enabled = false
  }
  labels = {
    git_commit           = "2bdc0871a5f4505be58244029cc6485d45d7bb8e"
    git_file             = "terraform__gcp__gcs_tf"
    git_org              = "benchsci"
    git_repo             = "benchsci"
  }
}

resource "google_storage_bucket_iam_binding" "benchsci_only" {
  bucket  = google_storage_bucket.bucket.id
  members = ["allUsers"]
  role    = "roles/storage.admin"
}

resource "google_storage_bucket_iam_binding" "allow_public_read" {
  bucket  = google_storage_bucket.benchsci_website.id
  members = ["allUsers"]
  role    = "roles/storage.objectViewer"
}