# SinageOS Player Provisioner

a packer project that provisions a bootable image running linux
bootstrapping a chromium in kiosk mode at start. the goal is to
make setup and provisioning players as painless as flashing an ISO to
a disk. no technical know-how, high re-producability and low churn.

maybe we can use PXE server to bootstrap the various devices over the network too?

since sinageOS is literally just a node app that runs on top of chromium:

- [ ] let's use [fedora IOT](https://fedoraproject.org/iot/) as our base
- [ ] that uses [packer](https://www.packer.io/) to create the images
- [ ] and configuring what we need on the distro using [ansible](https://docs.ansible.com/ansible/latest/index.html)


# getting started

in order to run the playbooks on the device you'll need 3 things:
- the ip of the device
- sshd configured to permit root login
- sshd enabled and started

once you've fully installed linux of choice, open the terminal and type the follow:
```bash
sudo sed -i 's/^#\?PermitRootLogin .*/PermitRootLogin yes/' /etc/ssh/sshd_config
sudo systemctl enable --now sshd
```


then on the host machine (your laptop) in the project directory:
```bash
touch inventory/office
echo "<insert device ip>" >> inventory/office
ansible-playbook playbooks/bootstrap.yml -k 
```


