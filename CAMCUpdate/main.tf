resource "camc_updatable_scriptpackage" "create" {
  program = ["/bin/bash","./create.sh"]
  program_sensitive = ["-p", "${var.password}"]
  query = {
    prop1 = "${var.password}"
  } 
  query_sensitive = {
    prop2 = "${var.password}"
  }
  on_create = true
}


resource "camc_updatable_scriptpackage" "update" {
  program = ["/bin/bash","./update.sh"]
  program_sensitive = ["-p", "${var.password}"]
  query = {
    prop1 = "${var.password}"
  } 
  query_sensitive = {
    prop2 = "${var.password}"
  }
  on_update = true
}

resource "camc_updatable_scriptpackage" "delete" {
  program = ["/bin/bash","./update.sh"]
  program_sensitive = ["-p", "${var.password}"]
  query = {
    prop1 = "${var.password}"
  } 
  query_sensitive = {
    prop2 = "${var.password}"
  }
  on_delete = true
}

variable "password" {
  default = "foo"
}

output "create_result" {
  value = "${camc_updatable_scriptpackage.create.result}"
}

output "update_result" {
  value = "${camc_updatable_scriptpackage.update.result}"
}
