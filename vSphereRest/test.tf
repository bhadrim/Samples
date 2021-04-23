provider "vsphere" {
  version              = ">= 1.3.0, <= 1.18.3"
  allow_unverified_ssl = "true"
}

variable folder{
  type="string"
}

resource "null_resource" "folder_exists" {
  provisioner "local-exec" {
   command = "/usr/bin/python test.py ${var.folder}"
  }
}
