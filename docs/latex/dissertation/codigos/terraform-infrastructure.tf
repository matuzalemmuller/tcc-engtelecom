variable "gce_ssh_user" {
  default = "matuzalemmuller"
}

variable "gce_ssh_pub_key_file" {
  default = "keys/id_rsa.pub"
}

data "template_file" "startup_script" {
  template = "${file("startup_script.sh")}"
}

provider "google" {
  credentials = "${file("keys/gcp.json")}"
  project     = "k8s-test-cluster-215603"
  region      = "southamerica-east1"
}

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
    ports    = ["22", "53", "80", "443", "2380", "2379", "3306", "6443", "6790", "6800-7300", "8124", "9283", "10250", "10254", "30000-32767", "44134"]
  }

  allow {
    protocol = "udp"
    ports    = ["53", "8472"]
  }
}

resource "google_compute_instance" "vm-0" {
  name         = "vm-0"
  machine_type = "n1-standard-2"
  zone         = "southamerica-east1-a"

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-9"
      size = "15"
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

  metadata_startup_script = "${data.template_file.startup_script.rendered}"

  tags = ["k8s"]
}

resource "google_compute_instance" "vm-1" {
  name         = "vm-1"
  machine_type = "n1-standard-2"
  zone         = "southamerica-east1-a"

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-9"
      size = "15"
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

  metadata_startup_script = "${data.template_file.startup_script.rendered}"

  tags = ["k8s"]
}

resource "google_compute_instance" "vm-2" {
  name         = "vm-2"
  machine_type = "n1-standard-2"
  zone         = "southamerica-east1-a"

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-9"
      size = "15"
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

  metadata_startup_script = "${data.template_file.startup_script.rendered}"

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
