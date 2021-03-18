resource "kubernetes_namespace" "bakend_test" {
  metadata {
    name = "backend-test"
    labels = {
      role = "infrastructure"
    }
  }
}

resource "kubernetes_namespace" "frontend_test" {
  metadata {
    name = "frontend-test"
    labels = {
      role = "infrastructure"
    }
  }
}

resource "kubernetes_namespace" "integration_test" {
  metadata {
    name = "integration-test"
    labels = {
      role = "infrastructure"
    }
  }
}
