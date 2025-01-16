# general variables
variable "ssh_username" {
    type = string
    default = "root"
}

variable "ssh_password" {
    type = string
    default = "password"
    sensitive = true
}

variable "ssh_private_key_file" {
  type    = string
  default = "~/.ssh/ansible"
}

variable "efi_firmware" {
    type = map(string) 
    default = {
        code = "/opt/homebrew/share/qemu/edk2-x86_64-code.fd"
        vars = "/opt/homebrew/share/qemu/edk2-vars.fd"
    }
}

variable "iso" {
    type = map(string)
    default = {
        url = "https://download.fedoraproject.org/pub/alt/iot/41/IoT/aarch64/iso/Fedora-IoT-ostree-41-20241027.0.aarch64.iso"
        checksum = "sha256:bc2e40243d26afb3470e8e6f5db721adb47042aecee55bf90236c1b2d801b29f"
    }
}
