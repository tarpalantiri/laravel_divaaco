data "aws_key_pair" "webserver-ssh-key" {
  key_name = "my-KP"
}

data "aws_ami" "ubuntu-ami" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"]
  }
}
