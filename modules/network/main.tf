terraform {
  required_version = ">= 0.14.0"
  required_providers {
    openstack = {
      source  = "terraform-provider-openstack/openstack"
      version = "~> 1.35.0"
    }
  }
}

data "openstack_networking_network_v2" "ext-net" {
  name = "ext-net"
}

//создаем сеть с именем "terraform-web-net"
resource "openstack_networking_network_v2" "terraform-net" {
  name           = "vsfi-net"
  admin_state_up = "true"
}

//создаем подсеть
resource "openstack_networking_subnet_v2" "terraform-sbnt" {
  name       = "vsfi-subnet"
  network_id = openstack_networking_network_v2.terraform-net.id
  cidr       = var.cidr
  ip_version = 4
  dns_nameservers = [
    "8.8.8.8",
    "1.1.1.1"
  ]
}

//и роутер
resource "openstack_networking_router_v2" "terraform-rt" {
  name           = "vsfi-router"
  admin_state_up = "true"
  //id сети из которой добавляются внешние IP-адреса
  external_network_id = data.openstack_networking_network_v2.ext-net.id
}

resource "openstack_networking_router_interface_v2" "terraform" {
  router_id = openstack_networking_router_v2.terraform-rt.id
  subnet_id = openstack_networking_subnet_v2.terraform-sbnt.id
}