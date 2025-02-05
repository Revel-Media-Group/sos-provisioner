# SignageOS Provisioner

an ansible repo containing all the things needed for provisioning
signageos players running linux.

## creating a USB for provisioning (mac os)

you'll need `fzf` and `just` installed

```bash
brew install fzf just
```

you'll also need the .vaultpass file in the project directory

```bash
tree -a -C -L 1
.
├── .git
├── .gitignore
├── .justfile
├── .vaultpass <- this should be present
├── Brewfile
├── README.md
├── Vagrantfile
├── ansible.cfg
├── compose.yml
├── docker
├── docs
├── inventory
├── local.yml
├── packer
├── playbooks
├── requirements.yml
├── roles
├── scripts
└── venv
```

1. format a USB drive with [exfat](https://www.seagate.com/support/kb/how-to-format-your-drive-exfat-on-macos-big-sur-and-later/)
1. make sure the drive is mounted. you can check by using ls

```bash
ls /Volumes/
```

1. go ahead and run just usb

```bash
just usb
```

1. it'll then create a new usb!
