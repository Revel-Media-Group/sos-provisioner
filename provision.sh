#!/bin/bash
# This script is run by root to provision the signageos-server

ORGANIZATION_UID="$1"
DISABLE_FRONTEND=false
SETUP_KOISK=false

if [ "$ORGANIZATION_UID" = "" ]; then
    echo "Usage: $0 <companyUID> [--disable-frontend] [--setup-kiosk]"
    exit 1
fi

echo "Using organization UID:" $ORGANIZATION_UID

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

# Register SignageOS repository
dnf repolist | grep SignageOS &> /dev/null
if [ $? -ne 0 ]; then
    echo "Registering SignageOS repository"
    dnf config-manager --add-repo https://linux-package-repository.signageos.io/fedora/signageos.repo
fi

# Check signageos-server is running
systemctl status signageos-server.service &> /dev/null
if [ $? == 0 ]; then
    echo "Stopping signageos-server"
    systemctl stop signageos-server.service &> /dev/null
fi

# Install signageos-server
dnf list installed signageos-fedora &> /dev/null
if [ $? -ne 0 ]; then
    echo "Installing signageos-server"
    dnf install -y signageos-fedora.x86_64 --refresh
    if [ $? -ne 0 ]; then
        echo "Failed to install signageos-server"
        exit 1
    fi
else
    echo "Upgrading signageos-server"
    dnf upgrade -y signageos-fedora.x86_64 --refresh
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
    GDM_CONF_FILE="/etc/gdm/custom.conf"

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
close="['<CTRL><Alt>F8']"
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

read -p "System will be rebooted in 10 seconds. Press any key to cancel" -t 10 -n 1 key 

if [ $? = 0 ] ; then
    echo -e "\nReboot skipped"
else
    echo -e "\nRebooting the system"
    reboot
fi
