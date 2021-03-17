resource "kubernetes_deployment" "php_to_scaleout" {
  metadata {
    name = "php-to-scaleout"
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "php"
      }
    }

    template {
      metadata {
        labels = {
          app = "php"
        }
      }

      spec {
        container {
          name  = "php-to-scaleout"
          image = "us.gcr.io/k8s-artifacts-prod/hpa-example"

          port {
            container_port = 80
          }

          resources {
            limits {
              cpu    = "500m"
              memory = "512Mi"
            }

            requests {
              cpu    = "200m"
              memory = "512Mi"
            }
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "php" {
  metadata {
    name = "php"
  }

  spec {
    port {
      protocol    = "TCP"
      port        = 80
      target_port = "80"
    }

    selector = {
      app = "php"
    }

    # type = "LoadBalancer"
  }
}

