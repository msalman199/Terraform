# Create security group for EC2 instance
resource "aws_security_group" "terraform_sg" {
  name_prefix = "terraform-lab-sg-"
  description = "Security group for Terraform lab EC2 instance"
  vpc_id      = data.aws_vpc.default.id

  # Allow SSH access
  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow HTTP access
  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "terraform-lab-sg"
    Environment = var.environment
    CreatedBy   = "Terraform"
  }
}
