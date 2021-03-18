locals {
  k8s_service_account_namespace = "kube-system"
  k8s_service_account_name      = "cluster-autoscaler-aws-cluster-autoscaler-chart"

  # non-default context name to protect from using wrong kubeconfig
  kubeconfig_context = "_terraform-kustomization-${var.cluster_name}_"

  kubeconfig = {
    apiVersion = "v1"
    clusters = [
      {
        name = local.kubeconfig_context
        cluster = {
          certificate-authority-data = data.aws_eks_cluster.cluster.certificate_authority.0.data
          server                     = data.aws_eks_cluster.cluster.endpoint
        }
      }
    ]
    users = [
      {
        name = local.kubeconfig_context
        user = {
          token = data.aws_eks_cluster_auth.cluster.token
        }
      }
    ]
    contexts = [
      {
        name = local.kubeconfig_context
        context = {
          cluster = local.kubeconfig_context
          user    = local.kubeconfig_context
        }
      }
    ]
  }
}
