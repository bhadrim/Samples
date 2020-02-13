
variable "password" {
  default = "foo"
}

resource "camc_scriptpackage" "ec2_create" {
  program = ["/bin/bash","./create.sh"]
  program_sensitive = ["-p", "${var.password}"]
  on_create = true
}

output "create_result" {
  value = "${camc_scriptpackage.ec2_create.result}"
}
