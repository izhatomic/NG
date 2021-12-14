resource "yandex_compute_instance" "kibana" {
  name        = "kibana"
  hostname    = "kibana"
  platform_id = "standard-v1"
  zone        = "ru-central1-c"

  labels = {
    group = "logging"
    vds   = "kibana"
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
    subnet_id = yandex_vpc_subnet.subnet-c.id
    nat       = true
  }

  metadata = {
    ssh-keys  = "${var.username}:${file(var.public_key_path)}"
  }
}
