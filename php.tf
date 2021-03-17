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
              cpu    = "300m"
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

resource "kubernetes_horizontal_pod_autoscaler" "php_hpa" {
  metadata {
    name = "php-hpa"
  }

  spec {
    max_replicas = 10
    min_replicas = 1

    target_cpu_utilization_percentage = 80

    scale_target_ref {
      kind = "Deployment"
      name = "php-to-scaleout"
    }
  }
}