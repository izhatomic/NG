resource "yandex_compute_instance" "web1" {
  name        = "web1"
  hostname    = "web1"
  platform_id = "standard-v1"
  zone        = "ru-central1-a"

  labels = {
    group = "webservers"
    vds   = "web1"
  }

  resources {
    cores  = 2
    memory = 1
    core_fraction = 5
  }

  boot_disk {
    initialize_params {
      image_id = var.image_id
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.subnet-a.id
    nat_ip_address = true
  }

  metadata = {
    ssh-keys  = "${var.username}:${file(var.public_key_path)}"
    user-data = "${file("users.yml")}"
  }
}
