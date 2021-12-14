resource "yandex_compute_instance" "web2" {
  name        = "web2"
  hostname    = "web2"
  platform_id = "standard-v1"
  zone        = "ru-central1-b"

  labels = {
    group = "webservers"
    vds   = "web2"
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
    subnet_id = yandex_vpc_subnet.subnet-b.id
    nat_ip_address = true
  }

  metadata = {
    ssh-keys  = "${var.username}:${file(var.public_key_path)}"
    user-data = "${file("users.yml")}"
  }
}
