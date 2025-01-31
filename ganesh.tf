provider "google" {
 project = "mythic-inn-420620"
 zone="us-central1-a"
 region = "us-central1"

}

locals {
  names=["sam","jam","cam"]
  file =["h1.txt","okay.txt"]
}

resource "google_compute_network" "net1" {
    name = "net1"
    auto_create_subnetworks = false

  
}

resource "google_compute_firewall" "fire1" {
    name = "firezone"
    network = google_compute_network.net1.id
    source_ranges = ["0.0.0.0/0"]
    
    allow {
      protocol = "tcp"
      ports = [80,84,22]
    }
    
  
}

resource "google_compute_subnetwork" "sub1" {
    name = "opps"
    network = google_compute_network.net1.id
   
    ip_cidr_range = "10.2.0.0/16"
    region        = "us-central1"
}



resource "google_compute_disk" "disks" {
  for_each = toset(local.names)  # Creates a disk for each instance

  name = "disk-${each.key}"      # Unique name for each disk
  size = 40
  zone = "us-central1-a"
}


resource "google_compute_instance" "multi" {
    for_each = toset(local.names)

    name = "instance-${each.key}"
    machine_type = "e2-micro"
    boot_disk {
      initialize_params {
        image = "centos-stream-9"
      }
    } 
    network_interface {
      network = google_compute_network.net1.id
      subnetwork = google_compute_subnetwork.sub1.id
      
      access_config {
    
        
      }
    }

    attached_disk {
    source      = google_compute_disk.disks[each.key].id  # Corrected reference
    device_name = "disk-${each.key}"
    mode        = "READ_WRITE"  # Ensures full access to the disk
  }
  
  
}


resource "google_storage_bucket" "tf_state" {
  name     = "ssuurrpphwghwg"
  location = "us-central1"  # Change to the region where you want to store the bucket
 
}
resource "google_storage_bucket_object" "obj" {
  bucket =  google_storage_bucket.tf_state.name 
  count = length(local.file)
  name = local.file[count.index]
  source = "${local.file[count.index]}"
}
#
#

terraform {
  backend "gcs" {
    credentials = "file.json"
    bucket = "dk7610"   # Your GCS bucket name
    prefix = "terraform/state"             # Path inside the bucket where the state file will be stored
  }
}
