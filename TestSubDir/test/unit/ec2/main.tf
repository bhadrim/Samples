
variable "password" {
  default = "foo"
}

module "ec2_create"{
  source="../../../module/ec2"  
  password="${var.password}"
}
  
module "ebs_create"{
  source="../../../module/ebs"  
  password="${var.password}"
}
  
output "ec2_out" {
	value = "${module.ec2_create.create_result}"
}
  
output "ebs_out" {
	value = "${module.ebs_create.create_result}"
}
