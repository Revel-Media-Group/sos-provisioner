# SinageOS Player Provisioner

## Provisioning Ubuntu

### boot into the bios

you'll need to get into the bios in the player.
in this order plugin a keyboard, mouse, ethernet, monitor, Ubuntu USB.
hold off on power until you're ready.

prepare to press f12/del/f2 on the keyboard. most of the time it should be f12.
plugin the power for the player and press on repeat the respective key. there should be an
Ubuntu logo on the screen while it boots into. you should then get to the desktop:

![desktop](docs/images/IMG_6831.JPG)

shortly after there will be a dialog that for install. click the
**`Install Ubuntu`** button

![welcome splash](docs/images/IMG_6832.JPG)

click and select english for the language

![set keyboard](docs/images/IMG_6833.JPG)

click `Continue`

you'll then be presented:

![alt](docs/images/IMG_6834.JPG)

you'll then want to:

- switch the option from `Normal installation` to `Minimal installation`
- un-check `Download updates while installing Ubuntu`
- check `Install third-party software for graphics and Wi-Fi hardware and additional media formats`

![alt](docs/images/IMG_6835.JPG)

click `Continue`

under `Installation type` choose the top option to `Erase Ubuntu...`
![alt](docs/images/IMG_6836.JPG)

click `Install Now`

Dialog should pop up confirming the changes.
![alt](docs/images/IMG_6837.JPG)

click `Continue`

you'll be prompted to select the timezone, should select automatically.
![alt](docs/images/IMG_6838.JPG)

click `Continue`

you'll then need to fill in all the information for the login.

- set the `Your Name` field to `revel`
- either set the `Your Computer Name` to the desired name/purpose of the device or leave it be
- set the `Pick a username` field to `revel` if not already
- set + confirm our password we have
- set to automatically login

![alt](docs/images/IMG_6839.JPG)

click `Continue`

at this point it will start installing. it will take roughly 15 - 20 minutes
so it's best to unplug the monitor, keyboard, and mouse and continue to the next.
after its done installing, you'll be greeted with:
![alt](docs/images/IMG_6840.JPG)

click `Restart Now`

you'll then be greeted with the ubuntu logo and  prompted to unplug the install USB.
go ahead and unplug it and hit `Enter` on the keyboard.
![alt](docs/images/IMG_6841.JPG)

once it's rebooted, you'll be created with a dialog for setup. furiously click where the `skip` button is
to confirm all the defaults
![alt](docs/images/IMG_6842.JPG)

at this point you'll need to plugin the designated USB for install scripts. he contains sensitive information
to revel so please keep him safe. go ahead and in the nav on the side open him up
![alt](docs/images/IMG_6843.JPG)

you'll then see three files in the USB drive.

- install
- setup
- vaultpass
  ![alt](docs/images/IMG_6844.JPG)

right click on the `setup` script and choose `Run as a Program`
![alt](docs/images/IMG_6845.JPG)

it will pop up a terminal asking for a password. type the password set previously and hit `enter`.
in the install
![alt](docs/images/IMG_6846.JPG)

occasionally and update prompt will show, just minimize him
![alt](docs/images/IMG_6847.JPG)

you'll then want to eject the SENSITIVE usb
![alt](docs/images/IMG_6848.JPG)

in the file explorer navigate to the home folder
![alt](docs/images/IMG_6849.JPG)

right click in an empty space and open in terminal
![alt](docs/images/IMG_6850.JPG)

lastly type `./install` and hit `enter`. should ask for a password.
go ahead and type it in and hit `enter`
![alt](docs/images/IMG_6851.JPG)
