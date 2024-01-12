data "archive_file" "function_archive" {
  type             = "zip"
  source_dir       = "./${var.function_path}/"
  output_file_mode = "0777"
  output_path      = "./output/${var.name}.zip"
}


resource "google_cloud_scheduler_job" "job" {
  name        = var.name
  description = "Runs ${var.name} job"
  schedule    = var.schedule

  pubsub_target {
    # topic.id is the topic's full resource name.
    topic_name = google_pubsub_topic.pubsub_topic.id
    data       = base64encode("run job")
  }
}

resource "google_storage_bucket_object" "bucket_obj" {
  name   = "${var.name}.zip"
  bucket = google_storage_bucket.bucket.name
  source = "output/${var.name}.zip"
}

resource "google_pubsub_topic" "pubsub_topic" {
  name = var.name
}

resource "google_cloudfunctions2_function" "gcf_func" {
  name        = var.name
  description = var.name
  project     = var.project
  location    = var.region

  build_config {
    runtime     = var.runtime
    entry_point = var.entry_point # Set the entry point 
    source {
      storage_source {
        bucket = google_storage_bucket.bucket.name
        object = google_storage_bucket_object.bucket_obj.name
      }
    }
  }
  
  labels = {
    git_commit           = "2bdc0871a5f4505be58244029cc6485d45d7bb8e"
    git_file             = "terraform__gcp__instances_tf"
    git_org              = "benchsci"
    git_repo             = "benchsci"
  }

  service_config {
    max_instance_count = 1
    available_memory   = var.memory
    timeout_seconds    = 540
    ingress_settings   = "ALLOW_ALL"
  }

  event_trigger {
    trigger_region = "us-east1"
    event_type     = "google.cloud.pubsub.topic.v1.messagePublished"
    pubsub_topic   = google_pubsub_topic.pubsub_topic.id
    retry_policy   = "RETRY_POLICY_DO_NOT_RETRY"
  }
}


data "google_iam_policy" "admin" {
  binding {
    role = "roles/cloudfunctions.admin"
    members = [
      "allAuthenticatedUsers",
    ]
  }
}

resource "google_cloudfunctions2_function_iam_policy" "policy" {
  project = google_cloudfunctions2_function.gcf_func.project
  location = google_cloudfunctions2_function.gcf_func.location
  cloud_function = google_cloudfunctions2_function.gcf_func.name
  policy_data = data.google_iam_policy.admin.policy_data
}