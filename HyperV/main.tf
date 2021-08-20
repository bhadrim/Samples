
terraform {
  required_providers {
    hyperv = {
      version = "1.0.3"
      source = "registry.terraform.io/taliesins/hyperv"
    }
  }
}

provider "hyperv" {

}

variable "instance_name"{
  description="Virtual machine name"
}

variable "generation"{
  description="Virtual machine generation"
  default = 2
}

variable "processor_count"{
  description="Virtual machine processor count"
  default = 1
}

variable "static_memory"{
  description="is static memory"
  default = true
}

variable "memory_startup_bytes"{
  description="Virtual machine startup memory"
  default = 2147483648
}

variable "resource_pool_name"{
  description="Resource pool name"
  default = "Primordial"
}

variable "iso_path"{
    description="Virtual machine iso path"
    default="C:\\Users\\Administrator\\Downloads\\en_windows_server_2019_updated_jun_2021_x64_dvd_a2a2f782.iso"
}

variable "controller_type"{
    default = "Scsi"
    description = "Drive controller type"
} 

variable network_switch_name {
  description = "Network switch name"
  default = "Intel(R) 82574L Gigabit Network Connection - Virtual Switch"
}

variable instance_vhd_path{
  description = "VHD Path"
  default = "c:\\users\\public\\documents\\hyper-v\\virtual hard disks\\myvm.vhdx"
}

variable instance_vhd_size{    
  description = "VHD Size"
  default = 107374182400
}

resource "hyperv_vhd" "instance_vhd" {
  path = var.instance_vhd_path
  size = var.instance_vhd_size
}

resource "hyperv_machine_instance" "an_instance" {
  name = var.instance_name
  generation = var.generation
  processor_count = var.processor_count
  static_memory = var.static_memory
  memory_startup_bytes = var.memory_startup_bytes
  wait_for_state_timeout = 10
  wait_for_ips_timeout = 10

  vm_processor {
    expose_virtualization_extensions = true
    hw_thread_count_per_core = 1
  }

  network_adaptors {
      name = "wan"
      switch_name = var.network_switch_name
      wait_for_ips = false
  }

  hard_disk_drives {
    controller_type = "Scsi"
    path = hyperv_vhd.instance_vhd.path
    controller_number = 0
    controller_location = 0
    resource_pool_name = var.resource_pool_name
  }

  dvd_drives {
    controller_number = 0
    controller_location = 1
    path = var.iso_path
    resource_pool_name = var.resource_pool_name
  }
}
