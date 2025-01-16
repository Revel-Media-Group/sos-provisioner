packer {
    required_version = ">= 1.7.0"
    required_plugins {
      vagrant = {
        source  = "github.com/hashicorp/vagrant"
        version = "~> 1"
      }
      qemu = {
        source  = "github.com/hashicorp/qemu"
        version = "~> 1"
      }
      ansible = {
        source  = "github.com/hashicorp/ansible"
        version = "~> 1"
      }
    }
}

source "qemu" "gentoo" {
    headless = false
    format = "qcow2"
    vm_name = "gentoo.qcow2"
    output_directory = "packer/output"

    disk_size = "50G"

    efi_boot = true
    efi_firmware_code = var.efi_firmware.code
    efi_firmware_vars = var.efi_firmware.vars

    iso_url = var.gentoo_iso.url
    iso_checksum = var.gentoo_iso.checksum

    ssh_username = var.ssh_username
    ssh_password = var.ssh_password

    memory = "4000"
    accelerator = "kvm"
    qemuargs = [
        ["-smp", "cpus=12,sockets=1,threads=2"]
    ]

    boot_wait = "1s"      
    boot_command = [
        "<enter>",
        "<wait10>",
        "<enter>",
        "<wait50>",
        "passwd root",
        "<enter>",
        var.ssh_password,
        "<enter>",
        var.ssh_password,
        "<enter>",
        "/etc/init.d/sshd start",
        "<enter>",
        "<wait4>",
    ]
}

build {
    sources = ["source.qemu.gentoo"]

    # remote bootstrap the filesystem
    provisioner "ansible" {
        roles_path = "./roles"
        inventory_directory = "./inventory"
        playbook_file = "playbooks/install/stage1.yml"
        ansible_env_vars = ["ANSIBLE_FORCE_COLOR=1"]
        extra_arguments = [ 
            "--user", var.ssh_username,
            "--become-method", "su",
            "--scp-extra-args", "'-O'",
            "--vault-password-file", ".vaultpass",
            "--extra-vars", "source=${abspath(path.cwd)}",
        ]
    }

    # local bootstrap the filesystem
    provisioner "ansible-local" {
        role_paths = ["./roles/install"]
        command = "ANSIBLE_FORCE_COLOR=1 /root/ansible/bin/ansible-playbook"
        group_vars = "inventory/group_vars"
        playbook_file = "playbooks/install/stage2.yml"
        inventory_file = "inventory/chroot"
        extra_arguments = [ 
            "--connection=chroot",
            "--vault-password-file=/tmp/vaultpass"
        ]
    }

    post-processor "vagrant" {
        keep_input_artifact = true
        output = "packer/output/{{.BuildName}}_{{.Provider}}.box"
    }
}

