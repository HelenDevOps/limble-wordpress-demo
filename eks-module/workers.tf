resource "aws_eks_node_group" "k8scluster-nodegroup" {
  cluster_name    = aws_eks_cluster.k8scluster.name
  node_group_name = "project-limble-eks-nodegroup"
  node_role_arn   = aws_iam_role.k8scluster-nodegroup-role.arn
  subnet_ids = [
    "subnet-0ba104eb79df84f8f",
    "subnet-0bccee867344d44c2"
  ]

  scaling_config {
    desired_size = 1
    max_size     = 2
    min_size     = 1
  }

  update_config {
    max_unavailable = 1
  }
  capacity_type  = "SPOT"
  instance_types = ["t3.small"]


  # Ensure that IAM Role permissions are created before and deleted after EKS Node Group handling.
  # Otherwise, EKS will not be able to properly delete EC2 Instances and Elastic Network Interfaces.
  depends_on = [
    aws_iam_role_policy_attachment.k8scluster-nodegroup-AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.k8scluster-nodegroup-AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.k8scluster-nodegroup-AmazonEC2ContainerRegistryReadOnly,
  ]
}

resource "aws_iam_role" "k8scluster-nodegroup-role" {
  name = "project-limble-eks-iam-nodegroup-role"

  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
    Version = "2012-10-17"
  })
}

resource "aws_iam_role_policy_attachment" "k8scluster-nodegroup-AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.k8scluster-nodegroup-role.name
}

resource "aws_iam_role_policy_attachment" "k8scluster-nodegroup-AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.k8scluster-nodegroup-role.name
}

resource "aws_iam_role_policy_attachment" "k8scluster-nodegroup-AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.k8scluster-nodegroup-role.name
}