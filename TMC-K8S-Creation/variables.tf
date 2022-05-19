variable "endpoint" {
  default = "stg" #stg or prod
}

variable "api_token" {
  default = "***********************************************"
}

variable "provisioner_name" {
  default = "my-provisioner-name" # tmc managementcluster provisioner list
}

variable "cluster_name" {
  default = "my_new_cluster_name"
}

variable "cluster_group" {
  default = "my_cluster_group"
}

variable "network" {
  type = map(string)
  default = {
    pods_cidr_blocks     = "172.20.0.0/16" # pods cidr block by default has the value `172.20.0.0/16`
    services_cidr_blocks = "10.96.0.0/16"  # services cidr block by default has the value `10.96.0.0/16`
  }
}

variable "k8s_version" {
  default = "v1.21.6+vmware.1-tkg.1.b3d708a"
}

variable "class" {
  type = map(string)
  default = {
    control_plane_class         = "best-effort-xsmall"
    control_plane_storage_class = "my-sc"
    worker_node_class           = "best-effort-xsmall"
    worker_node_storage_class   = "my-sc"
  }
}

variable "node_count" {
  type = map(string)
  default = {
    control_plane_high_availability = false # If false, only 1 controler will be created. if you set true. There will be 3 controllers
    worker_node_count               = 1
  }
}

variable "nodepool_info" {
  type = map(string)
  default = {
    name        = "myckuster-nodepool" # default node pool name `default-nodepool`
    description = "tkgs workload nodepool"
  }
}
