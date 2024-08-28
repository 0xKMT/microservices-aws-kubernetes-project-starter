resource "aws_iam_role" "demo" {
  name = "eks-cluster-demo-udacity"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "demo-AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.demo.name
}

resource "aws_iam_role" "nodes" {
  name = "eks-node-group-nodes"

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

resource "aws_iam_role_policy_attachment" "nodes-AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.nodes.name
}

resource "aws_iam_role_policy_attachment" "nodes-AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.nodes.name
}

resource "aws_iam_role_policy_attachment" "nodes-AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.nodes.name
}

# Attach AmazonSSMManagedInstanceCore
resource "aws_iam_role_policy_attachment" "nodes-SSMManagedInstanceCore" {
  role       = aws_iam_role.nodes.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# Attach AmazonSSMFullAccess
resource "aws_iam_role_policy_attachment" "nodes-SSMFullAccess" {
  role       = aws_iam_role.nodes.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMFullAccess"
}

# This policy will soon be deprecated. Please use AmazonSSMManagedInstanceCore policy to enable AWS Systems Manager service core functionality on EC2 instances. 
# For more information see https://docs.aws.amazon.com/systems-manager/latest/userguide/setup-instance-profile.html
# resource "aws_iam_role_policy_attachment" "nodes-EC2RoleForSSM" {
#   role       = aws_iam_role.nodes.name
#   policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforSSM"
# }

# Attach AmazonSSMManagedEC2InstanceDefaultPolicy
resource "aws_iam_role_policy_attachment" "nodes-SessionManager" {
  role       = aws_iam_role.nodes.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedEC2InstanceDefaultPolicy"
}

resource "aws_eks_cluster" "udacity_cluster" {
  name     = var.cluster_config.cluster_name
  role_arn = aws_iam_role.demo.arn
  version  = var.cluster_config.cluster_version
  vpc_config {
    subnet_ids = [for s in data.aws_subnet.default : s.id]
    endpoint_private_access = false
    endpoint_public_access  = true
  }

  depends_on = [aws_iam_role_policy_attachment.demo-AmazonEKSClusterPolicy]
  tags = {
    Name = "${local.project}-${var.env}-eks"
  }
}


resource "aws_eks_node_group" "node-group-udacity" {
  cluster_name    = aws_eks_cluster.udacity_cluster.name
  node_group_name = "udacity-nodes-grp"
  node_role_arn   = aws_iam_role.nodes.arn
  version         = var.cluster_config.cluster_version
  subnet_ids      = [for s in data.aws_subnet.default : s.id]

  capacity_type  = "SPOT"
  instance_types = ["t2.large"]

  scaling_config {
    desired_size = 2
    max_size     = 3
    min_size     = 1
  }

  update_config {
    max_unavailable = 1
  }

  labels = {
    role = "general"
  }
  depends_on = [
    aws_iam_role_policy_attachment.nodes-AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.nodes-AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.nodes-AmazonEC2ContainerRegistryReadOnly,
  ]
  tags = {
    Name              = "${local.project}-${var.env}-eks"
    "node_group_name" = "udacity-nodes-grp"
  }
}

