resource "yandex_compute_instance" "elastic" {
  name        = "elastic"
  hostname    = "elastic"
  platform_id = "standard-v1"
  zone        = "ru-central1-b"

  labels = {
    group = "logging"
    vds   = "elastic"
  }

  resources {
    cores  = 2
    memory = 8
    core_fraction = 100
  }

  boot_disk {
    initialize_params {
      image_id = var.image_id
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.subnet-b.id
    nat = true
  }

  metadata = {
    ssh-keys  = "${var.username}:${file(var.public_key_path)}"
  }
}
