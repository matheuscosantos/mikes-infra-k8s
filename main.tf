provider "aws" {
  region = var.region
}

terraform {
  backend "s3" {
    bucket         = "mikes-terraform-state"
    key            = "mikes-cluster.tfstate"
    region         = "us-east-2"
    encrypt        = true
  }
}

resource "aws_iam_role" "role" {
  name               = "${var.cluster_name}-role"
  assume_role_policy = file("policy/eks_assume_role_policy.json")
}

resource "aws_iam_role_policy_attachment" "policy-attachment" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.role.name
}

resource "aws_cloudwatch_log_group" "log" {
  name              = "/aws/eks/${var.cluster_name}"
  retention_in_days = 7
}

resource "aws_eks_cluster" "mikes-cluster" {
  name      = var.cluster_name
  role_arn  = aws_iam_role.role.arn

  vpc_config {
    subnet_ids = var.subnet_ids
  }

  enabled_cluster_log_types = ["api", "audit"]

  depends_on = [
    aws_iam_role_policy_attachment.policy-attachment,
    aws_cloudwatch_log_group.log
  ]
}
