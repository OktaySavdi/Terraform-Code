terraform {
 required_providers {
   kubernetes = {
     source = "hashicorp/kubernetes"
     version = "2.11.0"
   }
 }
}

provider "kubernetes" {
 config_path    = "~/.kube/config"
 config_context = var.cluster_name
}

resource "kubernetes_namespace_v1" "create_namespace" {
 metadata {

   labels = {
     team = var.team_name
   }

   name = var.namespace_name
 }
}

# Cases to compare with expression
variable "quotas" {
    default = {
        "small" = {
            "cpu_requests" = "1"
            "memory_requests" = "2Gi"
            "cpu_limits" = "2"
            "memory_limits" = "2Gi"
        },
        "medium" = {
            "cpu_requests" = "1"
            "memory_requests" = "2Gi"
            "cpu_limits" = "2"
            "memory_limits" = "4Gi"
        },
        "large" = {
            "cpu_requests" = "2"
            "memory_requests" = "4Gi"
            "cpu_limits" = "2"
            "memory_limits" = "8Gi"
        },
        "xlarge" = {
            "cpu_requests" = "4"
            "memory_requests" = "8Gi"
            "cpu_limits" = "8"
            "memory_limits" = "16Gi"
        },
        "xxxlarge" = {
            "cpu_requests" = "4"
            "memory_requests" = "8Gi"
            "cpu_limits" = "8"
            "memory_limits" = "16Gi"
        }
    }
}

# Module do switch-case for you
module "quota-switch-case" {
    source = "github.com/lonnyantunes/terraform-provider-switch-case"
    expression = var.profile
    cases = var.quotas
}

resource "kubernetes_resource_quota_v1" "first_quota" {
 metadata {
   name = var.profile
   namespace = var.namespace_name
   labels = {
     team = var.team_name
   }
 }
 spec {
   hard = {
     "requests.cpu" = module.quota-switch-case.result.cpu_requests
     "requests.memory"  = module.quota-switch-case.result.memory_requests
     "limits.cpu"  = module.quota-switch-case.result.cpu_limits
     "limits.memory" = module.quota-switch-case.result.memory_limits
   }
   #scopes = ["BestEffort"]
 }
}

resource "kubernetes_limit_range_v1" "first_limitrange" {
  metadata {
    name = var.profile
    namespace = var.namespace_name
    labels = {
     team = var.team_name
   }
  }
  spec {
    limit {
      type = "Container"
      max = {
        cpu    = "800m"
        memory = "1Gi"
      }
      min = {
        cpu    = "100m"
        memory = "100Mi"
      }
      default = {
        cpu    = "700m"
        memory = "900Mi"
      }
      default_request = {
        cpu    = "110m"
        memory = "110Mi"
      }
    }
  }
}
