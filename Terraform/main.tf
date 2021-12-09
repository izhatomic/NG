terraform {
  required_providers {
    yandex = {
      source  = "yandex-cloud/yandex"
      version = "0.67.0"
    }
  }
}

provider "yandex" {
  token     = "AQAAAAABZgLiAATuwZCa5yregkOCjtEhFlIVi1U"
  cloud_id  = "b1gbfmcnli0qbnh558o8"
  folder_id = "b1gcb5c8lbq0p898u2lg"
  zone      = "ru-central1-c"
}

resource "yandex_compute_instance" "default" {
  name        = "test"
  platform_id = "standard-v1"
  zone        = "ru-central1-c"

  resources {
    cores         = 2
    memory        = 2
    core_fraction = 20
  }

  boot_disk {
    initialize_params {
      image_id = "fd8ot0k0vde438jv0t8j"
    }
  }

  network_interface {
    nat       = "true"
    subnet_id = "b0c3eh2qaofainqtrg4o"
  }

  metadata = {
    #    foo = "bar"
    ssh-keys  = "izhatomic:${file("~/.ssh/id_rsa.pub")}"
#    user-data = "${file("/home/izhatomic/GIT/NG/users.txt")}"
  }
}
