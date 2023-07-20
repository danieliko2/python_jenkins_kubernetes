terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.48.0"
    }

    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.16.1"
    }

  }
}

variable "FILEBEAT_IMAGE" {
  type = string
}

variable "PYTHON_DOCKER_IMAGE" {
  type = string
}

data "kubernetes_config_map" "my-configmap" {
  metadata {
    name = "elastic-ip-configmap"
  }
}

data "kubernetes_secret" "my-secret" {
  metadata {
    name = "mysecret"
  }

}

data "terraform_remote_state" "eks" {
  backend = "local"

  config = {
    path = "../provision-eks/terraform.tfstate"
  }
}

# Retrieve EKS cluster information
provider "aws" {
  region = data.terraform_remote_state.eks.outputs.region
}

data "aws_eks_cluster" "cluster" {
  name = data.terraform_remote_state.eks.outputs.cluster_name
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    args = [
      "eks",
      "get-token",
      "--cluster-name",
      data.aws_eks_cluster.cluster.name
    ]
  }
}

resource "kubernetes_deployment" "python-app" {
  metadata {
    name = "python-app"
    labels = {
      App = "python-app"
    }
  }

  spec {
    replicas = 2
    selector {
      match_labels = {
        App = "python-app"
      }
    }
    template {
      metadata {
        labels = {
          App = "python-app"
        }
      }
      spec {

        # Create a shared volume
        volume {
          name = "shared-data"
          empty_dir {}
        }

        container {
          image             = "${var.PYTHON_DOCKER_IMAGE}"
          name              = "my-python-app"
          image_pull_policy = "Always"

          volume_mount {
            name      = "shared-data"
            mount_path = "/app/log"
          }

          port {
            container_port = 8000
          }

          env {
            name = "MONGO_PASS"
            value_from {
              secret_key_ref {
                name = "mysecret"
                key  = "MY_ENV_MONGO"
              }
            }
          }

          resources {
            limits = {
              cpu    = "0.5"
              memory = "512Mi"
            }
            requests = {
              cpu    = "250m"
              memory = "50Mi"
            }
          }
        }

        container {
          image             = "${var.FILEBEAT_IMAGE}"
          name              = "my-filebeat"
          image_pull_policy = "Always"

          volume_mount {
            name      = "shared-data"
            mount_path = "/usr/share/filebeat/python_log"
          }

          env {
            name = "ELASTIC_IP"
            value = data.kubernetes_config_map.my-configmap.data["my_elastic_ip"]
          }

          resources {
            limits = {
              cpu    = "0.5"
              memory = "512Mi"
            }
            requests = {
              cpu    = "250m"
              memory = "50Mi"
            }
          }
        }

      }
    }
  }
}

resource "kubernetes_service" "python-app" {
  metadata {
    name = "python-app"
  }
  spec {
    selector = {
      App = kubernetes_deployment.python-app.spec.0.template.0.metadata[0].labels.App
    }
    port {
      port        = 80
      target_port = 8000
    }

    type = "LoadBalancer"
  }
}

output "lb_ip" {
  value = kubernetes_service.python-app.status.0.load_balancer.0.ingress.0.hostname
}