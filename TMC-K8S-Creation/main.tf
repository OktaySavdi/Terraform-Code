terraform {
  required_providers {
    tanzu-mission-control = {
      source  = "vmware/tanzu-mission-control"
      version = "1.0.2"
    }
  }
}

provider "tanzu-mission-control" {
  endpoint            = "mycompanyname.tmc.cloud.vmware.com"
  vmw_cloud_api_token = var.api_token
}

# Create Tanzu Mission Control Tanzu Kubernetes Grid Service workload cluster entry
resource "tanzu-mission-control_cluster" "create_tkgs_workload" {
  management_cluster_name = var.endpoint == "stg" ? "mytest-cluster_name" : "myprod-cluster_name"
  provisioner_name        = var.provisioner_name
  name                    = var.cluster_name

  meta {
    labels = { "environment" : var.endpoint == "stg" ? "test" : "prod" }
  }

  spec {
    cluster_group = var.cluster_group
    tkg_service_vsphere {
      settings {
        network {
          pods {
            cidr_blocks = [
              var.network.pods_cidr_blocks,
            ]
          }
          services {
            cidr_blocks = [
              var.network.services_cidr_blocks,
            ]
          }
        }
      }

      distribution {
        version = var.k8s_version
      }

      topology {
        control_plane {
          class             = var.class.control_plane_class
          storage_class     = var.class.control_plane_storage_class
          high_availability = var.node_count.control_plane_high_availability
        }
        node_pools {
          spec {
            worker_node_count = var.node_count.worker_node_count
            node_label = {
              "environment" : var.endpoint == "stg" ? "test" : "prod"
            }

            tkg_service_vsphere {
              class         = var.class.worker_node_class
              storage_class = var.class.worker_node_storage_class
            }
          }
          info {
            name        = var.nodepool_info.name
            description = var.nodepool_info.description
          }
        }
      }
    }
  }
}
