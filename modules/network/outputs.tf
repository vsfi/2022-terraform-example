output "network_uuid" {
  value = openstack_networking_network_v2.terraform-net.id
}

output "ext_net_name" {
  value = data.openstack_networking_network_v2.ext-net.id
}

