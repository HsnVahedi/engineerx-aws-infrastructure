resource "aws_security_group" "eks_efs_group" {
  name        = "eks-efs-group"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port   = 2049
    to_port     = 2049
    protocol    = "tcp"
    cidr_blocks = [module.vpc.vpc_cidr_block]
  }
}

resource "aws_efs_file_system" "media_efs" {

}

resource "aws_efs_mount_target" "media_efs_mount_targets" {
  count = 3
  subnet_id      = module.vpc.public_subnets[count.index] 
  file_system_id = aws_efs_file_system.media_efs.id
  security_groups = [aws_security_group.eks_efs_group.id]
}

resource "aws_efs_file_system" "static_efs" {

}

resource "aws_efs_mount_target" "static_efs_mount_targets" {
  count = 3
  subnet_id      = module.vpc.public_subnets[count.index] 
  file_system_id = aws_efs_file_system.static_efs.id
  security_groups = [aws_security_group.eks_efs_group.id]
}



# resource "helm_release" "aws_efs_csi_driver" {
#   name       = "aws-efs-csi-driver/aws-efs-csi-driver"

#   repository = "https://kubernetes-sigs.github.io/aws-efs-csi-driver/"
#   chart      = "aws-efs-csi-driver"
#   namespace  = "kube-system"
# }

# data "kustomization" "kustomization_info" {
#   provider = kustomization
#   path = "github.com/kubernetes-sigs/aws-efs-csi-driver/deploy/kubernetes/overlays/stable/?ref=release-1.0"
# }

# resource "kustomization_resource" "kustomization_resources" {
#   provider = kustomization

#   for_each = data.kustomization.kustomization_info.ids

#   manifest = data.kustomization.kustomization_info.manifests[each.value]
# }
