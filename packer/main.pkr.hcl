packer {
    required_version = ">= 1.7.0"
    required_plugins {
      vagrant = {
        source  = "github.com/hashicorp/vagrant"
        version = "~> 1"
      }
      virtualbox = {
          version = "~> 1"
          source  = "github.com/hashicorp/virtualbox"
      }
      ansible = {
        source  = "github.com/hashicorp/ansible"
        version = "~> 1"
      }
    }
}

source "virtualbox-iso" "fedora-iot" {
  iso_url = var.iso.url 
  iso_checksum = var.iso.checksum
  ssh_username = var.ssh_username
  ssh_password = var.ssh_password
  shutdown_command = "echo 'packer' | sudo -S shutdown -P now"

  boot_wait = "1s"      
  boot_command = [
      "<wait50>",
  ]
}

build {
  sources = ["sources.virtualbox-iso.fedora-iot"]

    # remote bootstrap the filesystem
    provisioner "ansible" {
        roles_path = "./roles"
        inventory_directory = "./inventory"
        playbook_file = "playbooks/install.yml"
        ansible_env_vars = ["ANSIBLE_FORCE_COLOR=1"]
        extra_arguments = [ 
            "--user", var.ssh_username,
            "--become-method", "su",
            "--scp-extra-args", "'-O'",
            "--vault-password-file", ".vaultpass",
            "--extra-vars", "source=${abspath(path.cwd)}",
        ]
    }

    post-processor "vagrant" {
        keep_input_artifact = true
        output = "packer/output/{{.BuildName}}_{{.Provider}}.box"
    }
}

