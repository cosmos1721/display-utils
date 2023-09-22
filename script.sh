#!/bin/bash


# pgk(){
#   declare -A osInfo;
#   osInfo[/etc/redhat-release]=yum
#   osInfo[/etc/arch-release]=pacman
#   osInfo[/etc/gentoo-release]=emerge
#   osInfo[/etc/SuSE-release]=zypp
#   osInfo[/etc/debian_version]=apt-get
#   osInfo[/etc/alpine-release]=apk

#   for f in ${!osInfo[@]}
#   do
#       if [[ -f $f ]];then
#           echo ${osInfo[$f]}
#       fi
#   done
# }

install(){
sudo add-apt-repository ppa:rockowitz/ddcutil -y
sudo apt install ddcutil -y
sudo apt install acpi -y
sudo cp display-utils.sh /usr/local/bin/display-utils
sudo chmod +x /usr/local/bin/display-utils
mkdir -p ~/.config/systemd/user/

sudo cat <<EOL > ~/.config/systemd/user/display-utils.service
[Unit]
Description=Script Daemon For Test User Services

[Service]
Type=simple
ExecStart=/usr/local/bin/display-utils
Restart=on-failure
StandardOutput=file:%h/display-utils.log

[Install]
WantedBy=default.target

EOL

systemctl --user daemon-reload
systemctl --user start display-utils.service
systemctl --user enable display-utils.service

echo "Installation and related operations are completed. Try messing up with your media keys now, lets see if it works or not."
}

uninstall(){
echo " removing display-utils"
systemctl --user daemon-reload
systemctl --user stop display-utils.service
systemctl --user disable display-utils.service
sudo rm -rf /usr/local/bin/display-utils
sudo rm -rf ~/.config/systemd/user/display-utils.*
sudo apt remove ddcutil -y
sudo apt-add-repository --remove ppa:rockowitz/ddcutil -y
echo "uninstall completed"
}

read -p "Do you want to (I)nstall or (U)ninstall display-utils? (I/U): " choice

case "$choice" in
  [Ii]*)
    install
    ;;
  [Uu]*)
    uninstall
    ;;
  *)
    echo "Invalid choice. Please enter 'I' to install or 'U' to uninstall."
    exit 1
    ;;
esac


