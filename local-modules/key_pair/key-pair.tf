resource "tls_private_key" "key" {
  algorithm = "RSA"
}

resource "local_sensitive_file" "private_key" {
  filename        = "${path.module}/myapp-3108.pem"
  content         = tls_private_key.key.private_key_pem
  file_permission = "0400"
}


resource "aws_key_pair" "key_pair" {
  key_name   = "myapp-3108"
  public_key = tls_private_key.key.public_key_openssh
}
