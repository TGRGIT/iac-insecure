data "google_compute_zones" "zones" {}

resource "google_compute_instance" "server" {
  machine_type = "n1-standard-1"
  name         = "benchsci-${var.environment}-machine"
  zone         = data.google_compute_zones.zones.names[0]
  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-9"
    }
    auto_delete = true
  }
  network_interface {
    subnetwork = google_compute_subnetwork.public-subnetwork.name
    access_config {}
  }
  can_ip_forward = true

  metadata = {
    block-project-ssh-keys = false
    enable-oslogin         = false
    serial-port-enable     = true
  }
  labels = {
    git_commit           = "2bdc0871a5f4505be58244029cc6485d45d7bb8e"
    git_file             = "terraform__gcp__instances_tf"
    git_org              = "benchsci"
    git_repo             = "benchsci"
  }
}

resource "google_compute_disk" "unencrypted_disk" {
  name = "benchsci-${var.environment}-disk"
  labels = {
    git_commit           = "2bdc0871a5f4505be58244029cc6485d45d7bb8e"
    git_file             = "terraform__gcp__instances_tf"
    git_org              = "benchsci"
    git_repo             = "benchsci"
  }
}