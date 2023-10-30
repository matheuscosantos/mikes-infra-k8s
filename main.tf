provider "aws" {
  region = var.region
}

## - cloudwatch log

resource "aws_cloudwatch_log_group" "log" {
  name              = "/aws/eks/${var.cluster_name}"
  retention_in_days = 7
}

## - fargate profile

resource "aws_iam_role" "eks_fargate-profile-role" {
  name = "eks-fargate-profile-role"
  assume_role_policy = file("policy/fargate_profile_assume_role_policy.json")
}

resource "aws_iam_role_policy_attachment" "eks_fargate-profile-policy-attachment" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSFargatePodExecutionRolePolicy"
  role       = aws_iam_role.eks_fargate-profile-role.name
}

resource "aws_eks_fargate_profile" "eks_fargate_profile" {
  cluster_name           = aws_eks_cluster.cluster.name
  fargate_profile_name   = "fargate-profile"
  pod_execution_role_arn = aws_iam_role.eks_fargate-profile-role.arn
  subnet_ids             = var.subnet_ids

  selector {
    namespace = var.cluster_name
  }
}

#-- eks

resource "aws_iam_role" "role" {
  name               = "${var.cluster_name}-role"
  assume_role_policy = file("policy/eks_assume_role_policy.json")
}

resource "aws_iam_role_policy_attachment" "policy-attachment" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.role.name
}

resource "aws_eks_cluster" "cluster" {
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

