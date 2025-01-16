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
        code = "/usr/share/edk2-ovmf/OVMF_CODE.fd"
        vars = "/usr/share/edk2-ovmf/OVMF_VARS.fd"
    }
}

variable "gentoo_iso" {
    type = map(string)
    default = {
        url = "https://mirror.bytemark.co.uk/gentoo/releases/amd64/autobuilds/current-install-amd64-minimal/install-amd64-minimal-20240923T191858Z.iso"
        checksum = "sha256:7918a6f1e30a5e6f4c5c57713f141d3f7a316e2ce6b2a5a944848182d0b974ba"
    }
}
