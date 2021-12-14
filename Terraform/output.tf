output "web1_extIP" {
  value = yandex_compute_instance.web1.network_interface.0.nat_ip_address
}

output "web2_extIP" {
  value = yandex_compute_instance.web2.network_interface.0.nat_ip_address
}

output "bastion_extIP" {
  value = yandex_compute_instance.bastion.network_interface.0.nat_ip_address
}

output "grafana_extIP" {
  value = yandex_compute_instance.grafana.network_interface.0.nat_ip_address
}

output "kibana_extIP" {
  value = yandex_compute_instance.kibana.network_interface.0.nat_ip_address
}
