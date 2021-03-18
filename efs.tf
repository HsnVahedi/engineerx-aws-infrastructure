resource "aws_security_group" "eks_efs_group" {
  name        = "eks-efs-group"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port   = 2049
    to_port     = 2049
    protocol    = "tcp"
    cidr_blocks = [module.vpc.cidr_block]
  }
}

resource "aws_efs_file_system" "media_efs" {

}

resource "aws_efs_mount_target" "media_efs_mount_targets" {
  for_each       = toset(module.vpc.public_subnets)
  subnet_id      = each.id
  file_system_id = aws_efs_file_system.media_efs.id
  security_groups = [aws_security_group.eks_efs_group.id]
}

data "kustomization" "kustomization_info" {
  provider = kustomization
  path = "github.com/kubernetes-sigs/aws-efs-csi-driver/deploy/kubernetes/overlays/stable/?ref=release-1.0"
}

resource "kustomization_resource" "kustomization_resources" {
  provider = kustomization

  for_each = data.kustomization.kustomization_info.ids

  manifest = data.kustomization.kustomization_info.manifests[each.value]
}

resource "kubernetes_storage_class" "efs_sc" {
  metadata {
    name = "efs-sc"
    storage_provisioner = "efs.csi.aws.com"
  }
}

resource "kubernetes_persistent_volume" "media_efs_pvc" {
  metadata {
    name = "media-efs-pvc"
  }

  spec {
    capacity = {
      storage = "5Gi"
    }

    access_modes                     = ["ReadWriteMany"]
    persistent_volume_reclaim_policy = "Retain"
    storage_class_name               = "efs-sc"
    csi = {
      driver = "efs.csi.aws.com"
      volume_handle =  aws_efs_file_system.media_efs.id
    }
  }
}

resource "kubernetes_persistent_volume_claim" "efs_storage_claim" {
  metadata {
    name      = "efs-storage-claim"
    namespace = "storage"
  }

  spec {
    access_modes = ["ReadWriteMany"]

    resources {
      requests = {
        storage = "5Gi"
      }
    }

    storage_class_name = "efs-sc"
  }
}
