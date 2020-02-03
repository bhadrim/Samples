resource "camc_scriptpackage" "create" {
  program = ["/bin/bash","./create.sh"]
  program_sensitive = ["-p", "${var.password}"]
  on_create = true
}


resource "camc_scriptpackage" "update" {
  program = ["/bin/bash","./update.sh","-p", "${var.password}"]
  #program_sensitive = ["-p", "${var.password}"]
  on_update = true
}

variable "password" {
  default = "foo"
}

output "create_result" {
  value = "${camc_scriptpackage.create.result}"
}

output "update_result" {
  value = "${camc_scriptpackage.update.result}"
}
