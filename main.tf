resource "yandex_vpc_network" "network" {
  name = "devops-network"
}

resource "yandex_vpc_security_group" "bastion_sg" {
  name       = "bastion-sg"
  network_id = yandex_vpc_network.network.id

  ingress {
    protocol       = "TCP"
    description    = "SSH from administrator"
    port           = 22
    v4_cidr_blocks = [var.admin_cidr]
  }

  egress {
    protocol       = "ANY"
    description    = "Allow all outgoing traffic"
    from_port      = 0
    to_port        = 65535
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "yandex_vpc_security_group" "nat_sg" {
  name       = "nat-sg"
  network_id = yandex_vpc_network.network.id

  ingress {
    protocol       = "ANY"
    description    = "Traffic from private subnet"
    from_port      = 0
    to_port        = 65535
    v4_cidr_blocks = ["192.168.20.0/24"]
  }

  egress {
    protocol       = "ANY"
    description    = "Allow all outgoing traffic"
    from_port      = 0
    to_port        = 65535
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "yandex_vpc_security_group" "private_sg" {
  name       = "private-sg"
  network_id = yandex_vpc_network.network.id

  ingress {
    protocol       = "TCP"
    description    = "SSH from public subnet"
    port           = 22
    v4_cidr_blocks = ["192.168.10.0/24"]
  }

  egress {
    protocol       = "ANY"
    description    = "Allow all outgoing traffic"
    from_port      = 0
    to_port        = 65535
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "yandex_vpc_subnet" "public" {
  name           = "public"
  zone           = var.zone
  network_id     = yandex_vpc_network.network.id
  v4_cidr_blocks = ["192.168.10.0/24"]
}

resource "yandex_compute_instance" "nat" {
  name        = "nat-instance"
  platform_id = "standard-v3"
  zone        = var.zone

  resources {
    cores         = 2
    memory        = 2
    core_fraction = 20
  }

  boot_disk {
    initialize_params {
      image_id = var.nat_image_id
      size     = 20
      type     = "network-hdd"
    }
  }

  network_interface {
    subnet_id          = yandex_vpc_subnet.public.id
    ip_address         = "192.168.10.254"
    nat                = true
    security_group_ids = [yandex_vpc_security_group.nat_sg.id]
  }

  metadata = {
    ssh-keys = "ubuntu:${file(pathexpand(var.ssh_public_key_path))}"
  }
}

resource "yandex_compute_instance" "bastion" {
  name        = "bastion"
  platform_id = "standard-v3"
  zone        = var.zone

  resources {
    cores         = 2
    memory        = 2
    core_fraction = 20
  }

  boot_disk {
    initialize_params {
      image_id = var.ubuntu_image_id
      size     = 10
      type     = "network-hdd"
    }
  }

  network_interface {
    subnet_id          = yandex_vpc_subnet.public.id
    nat                = true
    security_group_ids = [yandex_vpc_security_group.bastion_sg.id]
  }

  metadata = {
    ssh-keys = "ubuntu:${file(pathexpand(var.ssh_public_key_path))}"
  }
}

resource "yandex_vpc_route_table" "private_route" {
  name       = "private-route"
  network_id = yandex_vpc_network.network.id

  static_route {
    destination_prefix = "0.0.0.0/0"
    next_hop_address   = yandex_compute_instance.nat.network_interface[0].ip_address
  }
}

resource "yandex_vpc_subnet" "private" {
  name           = "private"
  zone           = var.zone
  network_id     = yandex_vpc_network.network.id
  v4_cidr_blocks = ["192.168.20.0/24"]

  route_table_id = yandex_vpc_route_table.private_route.id
}

resource "yandex_compute_instance" "private" {
  name        = "private-vm"
  platform_id = "standard-v3"
  zone        = var.zone

  resources {
    cores         = 2
    memory        = 2
    core_fraction = 20
  }

  boot_disk {
    initialize_params {
      image_id = var.ubuntu_image_id
      size     = 10
      type     = "network-hdd"
    }
  }

  network_interface {
    subnet_id          = yandex_vpc_subnet.private.id
    nat                = false
    security_group_ids = [yandex_vpc_security_group.private_sg.id]
  }

  metadata = {
    ssh-keys = "ubuntu:${file(pathexpand(var.ssh_public_key_path))}"
  }
}
