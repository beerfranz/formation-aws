provider "aws" {
	region = "eu-west-3"
}


resource "aws_key_pair" "deployer" {
  key_name   = "deployer-key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDJmbIX66//VAENFXMB2IRsfX8e4EY+fbVpyQHmKJQrzkm7J7KHp5A6lq0nmHvF3vlprS2Dj5SmsMeEL8wvm+y3vrKbYghAjboh22bQMCISgHJKRKqOZJX30km5gc7zDc8EIScyUMIH5hQfL0PXaIg3QBXjkX16iTyaBR15rgPDKu4erNUD6sYsg3u57LoYvcg1MOAf+/3wO0v9/9bT6l0MNPmpdHjj4w4QZO+1AMxcw9FjF3ZM8pKjSUyQgQ1rxBiIdEuiHewHrFaaYgGG1e7pdJb76RQ32CVYn29eT8P9V7CfNomM9ZadPDPBs5iUYXOWVO5O03z0iGYRAZv92mSJ root@localhost.localdomain"
}
