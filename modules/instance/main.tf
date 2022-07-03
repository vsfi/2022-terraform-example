terraform {
  required_version = ">= 0.14.0"
  required_providers {
    openstack = {
      source  = "terraform-provider-openstack/openstack"
      version = "~> 1.35.0"
    }
  }
}


resource "openstack_compute_instance_v2" "instance" {
  name        = var.instance_name
  image_name  = var.image_name
  image_id    = var.image_id
  flavor_name = var.flavor_name

  key_pair        = var.key_pair
  security_groups = var.security_groups

  network {
    uuid = var.network_uuid
  }

  //используем внешний cloud config
  user_data = file("modules/instance/cloud-init.yml")


  block_device {
    uuid                  = var.image_id
    source_type           = "image"
    volume_size           = 5
    boot_index            = 0
    destination_type      = "volume"
    delete_on_termination = true
  }
}
