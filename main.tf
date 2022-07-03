# Define required providers
terraform {
  required_version = ">= 0.14.0"
  required_providers {
    openstack = {
      source  = "terraform-provider-openstack/openstack"
      version = "~> 1.35.0"
    }
  }
}


//создаем ключевую пару
resource "openstack_compute_keypair_v2" "terraform_keypair" {
  name       = "vsfi-keypair"
  public_key = file("demo_rsa.pub")
}

module "network" {
  source = "./modules/network"
  cidr   = "10.0.1.0/24"
}

module "firewall" {
  source = "./modules/firewall"
  name   = "allow-ssh-and-http"
}

module "main_instance" {
  source          = "./modules/instance"
  instance_name   = "vsfi-prod-0"
  flavor_name     = "Standard-6-6"
  security_groups = [module.firewall.name]
  key_pair        = openstack_compute_keypair_v2.terraform_keypair.name
  network_uuid    = module.network.network_uuid
}

module "dev_instance" {
  for_each      = toset(["vsfi-dev-0", "vsfi-dev-1"])
  source        = "./modules/instance"
  instance_name = each.key
  key_pair      = openstack_compute_keypair_v2.terraform_keypair.name
  network_uuid  = module.network.network_uuid
}

// выделяем внешний IP-адрес из пула "ext-net"
resource "openstack_compute_floatingip_v2" "vm_floating_ip" {
  pool = module.network.ext_net_name
}


resource "openstack_compute_floatingip_associate_v2" "this" {
  floating_ip = openstack_compute_floatingip_v2.vm_floating_ip.address
  instance_id = module.main_instance.id


  //исполняем inline-команды сразу после назначения белого IP
  provisioner "remote-exec" {

    //для этого подключаемся к инстансу по ssh
    connection {
      host        = openstack_compute_floatingip_v2.vm_floating_ip.address
      user        = var.user
      private_key = file("demo_rsa")
    }

    inline = [
      "echo ${openstack_compute_floatingip_v2.vm_floating_ip.address}",
      "cat /etc/hosts"
    ]
  }

  //В качестве альтернативы, можно скопировать локальный скрипт на виртуальную машину
  provisioner "file" {

    connection {
      host        = openstack_compute_floatingip_v2.vm_floating_ip.address
      user        = var.user
      private_key = file("demo_rsa")
    }

    source      = "script.sh"
    destination = "/tmp/script.sh"
  }

  //и выполнить его
  provisioner "remote-exec" {

    connection {
      host        = openstack_compute_floatingip_v2.vm_floating_ip.address
      user        = var.user
      private_key = file("demo_rsa")
    }

    //перед выполнением меняем атрибуты файла на исполняемые
    inline = [
      "chmod +x /tmp/script.sh",
      "/tmp/script.sh args",
    ]
  }
}


//На выходе возвращаем публичный IP-адрес виртуальной машины VM
output "web-instances" {
  value = join(",", openstack_compute_floatingip_associate_v2.this.*.floating_ip)
}
