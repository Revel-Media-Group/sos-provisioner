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


# runs the ansible host
host:
    docker compose up -d
    docker exec -it ansible zsh


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


# packer (reset|debug|build) $target $options
packer $command $target='packer' *$options='':
    #!/usr/bin/env bash
    if [[ $command == "reset" ]]; then
        [[ -d ./packer/output/ ]] && rm -rf packer/output
        packer init $options $target
    elif [[ $command == "debug" ]]; then
        PACKER_LOG=1 just packer build $target -on-error=ask
    elif [[ $command == "build" ]]; then
        packer build -force -on-error=ask $options $target
    else
        packer $command $options $target
    fi

docsgen:
    #!/usr/bin/env bash
    echo "Generating Documentation, this could take a minute..."
    find docs -name -print0 | xargs -o -I {} sh -c 'pandoc "{}" -o "docs/output/$(basename "{}" .md).docx"'
    echo "Success!"
    echo "docx saved to: $(pwd)/docs/output"


usb:
    #!/usr/bin/env bash
    echo "insert empty + ext-fat formateed USB. Press Enter to continue..."
    read
    drive_path=$(find /Volumes/ -depth 1 | fzf --header="Select which drive to copy to")
    [[ -z $drive_path ]] && exit 1

    # removing
    rm -rf "$drive_path"/{.,}*
    
    # coping
    cp .vaultpass $drive_path
    cp -R inventory $drive_path
    cp -a scripts/. $drive_path

    # umounting
    diskutil umount /Volumes/Untitled &> /dev/null
    echo "finished! you can unplug the usb."

secrets:
    #!/usr/bin/env bash
    if [ ! -f "./secrets.zip" ]; then
        echo "please install secrets.zip: "
        echo "https://drive.google.com/file/d/1je94U7cb1jU4wTXLFBmjTX7ce6hS3D8o/view?usp=drive_link"
        exit 1
    fi

    echo "installing ssh keys..."
    unzip -o secrets.zip ansible ansible.pub -d ~/.ssh/ &> /dev/null
    sudo chown $(whoami) ~/.ssh/ansible ~/.ssh/ansible.pub
    sudo chmod 600 ~/.ssh/ansible
    sudo chmod 644 ~/.ssh/ansible.pub

    echo "installing .vaultpass..."
    unzip -o secrets.zip .vaultpass -d . &> /dev/null
    sudo chown $(whoami) ./.vaultpass
    sudo chmod 600 ./.vaultpass

    echo "Installation complete!"


