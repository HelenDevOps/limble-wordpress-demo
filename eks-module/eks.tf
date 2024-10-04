
resource "aws_eks_cluster" "k8scluster" {
  name     = "project-limble-eks"
  version  = "1.28"
  role_arn = aws_iam_role.k8sclusterrole.arn

  vpc_config {
    subnet_ids = [
      "subnet-0ba104eb79df84f8f",
      "subnet-0bccee867344d44c2"
    ]
  }

  kubernetes_network_config {
    service_ipv4_cidr = "10.2.0.0/16"
  }

  # Ensure that IAM Role permissions are created before and deleted after EKS Cluster handling.
  # Otherwise, EKS will not be able to properly delete EKS managed EC2 infrastructure such as Security Groups.
  depends_on = [
    aws_iam_role_policy_attachment.k8sclusterrole-AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.k8sclusterrole-AmazonEKSVPCResourceController,
  ]

  tags = {
    Name = "project-limble-eks"
  }

}

data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["eks.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}
#AIM role for eks cluster
resource "aws_iam_role" "k8sclusterrole" {
  name               = "project-limble-eks-iam-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "aws_iam_role_policy_attachment" "k8sclusterrole-AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.k8sclusterrole.name
}

# Optionally, enable Security Groups for Pods
# Reference: https://docs.aws.amazon.com/eks/latest/userguide/security-groups-for-pods.html
resource "aws_iam_role_policy_attachment" "k8sclusterrole-AmazonEKSVPCResourceController" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
  role       = aws_iam_role.k8sclusterrole.name
}

# output "endpoint" {
#   value = aws_eks_cluster.example.endpoint
# }

# output "kubeconfig-certificate-authority-data" {
#   value = aws_eks_cluster.example.certificate_authority[0].data
# }

resource "aws_security_group" "allow_tls" {
  name        = "eks-cluster-sg-project-limble-eks"
  description = "Main SG for eks cluster"
  vpc_id      = "vpc-00dd5e2ef7bd963d4"

  ingress {
    description = "Allow all self"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    self        = true
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    "kubernetes.io/cluster/project-limble-eks" = "owned"
    "aws:eks:cluster-name"                     = "project-limble-eks"
    "Name"                                     = "eks-cluster-sg-project-limble-eks"
  }
}