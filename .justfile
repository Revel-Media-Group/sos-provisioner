PWD := "$(shell pwd)"
SSH_KEYNAME := "ansible"

# list all just commands
default:
    @just --list --unsorted

# installs all dependencies you'll need to run the project
deps:
    brew bundle install
    ansible-galaxy collection install -r requirements.yml
    packer init packer

# creates/copies ssh keys to hosts
ssh $command *$options='':
    #!/usr/bin/env bash
    if [[ $command == "create" ]]; then
        ssh-keygen $options -t ed25519 -f ~/.ssh/{{ SSH_KEYNAME }}
    elif [[ $command == "copy" ]]; then
        read -p "username: " USER
        read -p "ssh server: " SSH
        ssh-copy-id $options -i ~/.ssh/{{ SSH_KEYNAME }}.pub $USER@$SSH
    fi

VAGRANT_ANSIBLE_INV := PWD + "/.vagrant/provisioners/ansible/inventory/vagrant_ansible_inventory"
# vagrant (reset|up|<vagrant --help>) $options
vagrant $command *$options='':
    #!/usr/bin/env bash
    if [[ $command == "reset" ]]; then
        [[ -d ./.vagrant/ ]] && rm -rf .vagrant
        vagrant plugin update $options
    elif [[ $command == "up" ]]; then
        vagrant up $options
        ln -sf $VAGRANT_ANSIBLE_INV inventory/vagrant
    else
        vagrant $command $options
    fi

# ansible-vault alias 
ansible-vault $target *$options='':
    #!/usr/bin/env bash
    unset HISTFIL
    [[ ! -f ".vaultpass" ]] \
        && dd if=/dev/urandom of=.vaultpass bs=8388607 count=1 2> /dev/null
    ansible-vault $target $options

# ansible-playbook alias 
ansible-playbook $target *$options='':
    #!/usr/bin/env bash
    ansible-playbook $target $options
    
