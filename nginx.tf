resource "kubernetes_deployment" "nginx_to_scaleout" {
  metadata {
    name = "nginx-to-scaleout"
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "nginx"
      }
    }

    template {
      metadata {
        labels = {
          app = "nginx"
        }
      }

      spec {
        container {
          name  = "nginx-to-scaleout"
          image = "nginx"

          port {
            container_port = 80
          }

          resources {
            limits {
              cpu    = "500m"
              memory = "512Mi"
            }

            requests {
              cpu    = "500m"
              memory = "512Mi"
            }
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "nginx" {
  metadata {
    name = "nginx"
  }

  spec {
    port {
      protocol    = "TCP"
      port        = 80
      target_port = "80"
    }

    selector = {
      app = "nginx"
    }

    type = "LoadBalancer"
  }
}

