terraform {
  required_providers {
    yandex = {
      source  = "yandex-cloud/yandex"
      version = "0.67.0"
    }
  }
}

provider "yandex" {
  token     = var.oauth_token
  cloud_id  = var.cloud_id
  folder_id = var.folder_id
  zone      = "ru-central1-c"
}

resource "yandex_vpc_network" "network_1" {
  name = "network_1"
}

resource "yandex_vpc_subnet" "subnet_1" {
  name           = "subnet_1"
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.network_1.id
  v4_cidr_blocks = ["192.168.10.0/24"]
}

resource "yandex_compute_instance" "vm1" {
  name = "terraform1"

  resources {
    cores  = 2
    memory = 2
    core_fraction = 20
  }

  boot_disk {
    initialize_params {
      image_id = var.image_id
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.subnet_1.id
#    subnet_id = "e9bqstrd9l7dpc6g3l3e"
#    subnet_id = "b0c3eh2qaofainqtrg4o"
    nat       = true
  }

  metadata = {
    ssh-keys = "${var.username}:${file("~/.ssh/id_rsa.pub")}"
    user-data = "${file("users.yml")}"
  }
}


output "yandex_vpc_subnet_subnet_1_id" {
  value = yandex_vpc_subnet.subnet_1.id
}

output "internal_ip_address_vm_1" {
  value = yandex_compute_instance.vm1.network_interface.0.ip_address
}

output "external_ip_address_vm_1" {
  value = yandex_compute_instance.vm1.network_interface.0.nat_ip_address
}
