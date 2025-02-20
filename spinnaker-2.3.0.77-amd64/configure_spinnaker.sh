#!/bin/bash

set -o errexit

grpname="flirimaging"

# Verifica se o script está sendo executado como root
if [ "$(id -u)" != "0" ]
then
    echo
    echo "This script needs to be run as root, e.g.:"
    echo "sudo configure_spinnaker.sh"
    echo
    exit 0
fi

# Adiciona o usuário 'y' ao grupo 'flirimaging' automaticamente
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

# Cria a regra udev
UdevFile="/etc/udev/rules.d/40-flir-spinnaker.rules"
echo
echo "Writing the udev rules file..."

# Verifica se o arquivo já existe
if [ -f "$UdevFile" ]
then
    echo "The file $UdevFile already exists. Do you want to overwrite it?"
    echo -n "[Y/n] $ "
    read confirm
    if [ "$confirm" = "n" ] || [ "$confirm" = "N" ]
    then
        echo "Aborting. No changes were made."
        exit 0
    fi
fi

# Escreve as regras udev
echo "SUBSYSTEM==\"usb\", ATTRS{idVendor}==\"1e10\", GROUP=\"$grpname\"" >$UdevFile
echo "SUBSYSTEM==\"usb\", ATTRS{idVendor}==\"1724\", GROUP=\"$grpname\"" >>$UdevFile

# Reinicia o serviço udev automaticamente
echo "Restarting the udev daemon..."
/etc/init.d/udev restart

echo "Configuration complete."
echo "A reboot may be required on some systems for changes to take effect."
exit 0
