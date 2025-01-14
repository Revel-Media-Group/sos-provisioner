# SinageOS Player Provisioner

a packer project that provisions a bootable image running linux
bootstrapping a chromium in kiosk mode as start. the goal is to
make setup and provisioning players as painless as flashing an ISO to
a disk. no technical know-how, high re-producability and low churn.

since sinageOS is literally just a node app that runs on top of chromium:

- \[\] let's use [fedora IOT](https://fedoraproject.org/iot/) as our base
- \[\] that uses [packer](https://www.packer.io/) to create the images
- \[\] and configuring what we need on the distro using [ansible](https://docs.ansible.com/ansible/latest/index.html)
