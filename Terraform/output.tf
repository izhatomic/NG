output "web1_extIP" {
  value = yandex_compute_instance.web1.network_interface.0.nat_ip_address
}

output "web2_extIP" {
  value = yandex_compute_instance.web2.network_interface.0.nat_ip_address
}
