resource "aws_instance" "final_ec2" {
  ami           = var.ami_id
  instance_type = var.instance_type

  tags = {
    Name        = var.name
    Environment = var.environment
  }
}