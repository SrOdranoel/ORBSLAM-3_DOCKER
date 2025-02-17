#!/bin/bash

set -o errexit

grpname="flirimaging"

if [ "$(id -u)" = "0" ]
then
    echo
    echo "This script will assist users in configuring their udev rules to allow"
    echo "access to USB devices. The script will create a udev rule which will"
    echo "add FLIR USB devices to a group called $grpname. The user may also"
    echo "choose to restart the udev daemon. All of this can be done manually as well."
    echo
else
    echo
    echo "This script needs to be run as root, e.g.:"
    echo "sudo configure_spinnaker.sh"
    echo
    exit 0
fi

# Adicionar o usuário 'y' ao grupo 'flirimaging' automaticamente
usrname="y"
if (getent passwd $usrname > /dev/null)
then
    echo "Adding user $usrname to group $grpname..."
    groupadd -f $grpname
    usermod -a -G $grpname $usrname
    echo "Added user $usrname"
else
    echo "User \"$usrname\" does not exist"
    exit 1
fi

# Criar regra udev
UdevFile="/etc/udev/rules.d/40-flir-spinnaker.rules"
echo
echo "Writing the udev rules file..."
echo "SUBSYSTEM==\"usb\", ATTRS{idVendor}==\"1e10\", GROUP=\"$grpname\"" 1>>$UdevFile
echo "SUBSYSTEM==\"usb\", ATTRS{idVendor}==\"1724\", GROUP=\"$grpname\"" 1>>$UdevFile

# Reiniciar o serviço udev automaticamente
echo "Restarting the udev daemon..."
/etc/init.d/udev restart

echo "Configuration complete."
echo "A reboot may be required on some systems for changes to take effect."
exit 0
