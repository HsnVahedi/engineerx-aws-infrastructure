resource "kubernetes_service" "ingress" {
  metadata {
    name = "ingress"
    labels = {
      app  = "ingress"
      role = "deployment"
    }
  }

  spec {
    port {
      protocol    = "TCP"
      port        = 80
      target_port = "80"
    }

    selector = {
      app = "ingress"
    }

    type = "LoadBalancer"
  }
}