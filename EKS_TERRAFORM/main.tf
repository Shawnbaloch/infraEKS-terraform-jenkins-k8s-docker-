
resource "aws_vpc" "main" {
 cidr_block = "10.0.0.0/16"

 tags = {
    Name = "terraform-eks-example"
 }
}

resource "aws_subnet" "main" {
 count = 2

 availability_zone       = data.aws_availability_zones.available.names[count.index]
 cidr_block              = "10.0.${count.index}.0/24"
 map_public_ip_on_launch = true
 vpc_id                 = aws_vpc.main.id

 tags = {
    Name = "terraform-eks-example"
 }
}

data "aws_eks_cluster" "cluster" {
 name = aws_eks_cluster.this.id
}

data "aws_eks_cluster_auth" "cluster" {
 name = aws_eks_cluster.this.id
}

provider "kubernetes" {
 host                   = data.aws_eks_cluster.cluster.endpoint
 cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
 token                 = data.aws_eks_cluster_auth.cluster.token
 load_config_file       = false
}

resource "aws_eks_cluster" "this" {
 name     = "terraform-eks-example"
 role_arn = aws_iam_role.eks_cluster.arn

 vpc_config {
    subnet_ids = aws_subnet.main.*.id
 }

 depends_on = [
    "aws_iam_role_policy_attachment.eks_cluster_AmazonEKSClusterPolicy",
    "aws_iam_role_policy_attachment.eks_cluster_AmazonEKSServicePolicy",
 ]
}

resource "aws_iam_role" "eks_cluster" {
 name = "terraform-eks-example"

 assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "eks.amazonaws.com"
        }
      }
    ]
 })
}

resource "aws_iam_role_policy_attachment" "eks_cluster_AmazonEKSClusterPolicy" {
 policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
 role       = aws_iam_role.eks_cluster.name
}

resource "aws_iam_role_policy_attachment" "eks_cluster_AmazonEKSServicePolicy" {
 policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
 role       = aws_iam_role.eks_cluster.name
}

output "endpoint" {
 value = data.aws_eks_cluster.cluster.endpoint
}

output "kubeconfig-certificate-authority-data" {
 value = data.aws_eks_cluster.cluster.certificate_authority.0.data
}

output "cluster_security_group_id" {
 value = data.aws_eks_cluster.cluster.vpc_config.0.cluster_security_group_id
}

output "cluster_id" {
 value = data.aws_eks_cluster.cluster.id
}
