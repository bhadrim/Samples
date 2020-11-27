resource "null_resource" "copy_agent" {
  connection {
    type = "winrm"
    user = "${var.ucd_agent_connection_user}"
    password = "${var.ucd_agent_connection_password}"
    host = "${var.vm_admin_ip_address}"  # IPv4 address of the virtual machine
    port="5985"
    https = false
    insecure = true
    use_ntlm = false
    timeout  = "15m"
  }
  provisioner "file" {
    source      = "UCDAgent.ps1"
    destination = "C:\\temp\\UCDAgent.ps1"
  }
}

variable "vm_admin_ip_address" {
  description = "IPv4 address of the virtual machine"
}

variable "ucd_agent_connection_user" {
  type = "string"  
}

variable "ucd_agent_connection_password" {
  type = "string"
}