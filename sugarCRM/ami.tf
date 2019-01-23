provider "aws" {
  region = "eu-west-3"
}


resource "aws_key_pair" "builder-sugarCRM" {
  key_name   = "builder-sugarCRM"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDJmbIX66//VAENFXMB2IRsfX8e4EY+fbVpyQHmKJQrzkm7J7KHp5A6lq0nmHvF3vlprS2Dj5SmsMeEL8wvm+y3vrKbYghAjboh22bQMCISgHJKRKqOZJX30km5gc7zDc8EIScyUMIH5hQfL0PXaIg3QBXjkX16iTyaBR15rgPDKu4erNUD6sYsg3u57LoYvcg1MOAf+/3wO0v9/9bT6l0MNPmpdHjj4w4QZO+1AMxcw9FjF3ZM8pKjSUyQgQ1rxBiIdEuiHewHrFaaYgGG1e7pdJb76RQ32CVYn29eT8P9V7CfNomM9ZadPDPBs5iUYXOWVO5O03z0iGYRAZv92mSJ root@localhost.localdomain"
}



resource "aws_security_group" "builder-sugarcrm" {
  name        = "builder-sugarcrm"
  description = "Allow my inbound traffic"

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["195.6.88.12/32"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }
}



resource "aws_instance" "sugarCRM-builder" {
  ami           = "ami-01595b905d09d236e"
  instance_type = "t2.micro"
  key_name      = "${aws_key_pair.builder-sugarCRM.key_name}"
  vpc_security_group_ids = [ "${aws_security_group.builder-sugarcrm.id}" ]


  provisioner "file" {
    source      = "provisioner.sh"
    destination = "/tmp/provisioner.sh"

    connection {
      type     = "ssh"
      user     = "ubuntu"
    }
  }

  provisioner "file" {
    source      = "patchSuiteCRMDBConfiguration.sh"
    destination = "/tmp/patchSuiteCRMDBConfiguration.sh"

    connection {
      type     = "ssh"
      user     = "ubuntu"
    }
  }

  provisioner "remote-exec" {

    connection {
      type     = "ssh"
      user     = "ubuntu"
    }
    
    inline = [
      "chmod +x /tmp/provisioner.sh",
      "chmod +x /tmp/patchSuiteCRMDBConfiguration.sh",
      "sudo mv /tmp/patchSuiteCRMDBConfiguration.sh /etc/init.d",
      "/tmp/provisioner.sh",
    ]
  }

  // grep Setting Bitnami application password to dans /var/log/syslog pour mdb "user"
}

resource "aws_ami_from_instance" "sugarCRM" {
  name                = "sugarCRM"
  source_instance_id  = "${aws_instance.sugarCRM-builder.id}"
}
