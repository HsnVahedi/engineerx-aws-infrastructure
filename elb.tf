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

locals {
  lb_name = split("-", split(".", kubernetes_service.ingress.status.0.load_balancer.0.ingress.0.hostname).0).0
}

data "aws_elb" "elb" {
  name = local.lb_name
}

output "load_balancer_hostname" {
  value = kubernetes_service.ingress.status.0.load_balancer.0.ingress.0.hostname
}