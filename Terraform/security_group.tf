
resource "yandex_vpc_security_group" "sec-group" {
  name        = "sec-group"
  network_id  = "${yandex_vpc_network.netology-network.id}"
}


resource "yandex_vpc_security_group_rule" "rule1" {
  security_group_binding = yandex_vpc_security_group.sec-group.id
  direction              = "ingress"
  description            = "SSH"
  v4_cidr_blocks         = ["0.0.0.0/0"]
  port                   = 22
  protocol               = "TCP"
}

resource "yandex_vpc_security_group_rule" "rule2" {
  security_group_binding = yandex_vpc_security_group.sec-group.id
  direction              = "ingress"
  description            = "web"
  v4_cidr_blocks         = ["0.0.0.0/0"]
  port                   = 80
  protocol               = "ANY"
}

resource "yandex_vpc_security_group_rule" "rule3" {
  security_group_binding = yandex_vpc_security_group.sec-group.id
  direction              = "ingress"
  description            = "grafana"
  v4_cidr_blocks         = ["0.0.0.0/0"]
  port                   = 3000
  protocol               = "TCP"
}

resource "yandex_vpc_security_group_rule" "rule4" {
  security_group_binding = yandex_vpc_security_group.sec-group.id
  direction              = "ingress"
  description            = "kibana"
  v4_cidr_blocks         = ["0.0.0.0/0"]
  port                   = 5601
  protocol               = "TCP"
}

resource "yandex_vpc_security_group_rule" "rule5" {
  security_group_binding = yandex_vpc_security_group.sec-group.id
  direction              = "ingress"
  description            = "Allow any local ingress"
  v4_cidr_blocks         = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  protocol               = "ANY"
}

resource "yandex_vpc_security_group_rule" "rule6" {
  security_group_binding = yandex_vpc_security_group.sec-group.id
  direction              = "egress"
  description            = "Allow any local egress"
  v4_cidr_blocks         = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  protocol               = "ANY"
}

resource "yandex_vpc_security_group_rule" "rule7" {
  security_group_binding = yandex_vpc_security_group.sec-group.id
  direction              = "egress"
  description            = "Allow egress traffic"
  v4_cidr_blocks         = ["0.0.0.0/0"]
  protocol               = "ANY"
}


