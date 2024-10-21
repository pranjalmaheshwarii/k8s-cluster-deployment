terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 3.5" # Adjust as needed
    }
  }

  required_version = ">= 0.12"
}

provider "google" {
  credentials = file("service-account-key.json")  # Path to your service account key
  project     = var.project_id
  region      = var.region
}

variable "project_id" {
  description = "The ID of the project in GCP"
  type        = string
}

variable "cluster_name" {
  description = "The name of the Kubernetes cluster"
  type        = string
}

variable "region" {
  description = "The region where the cluster will be created"
  type        = string
}

resource "google_container_cluster" "primary" {
  name     = var.cluster_name
  location = var.region

  # Enable private cluster
  private_cluster_config {
    enable_private_endpoint = true
    enable_private_nodes    = true
    master_ipv4_cidr_block  = "10.0.0.0/28"  # Adjust CIDR block as necessary
  }

  # Enable master authorized networks with a reserved CIDR block
  master_authorized_networks_config {
    cidr_blocks {
      cidr_block   = "10.128.0.0/20"  # Example CIDR block from your VPC (adjust as needed)
      display_name = "Jenkins Network"
    }
  }

  initial_node_count = 1

  node_config {
    machine_type = "e2-medium"  # Adjust based on your needs
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform",
    ]
  }
}

output "kubeconfig" {
  value = google_container_cluster.primary.endpoint
}

output "cluster_name" {
  value = google_container_cluster.primary.name
}

output "cluster_location" {
  value = google_container_cluster
