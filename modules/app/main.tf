resource "aws_instance" "ami" {
  ami           = data.aws_ami.ami.id
  instance_type = var.instance_type
  vpc_security_group_ids = [data.aws_security_group.selected.id]
  tags = {
    name = var.component
  }
}
resource "null_resource" "ansible" {
  provisioner "remote-exec" {

    connection {
      type     = "ssh"
      user     = var.ssh_user
      password = var.ssh_pass
      host     = aws_instance.instance.public_ip
    }

    inline = [
      "sudo pip3.11 install ansible",
      "ansible-pull -i localhost, -U https://github.com/raju-b70/expense-ansible expense.yml -e env=${var.env} -e role_name=${var.component}"
    ]
  }
}

  resource "aws_route53_record" "selected" {
    name    = "$(var.component)-$(var.env)"
    type    = "a"
    zone_id = var.zone_id
    records = [aws_instance.instance.private_ip]
    ttl     = 30
  }
