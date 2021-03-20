module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  cluster_name    = var.cluster_name
  cluster_version = "1.18"
  subnets         = module.vpc.public_subnets
  vpc_id          = module.vpc.vpc_id
  enable_irsa     = true

  workers_group_defaults = {
      root_volume_type = "gp2"
  }

  worker_groups = [
    {
      name                 = "worker-group-1"
      instance_type        = "t3.xlarge"
      asg_max_size         = 10
      tags = [
        {
          "key"                 = "k8s.io/cluster-autoscaler/enabled"
          "propagate_at_launch" = "false"
          "value"               = "true"
        },
        {
          "key"                 = "k8s.io/cluster-autoscaler/${var.cluster_name}"
          "propagate_at_launch" = "false"
          "value"               = "true"
        }
      ]
    },
    {
      name                 = "worker-group-2"
      instance_type        = "t3.large"
      asg_max_size         = 15
      tags = [
        {
          "key"                 = "k8s.io/cluster-autoscaler/enabled"
          "propagate_at_launch" = "false"
          "value"               = "true"
        },
        {
          "key"                 = "k8s.io/cluster-autoscaler/${var.cluster_name}"
          "propagate_at_launch" = "false"
          "value"               = "true"
        }
      ]
    },
    {
      name                 = "worker-group-3"
      instance_type        = "t3.medium"
      asg_max_size         = 20   
      tags = [
        {
          "key"                 = "k8s.io/cluster-autoscaler/enabled"
          "propagate_at_launch" = "false"
          "value"               = "true"
        },
        {
          "key"                 = "k8s.io/cluster-autoscaler/${var.cluster_name}"
          "propagate_at_launch" = "false"
          "value"               = "true"
        }
      ]
    },
    {
      name                 = "worker-group-4"
      instance_type        = "m5.large"
      asg_max_size         = 15   
      tags = [
        {
          "key"                 = "k8s.io/cluster-autoscaler/enabled"
          "propagate_at_launch" = "false"
          "value"               = "true"
        },
        {
          "key"                 = "k8s.io/cluster-autoscaler/${var.cluster_name}"
          "propagate_at_launch" = "false"
          "value"               = "true"
        }
      ]
    }
  ]

}