data "aws_vpc" "vpc" {
  id = module.vpc.vpc_id
}

resource "aws_security_group" "rds_sg" {
  name   = "rds-sg"
  vpc_id = module.vpc.vpc_id
}

resource "aws_security_group" "rds_pod_sg" {
  name   = "rds-pod-sg"
  vpc_id = module.vpc.vpc_id
}

resource "aws_security_group_rule" "pod_to_workers" {
  for_each                 = toset(["udp", "tcp"])
  type                     = "ingress"
  from_port                = 53
  to_port                  = 53
  protocol                 = each.key
  source_security_group_id = aws_security_group.rds_pod_sg.id
  security_group_id        = module.eks.worker_security_group_id 
}

resource "aws_security_group_rule" "pod_to_rds" {
  type                     = "ingress"
  from_port                = 5432
  to_port                  = 5432
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.rds_pod_sg.id
  security_group_id        = aws_security_group.rds_sg.id
}

module "db" {
  source                  = "terraform-aws-modules/rds/aws"
  version                 = "~> 2.0"
  name                    = "engineerx"
  instance_class          = "db.t3.micro"
  engine                  = "postgres"
  subnet_ids              = vpc.public_subnets
  vpc_security_group_ids  = [aws_security_group.rds_sg.id]
  username                = "engineerx"
  password                = var.postgres_password 
  publicly_accessible     = true
  allocated_storage       = 10
  port                    = "5432"
  backup_retention_period = 0

}

resource "aws_iam_role_policy_attachment" "cni_policy_attachment" {
  role       = module.eks.worker_iam_role_name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
}
