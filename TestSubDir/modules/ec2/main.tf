
variable "password" {
  default = "foo"
}

resource "camc_scriptpackage" "ebs_create" {
  program = ["/bin/bash","./create.sh"]
  program_sensitive = ["-p", "${var.password}"]
  on_create = true
}

output "create_result" {
  value = "${camc_scriptpackage.ebs_create.result}"
}
