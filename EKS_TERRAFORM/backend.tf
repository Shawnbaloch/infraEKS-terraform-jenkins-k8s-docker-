terraform {
  backend "s3" {
    bucket = "terraform-shah-eks-backend" # Replace with your actual S3 bucket name
    key    = "path/to/terraform.tfstate"
    region = "us-east-1"
  }
}
