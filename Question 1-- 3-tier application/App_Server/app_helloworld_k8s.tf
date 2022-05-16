data "google_client_config" "provider" {}

data "google_container_cluster" "my_cluster" {
  depends_on = [
    google_container_cluster.helloworld_gke
  ]
  name     = "helloworld_gke"
  location = "us-central1-c"
}

provider "kubernetes" {
  load_config_file = true

  host  = "https://${data.google_container_cluster.my_cluster.endpoint}"
  token = data.google_client_config.provider.access_token
  cluster_ca_certificate = base64decode(
    data.google_container_cluster.my_cluster.master_auth.0.cluster_ca_certificate,
  )
}

resource "google_compute_address" "static_ip" {
  name = "static-ip-address"
  region = "us-central1"
  project = "app-project-asdf"
}

output "static_ip_helloworld" {
  value = google_compute_address.static_ip.address
}

#deployment
resource "kubernetes_deployment" "helloworld_deploy" {
  metadata {
    name = "helloworld-python"
    labels = {
      app = "helloworld-python"
    }
  }
  spec {
      replicas = 1
    selector {
      match_labels = {
        app = "helloworld-python"
      }
    }
    template {
      metadata {
        labels = {
          app = "helloworld-python"
        }
      }
      spec {
        container {
          image = "helloworld-python"
          name  = "helloworld-python-pod"
          env {
            name = "helloworld-python_DB_HOST"
            value = var.pubip
            }
          env {
            name = "helloworld-python_DB_DATABASE"
            value = var.dbname
            }
          env {
            name = "helloworld-python_DB_USER"
            value = var.uname
            }
          env {
            name = "helloworld-python_DB_PASSWORD"
            value = var.pass
          }
          port {
        container_port = 80
          }
        }
      }
    }
  }
}

# service 
resource "kubernetes_service" "helloworld_service" {
  metadata {
    name = "helloworld-service"
   
  }
  spec {
    load_balancer_ip = google_compute_address.static_ip.address
    selector = {
      app = "helloworld-python"
    }
    port {
      port        = 80
      target_port = 80
    }
    type = "LoadBalancer"
  
  }
}

# output "ip" {
#     value = kubernetes_service.helloworld_service.load_balancer_ingress.0.ip
# }
