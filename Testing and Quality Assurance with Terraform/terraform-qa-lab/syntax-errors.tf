# File with intentional syntax errors

resource "aws_instance" "broken_instance" {
  ami           = "ami-0c02fb55956c7d316"
  instance_type = "t2.micro"
  
  # Missing closing quote - syntax error
  tags = {
    Name = "broken-instance
  }
  
  # Invalid attribute name
  invalid_attribute = "this will cause an error"
}

# Missing resource type
resource "broken_resource" {
  name = "test"
}

# Invalid interpolation syntax
output "broken_output" {
  value = ${aws_instance.broken_instance.id}  # Old syntax
}
