// Variables
variable "gce_ssh_user" {
  default = "matuzalemmuller"
}

variable "gce_ssh_pub_key_file" {
  default = "keys/id_rsa.pub"
}

// Provider
provider "google" {
  // https://console.cloud.google.com/apis/credentials/serviceaccountkey
  credentials = "${file("keys/gcp.json")}"
  project     = "k8s-test-cluster-215603"
  region      = "southamerica-east1"
}

// Network
resource "google_compute_network" "network-0" {
  name = "network-0"
}

resource "google_compute_subnetwork" "subnet-0" {
  name          = "subnet-0"
  ip_cidr_range = "10.0.0.0/24"
  network       = "${google_compute_network.network-0.self_link}"
}

resource "google_compute_address" "address-0" {
  name         = "address-0"
  subnetwork   = "${google_compute_subnetwork.subnet-0.self_link}"
  address_type = "INTERNAL"
  address      = "10.0.0.100"
}

resource "google_compute_address" "address-1" {
  name         = "address-1"
  subnetwork   = "${google_compute_subnetwork.subnet-0.self_link}"
  address_type = "INTERNAL"
  address      = "10.0.0.101"
}

resource "google_compute_address" "address-2" {
  name         = "address-2"
  subnetwork   = "${google_compute_subnetwork.subnet-0.self_link}"
  address_type = "INTERNAL"
  address      = "10.0.0.102"
}

resource "google_compute_firewall" "firewall-0" {
  name    = "firewall-0"
  network = "${google_compute_network.network-0.name}"

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports    = ["22", "443", "2380", "2379", "6443", "10250"]
  }

  allow {
    protocol = "udp"
    port     = ["500", "4500"]
  }
}

// Compute
resource "google_compute_instance" "master-vm-0" {
  name         = "vm-0"
  machine_type = "n1-standard-2"
  zone         = "southamerica-east1-a"

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-9"
    }
  }

  network_interface {
    subnetwork    = "${google_compute_subnetwork.subnet-0.name}"
    address       = "${google_compute_address.address-0.address}"
    access_config = {}
  }

  metadata {
    sshKeys = "${var.gce_ssh_user}:${file(var.gce_ssh_pub_key_file)}"
  }

  tags = ["k8s"]
}

resource "google_compute_instance" "worker1-vm-1" {
  name         = "vm-1"
  machine_type = "n1-standard-2"
  zone         = "southamerica-east1-a"

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-9"
    }
  }

  network_interface {
    subnetwork    = "${google_compute_subnetwork.subnet-0.name}"
    address       = "${google_compute_address.address-1.address}"
    access_config = {}
  }

  metadata {
    sshKeys = "${var.gce_ssh_user}:${file(var.gce_ssh_pub_key_file)}"
  }

  tags = ["k8s"]
}

resource "google_compute_instance" "worker2-vm-2" {
  name         = "vm-2"
  machine_type = "n1-standard-2"
  zone         = "southamerica-east1-a"

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-9"
    }
  }

  network_interface {
    subnetwork    = "${google_compute_subnetwork.subnet-0.name}"
    address       = "${google_compute_address.address-2.address}"
    access_config = {}
  }

  metadata {
    sshKeys = "${var.gce_ssh_user}:${file(var.gce_ssh_pub_key_file)}"
  }

  tags = ["k8s"]
}

output "external-ip-0" {
  value = "${google_compute_instance.vm-0.network_interface.0.access_config.0.assigned_nat_ip}"
}

output "external-ip-1" {
  value = "${google_compute_instance.vm-1.network_interface.0.access_config.0.assigned_nat_ip}"
}

output "external-ip-2" {
  value = "${google_compute_instance.vm-2.network_interface.0.access_config.0.assigned_nat_ip}"
}
