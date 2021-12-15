variable "image_id" {
    type = string
    default = "fd8ot0k0vde438jv0t8j"
}
variable "image_id_bastion" {
    type = string
    default = "fd8drj7lsj7btotd7et5"
}
variable "username" {
    type = string
    default = "ubuntu"
}
variable "password" {
    type = string
    default = "qwerty"
}
variable "public_key_path" {
    type = string
    default = "~/.ssh/yandex-cloud.pub"
}
