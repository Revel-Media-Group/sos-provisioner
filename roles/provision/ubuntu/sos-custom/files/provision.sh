#!/bin/bash
# This script is run by root to provision the signageos-server

ORGANIZATION_UID="$1"
DISABLE_FRONTEND=false
SETUP_KOISK=false

if [ "$ORGANIZATION_UID" = "" ]; then
    echo "Usage: $0 <companyUID> [--disable-frontend] [--setup-kiosk]"
    exit 1
fi

args=$#
for (( i=2; i<=$args; i++ ))
do
    if [ "${!i}" == "--disable-frontend" ]; then
        echo "Frontend will be disabled"
        DISABLE_FRONTEND=true
    fi
    if [ "${!i}" == "--setup-kiosk" ]; then
        echo "System will be configured as kiosk"
        SETUP_KOISK=true
    fi
done

# Check if snap version of chromium is installed
if command -v snap &> /dev/null
then
    echo "Snap is unfortunately present"
    if snap list | grep -i chromium &> /dev/null ; then
        echo -e "\033[33m[WARN] signageOS does not support snap version of chromium\033[m"
        read -p "Do you wish to uninstall your current chromium and install supported version? [y/n]: " -n 1 key
        if [ $? = 0 ] ; then
            if [[ "$key" == "y" || "$key" == "Y" ]] ; then
                echo -e "\nUninstalling snap version of chromium"
                apt -y remove chromium-browser
                snap remove chromium
            else
                echo -e "\nCurrent installation of chrium stayed untached"
            fi
        fi
    else
        echo "Chromium is not installed through snap"
    fi
fi

# Check if chromium is installed
if ! apt list --installed 2> /dev/null | grep "chromium-browser" &> /dev/null; then
    echo "Chromium is not present. Installing"
    if [ ! -f /etc/apt/sources.list.d/savoury1-ubuntu-chromium-jammy.list ] ; then
        echo "Adding chromium repository"
        add-apt-repository -y ppa:savoury1/chromium
    fi
    apt update
    apt -y --fix-broken install
    apt install -y chromium-browser
else
    echo "Found chromium. Skipping the installation"
fi

# Check installed nodejs package
if ! sudo apt satisfy "nodejs (>= 16)" &> /dev/null ; then
    echo "Nodejs not present. Installing"
    apt install curl
    curl -sL https://deb.nodesource.com/setup_16.x -o nodesource_setup.sh
    chmod +x nodesource_setup.sh
    ./nodesource_setup.sh
    rm nodesource_setup.sh
else
    echo "Nodejs found. Skipping the installation"
fi

# Register SignageOS repository
if [ ! -f /etc/apt/sources.list.d/signageos.list ]; then
    echo "Registering SignageOS repository"
    echo "deb [arch=amd64] https://linux-package-repository.signageos.io/ubuntu stable main" | sudo tee -a /etc/apt/sources.list.d/signageos.list
    wget -qO - https://linux-package-repository.signageos.io/ubuntu/DEB-GPG-KEY-signageos | sudo apt-key add -
fi

apt update

# Check signageos-server is running
systemctl status signageos-server.service &> /dev/null
if [ $? == 0 ]; then
    echo "Stopping signageos-server"
    systemctl stop signageos-server.service &> /dev/null
fi

# Install signageos-server
dpkg -l | grep signageos-ubuntu &> /dev/null
if [ $? -ne 0 ]; then
    echo "Installing signageos-server"
    apt install -y signageos-ubuntu
    if [ $? -ne 0 ]; then
        echo "Failed to install signageos-server"
        exit 1
    fi
else
    echo "Upgrading signageos-server"
    apt upgrade -y signageos-ubuntu
fi

# Configure auto-verification for signageos-server
echo "Configuring signageos-server"
echo "autoVerification={\"organizationUid\":\"$ORGANIZATION_UID\"}" >> /etc/signageos/signageos.conf

# Disable frontend if requested
if [ "$DISABLE_FRONTEND" == true ]; then
    echo "disable_frontend=true" >> /etc/signageos/signageos.conf
fi

# Start signageos-server
systemctl start signageos-server.service &> /dev/null
if [ $? -ne 0 ]; then
    echo "Failed to start signageos-server"
    exit 1
fi

# Wait for signageos-server to verify and then restart
# TODO this is a hack, the service shoud not need to be restarted
sleep 20
systemctl restart signageos-server.service &> /dev/null
if [ $? -ne 0 ]; then
    echo "Failed to restart signageos-server"
    exit 1
fi
systemctl enable signageos-server.service
if [ ! "$DISABLE_FRONTEND" == true ]; then
    systemctl enable chromium.service
fi

# Configure system as kiosk
if [ "$SETUP_KOISK" == true ]; then
    KIOSK_USER=soskiosk
    ACCOUNT_CONF_FILE=/var/lib/AccountsService/users/$KIOSK_USER
    GDM_OVERRIDE_FILE=/usr/share/glib-2.0/schemas/10_signageos.gschema.override
    GDM_CONF_FILE="/etc/gdm3/custom.conf"

    export DISPLAY=$(ls /tmp/.X11-unix | tr 'X' ':' | head -n 1 | sed 's/=//g' | sed 's/\x1B\[[0-9;]\{1,\}[A-Za-z]//g')
    export XAUTHORITY=$(ps aux | grep Xorg | grep -Po 'auth \K[^\s]*' | tail -1)

    # Check existence of /usr/share/glib-2.0/schemas/10_signageos.gschema.override
    if [ ! -f $GDM_OVERRIDE_FILE ]; then
        cat > /$GDM_OVERRIDE_FILE << EOF
[org.gnome.desktop.wm.preferences]
num-workspaces=1
[org.gnome.settings-daemon.plugins.power]
idle-dim=false
[org.gnome.desktop.session]
idle-delay=0
[org.gnome.software]
allow-updates=false
[org.gnome.desktop.wm.keybindings]
close=['<CTRL><Alt>F8']
EOF
    fi

    glib-compile-schemas /usr/share/glib-2.0/schemas

    egrep -i "^$KIOSK_USER:" /etc/passwd > /dev/null;
    if [ ! $? -eq 0 ]; then
        useradd -U -m $KIOSK_USER
        passwd -d $KIOSK_USER
    else
        echo "User" $KIOSK_USER "already exists. Skipping."
    fi

    # Configure gdm
    echo "Configuring gdm for kiosk mode"
    systemctl set-default graphical.target

    if [ -f $GDM_CONF_FILE ]; then
        echo 'Creating GDM configuration backup.'
        cat $GDM_CONF_FILE > $GDM_CONF_FILE.bac
    fi

    cat > $GDM_CONF_FILE << EOF
# GDM configuration storage

[daemon]
# Uncomment the line below to force the login screen to use Xorg
WaylandEnable=false
AutomaticLoginEnable=True
AutomaticLogin=soskiosk
DefaultSession=gnome-xorg.desktop

[security]

[xdmcp]

[chooser]

[debug]
# Uncomment the line below to turn on debugging
#Enable=true
EOF

    if [ -f $ACCOUNT_CONF_FILE ]; then
        echo 'Creating account configuration backup.'
        cat $ACCOUNT_CONF_FILE > $ACCOUNT_CONF_FILE.bac
    fi

    cat > /var/lib/AccountsService/users/$KIOSK_USER << EOF
[User]
Language=en_US.UTF-8
Session=gnome-classic-xorg
PasswordHint=
Icon=/var/lib/AccountsService/icons/sususer
SystemAccount=false
EOF

    # Disable first login setup
    sudo -E su $KIOSK_USER -p -c "mkdir -p /home/$KIOSK_USER/.config"
    sudo -E su $KIOSK_USER -p -c "echo 'yes' > /home/$KIOSK_USER/.config/gnome-initial-setup-done"

    echo "Kiosk mode succesfully configured"
fi

