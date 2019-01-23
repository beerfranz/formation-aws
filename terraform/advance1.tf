

/*
resource "aws_vpc" "formation" {

}

resource "aws_subnet" "formation" {


}*/


resource "aws_security_group" "suiteCRM" {
  name        = "suiteCRM"
  description = "Allow elb only traffic"

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    security_groups = [ "${aws_security_group.elb-externe.id}" ]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["195.6.88.12/32"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "elb-externe" {
  name        = "allow_me2"
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

resource "aws_security_group" "bdd" {
  name        = "bdd"
  description = "Allow intern traffic only"
  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [ "${aws_security_group.suiteCRM.id}" ]
  }
}

/*

resource "aws_instance" "suiteCRM" {
  ami           = "ami-01595b905d09d236e"
  instance_type = "t2.micro"
  key_name      = "${aws_key_pair.deployer.key_name}"
  vpc_security_group_ids = [ "${aws_security_group.suiteCRM.id}" ]

  provisioner "file" {
    source      = "../sugarCRM/provisioner.sh"
    destination = "/tmp/provisioner.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/provisioner.sh",
      "/tmp/provisioner.sh args",
    ]
  }

  // grep Setting Bitnami application password to dans /var/log/syslog pour mdb "user"
}
*/
resource "aws_db_instance" "db01" {
  allocated_storage    = 10
  storage_type         = "gp2"
  engine               = "mysql"
  engine_version       = "5.7"
  instance_class       = "db.t2.micro"
  name                 = "db01"
  username             = "beerfranz"
  password             = "formation"
  parameter_group_name = "default.mysql5.7"
  vpc_security_group_ids = [ "${aws_security_group.bdd.id}" ]
  multi_az = 0
}

resource "aws_launch_configuration" "sugarCRM" {
  name          = "sugarCRM"
  // quand on change l'AMI, on doit détruire l'autoscaling group. entraine une perte du service pour plusieurs minutes.
  // il faudrait créer une nouvelle launch config et nouveau autoscaling group + blue/green avec un load balancer
  image_id      = "ami-0a08ffa85c1678311"
  instance_type = "t2.micro"
  user_data     = "RDS_HOSTNAME=${aws_db_instance.db01.address}; RDS_PORT=3306; RDS_DBMASTERUSER=${aws_db_instance.db01.username}; RDS_DBMASTERPASSWORD=${aws_db_instance.db01.password};"
  security_groups = [ "${aws_security_group.suiteCRM.id}" ]
  key_name      = "${aws_key_pair.deployer.key_name}"
}

resource "aws_autoscaling_group" "sugarCRM" {
  name                 = "sugarCRM"
  launch_configuration = "${aws_launch_configuration.sugarCRM.name}"
  min_size             = 1
  max_size             = 2
  health_check_type    = "ELB"
  availability_zones   = [ "eu-west-3a", "eu-west-3b" ]
  lifecycle {
    create_before_destroy = true
  }
}




# Create a new load balancer
resource "aws_elb" "sugarCRM" {
  name               = "sugarCRM"
  availability_zones = ["eu-west-3a", "eu-west-3b" ]
  security_groups    = [ "${aws_security_group.elb-externe.id}" ]

  listener {
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 2
    target              = "HTTP:80/index.php?action=Login&module=Users&Source=HealthCheck"
    interval            = 5
  }
}


resource "aws_autoscaling_attachment" "sugarCRM" {
  autoscaling_group_name = "${aws_autoscaling_group.sugarCRM.id}"
  elb                    = "${aws_elb.sugarCRM.id}"
}


/*
'db_user_name' => 'bn_suitecrm',
    'db_password' => 'd2ccb0004d',


*/ 

output "url" {
  value = "${aws_elb.sugarCRM.dns_name}"
}

output "password" {
  value = "tOsJ1sRuEPPD"
}

