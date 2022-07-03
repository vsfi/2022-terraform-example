variable "instance_name" {
  //название создаваемого инстанса
}
variable "image_name" {
  default = "Ubuntu-20.04.1-202008"
}

variable "image_id" {
  default = "d853edd0-27b3-4385-a380-248ac8e40956"
}

variable "flavor_name" {
  default = "Basic-1-1-10"
}



variable "security_groups" {
  default = []
}

variable "network_uuid" {

}

variable "key_pair" {

}
