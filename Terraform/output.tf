output "bastion_extIP" {
  value = yandex_compute_instance.bastion.network_interface.0.nat_ip_address
}

output "grafana_extIP" {
  value = yandex_compute_instance.grafana.network_interface.0.nat_ip_address
}

output "kibana_extIP" {
  value = yandex_compute_instance.kibana.network_interface.0.nat_ip_address
}

output "ALB_balancer_IP" {
  value = yandex_alb_load_balancer.alb.listener.0.endpoint.0.address.0.external_ipv4_address.0.address
}

