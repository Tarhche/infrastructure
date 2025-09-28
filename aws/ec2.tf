import {
  to = aws_instance.backend
  id = "i-0ed2ea2eccc9e0815"
}

resource "aws_instance" "backend" {
  ami               = "ami-07eef52105e8a2059" # Canonical, Ubuntu, 24.04, amd64 noble image
  instance_type     = "t3.medium"
  key_name          = "backend"
  availability_zone = "eu-central-1b"

  subnet_id = data.aws_subnets.default.ids[0]
  vpc_security_group_ids = [aws_security_group.backend.id]

  user_data = <<-EOT
    #!/bin/bash

    # volumes - ec2 modifies the device name xvdf to nvme1n1
    sudo mkfs.ext4 /dev/nvme1n1
    sudo mkdir /volume_01
    sudo mount /dev/nvme1n1 /volume_01
    sudo echo "/dev/nvme1n1 /volume_01 ext4 defaults,nofail 0 0" | sudo tee -a /etc/fstab

    # tools
    sudo apt install -y wget python3 ca-certificates curl htop jq vim make

    # Add Docker's official GPG key:
    sudo install -m 0755 -d /etc/apt/keyrings
    sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
    sudo chmod a+r /etc/apt/keyrings/docker.asc

    # Add the repository to Apt sources:
    echo \
      "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
      $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
      sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    sudo apt-get update

    # install docker and sysbox
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    wget -O sysbox.deb https://downloads.nestybox.com/sysbox/releases/v0.6.6/sysbox-ce_0.6.6-0.linux_amd64.deb
    sudo apt install -y ./sysbox.deb
    rm ./sysbox.deb

    # setup
    sudo systemctl enable docker.service
    sudo systemctl start docker.service
    sudo usermod -a -G docker ubuntu
    id ubuntu
    newgrp docker
    docker swarm init --advertise-addr 192.168.99.100

    # enable firewall
    sudo ufw enable

    # open ssh, http related ports
    sudo ufw allow 22/tcp
    sudo ufw allow 80/tcp
  EOT

  root_block_device {
    delete_on_termination = true
    encrypted             = false
    volume_size           = 100
    volume_type           = "gp3"

    tags = {
      project_name = var.project_name
    }
  }

  security_groups = [
    aws_security_group.backend.name
  ]

  tags = {
    project_name = var.project_name
  }
}