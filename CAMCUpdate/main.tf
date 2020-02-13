resource "camc_scriptpackage" "create" {
  program = ["/bin/bash","./create.sh"]
  program_sensitive = ["-p", "${var.password}"]
  on_create = true
}


resource "camc_scriptpackage" "delete" {
  program = ["/bin/bash","./update.sh"]
  program_sensitive = ["-p", "${var.password}"]
  on_delete = true
}

variable "password" {
  default = "foo"
}

output "create_result" {
  value = "${camc_scriptpackage.create.result}"
}

output "delete_result" {
  value = "${camc_scriptpackage.delete.result}"
}
