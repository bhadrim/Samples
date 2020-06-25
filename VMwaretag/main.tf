provider "vsphere" {
  version              = ">= 1.3.0"
  allow_unverified_ssl = "true"
}

resource "vsphere_tag_category" "ibm_terraform_automation_category" {
  count = length(module.camtags.tagslist) > 0 ? 1 : 0
  name        = format("%s %s", "IBM Terraform Automation Tags for", var.vm_name)
  description = "Category for IBM Terraform Automation"
  cardinality = "MULTIPLE"

  associable_types = [
    "VirtualMachine",
    "Datastore",
    "Network",
  ]
}

resource "vsphere_tag" "ibm_terraform_automation_tags" {
  count = length(var.camtags.tagslist)
  name        = element(var.tagslist, count.index)
  category_id = element(vsphere_tag_category.ibm_terraform_automation_category.*.id, 0)
  description = "Managed by IBM Terraform Automation"
}

resource "vsphere_virtual_machine" "vm" {
  name             = var.vm_name
  folder           = var.vm_folder
  num_cpus         = var.vm_vcpu
  memory           = var.vm_memory
  resource_pool_id = data.vsphere_resource_pool.resource_pool.id
  datastore_id     = data.vsphere_datastore.datastore.id
  guest_id         = data.vsphere_virtual_machine.vm_image_template.guest_id
  scsi_type        = data.vsphere_virtual_machine.vm_image_template.scsi_type
  tags = vsphere_tag.ibm_terraform_automation_tags[*].id
  clone {
    template_uuid = data.vsphere_virtual_machine.vm_image_template.id
    timeout       = var.vm_clone_timeout
    customize {
      linux_options {
        domain    = var.vm_domain_name
        host_name = var.vm_name
      }

      network_interface {
        ipv4_address = var.vm_ipv4_address
        ipv4_netmask = var.vm_ipv4_netmask
      }

      ipv4_gateway    = var.vm_ipv4_gateway
      dns_suffix_list = var.dns_suffixes
      dns_server_list = var.dns_servers
    }
  }

  network_interface {
    network_id   = data.vsphere_network.vm_network.id
    adapter_type = var.adapter_type
  }

  disk {
    label          = "${var.vm_name}.vmdk"
    size           = var.vm_disk_size
    keep_on_remove = var.vm_disk_keep_on_remove
    datastore_id   = data.vsphere_datastore.datastore.id
  }

  lifecycle {
    ignore_changes = [
      datastore_id,
      disk.0.datastore_id,
    ]
    create_before_destroy = true
  }
}
