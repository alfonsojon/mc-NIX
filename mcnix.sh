#!/bin/bash
#
#  Copyright 2013 Jonathan Alfonso <alfonsojon1997@gmail.com>
#  
#  This program is free software; you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation; either version 2 of the License, or
#  (at your option) any later version.
#  
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#  
#  You should have received a copy of the GNU General Public License
#  along with this program; if not, write to the Free Software
#  Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston,
#  MA 02110-1301, USA.
#  
#  
# This script does not distribute any protected Minecraft files. You can't use this to play Minecraft without buying it.
# All of the files downloaded by this script are provided by www.minecraft.net, so this does not break Minecraft's license.
# Enjoy, alfonsojon (Problems? E-Mail me at alfonsojon1997@gmail.com)

# Trap CTRL-C
trap abort 2 15
abort () {
echo "Keyboard interrupt (CTRL-C), aborting."
echo "If you cancelled mid-installation, you may have to reinstall Minecraft."
exit 0
}


###
# Legal Info
###
clear
cat <<EOF
This script does not distribute any protected Minecraft files. You can't
use this to play Minecraft without buying it. All of the files 
downloaded by this script are provided by minecraft.net, so this doesn't
break Minecraft's license.

Enjoy, alfonsojon (Problems? E-Mail me at alfonsojon1997@gmail.com)
EOF
echo ""
read -p "Press enter to continue."
###
# Begin function Main
###
function Main {
clear
cat <<EOF

   mc-*NIX v1.5.2 - 1/28/2013

   Made by alfonsojon
   E-Mail: alfonsojon1997@gmail.com
   Website: http://www.live-craft.com/

   Select an option (type the number and hit enter)
   You can also type the name of the entry. To exit, type "exit" or "quit".

1. Install Minecraft
EOF
if [ -e /usr/local/bin/minecraft ] && [ -e /usr/share/minecraft/minecraft.jar ]
then
INSTALLED_VANILLA=1
cat <<EOF
2. Uninstall Minecraft
3. Launch Minecraft
9. Troubleshoot Minecraft

EOF
fi
echo "a. Install Minecraft Server"
if [ -e /opt/minecraft_server ] && [ -e /opt/minecraft_server/minecraft_server.jar ]; then
    INSTALLED_VANILLA_SERVER=1
cat <<EOF
    b. Start Minecraft Server
    c. Uninstall Minecraft Server
EOF
fi
echo "0. Release Notes"
echo ""
printf "> "
read INPUT
if [ $BASH == /bin/bash ]; then
    shopt -s nocasematch
fi
case $INPUT in
    1|"Install Minecraft")
        Install_vanilla; Main; return;;
    2|"Uninstall Minecraft")
        if [ $INSTALLED_VANILLA -eq 1 ]; then
            Uninstall_vanilla; Main; return;
        else
            Main
        fi;;
    3|"Launch Minecraft")
        if [ $INSTALLED_VANILLA -eq 1 ]; then
            minecraft
        else
            Main
        fi;;
    9|"Troubleshoot")
        if [ $INSTALLED_VANILLA -eq 1 ]; then
            Troubleshoot_vanilla
        else
            Main
        fi;;
    0|"Release Notes")
	    FILE="/tmp/mcnix_notes.txt"
        reader "https://raw.github.com/alfonsojon/mc-NIX/master/RELEASE_NOTES.md" $FILE
        Main;;
    exit|q|quit) clear; exit 0;;
    *) Main;;
esac
if [ $BASH == /bin/bash ]; then
    shopt -u nocasematch 2>&1 >> /dev/null
fi
}

###
# Begin function Install_vanilla
###
Install_vanilla () {
clear
javacheck
# Launcher
FILE="/usr/share/minecraft/minecraft.jar"
if [ -e $FILE ]; then
    echo "Launcher already installed, upgrading"
    sudo rm -rf $FILE
fi
echo "Downloading minecraft.jar"
sudo mkdir -p "/usr/share/minecraft"
fetch_sudo "https://s3.amazonaws.com/MinecraftDownload/launcher/minecraft.jar" "$FILE"
md5verify "bb99785000fdb3ebadd61a4a347fa042" "$FILE"
# Icon
FILE="/usr/share/icons/minecraft.svg"
OLDFILE="/usr/share/pixmaps/minecraft.svg"
if [ -e $FILE ]; then
    echo "minecraft.svg already downloaded, upgrading"
    sudo rm -rf $FILE
fi
echo "Downloading minecraft.svg"
sudo rm -rf $OLDFILE
fetch_sudo "https://raw.github.com/alfonsojon/mc-NIX/master/minecraft.svg" "$FILE"
md5verify "52fe4c84feb29eecb0129d1c10895ff7" "$FILE"
# /usr/local/bin/minecraft
FILE="/usr/local/bin/minecraft"
if [ -e $FILE ]; then
    echo "Minecraft launcher binary already exists, upgrading."
    sudo rm -rf $FILE
fi
sudo touch /usr/local/bin/minecraft
sudo bash -c 'cat <<EOF > /usr/local/bin/minecraft
#!/bin/bash
cd /usr/share/minecraft
echo "bb99785000fdb3ebadd61a4a347fa042  /usr/share/minecraft/minecraft.jar" | md5sum -c
if [ "\$?" -ne "0" ]; then
    echo "Launcher not installed properly."
    echo "Please reinstall minecraft."
    zenity --title \"Error\" --error --text="Launcher not installed properly.\nPlease reinstall Minecraft."
    exit 1
else
	java -jar /usr/share/minecraft/minecraft.jar
fi
exit 0
EOF'
sudo chmod +x /usr/local/bin/minecraft
echo "Minecraft launcher binary installed successfully."
# /usr/local/bin/minecraft-debug
FILE="/usr/local/bin/minecraft-debug"
if [ -e $FILE ]; then
    echo "Minecraft debug launcher binary already exists, upgrading."
    sudo rm -rf /usr/local/bin/minecraft-debug
fi
sudo touch /usr/local/bin/minecraft-debug
sudo $SHELL -c 'cat <<EOF > /usr/local/bin/minecraft-debug
#!/bin/bash
minecraft | tee ~/minecraft_debug_log.txt && echo "Minecraft logfile stored in \"$HOME\"" &&  zenity --info --text="Minecraft logfile stored in \"$HOME\""
exit 0
EOF'
sudo chmod +x /usr/local/bin/minecraft-debug
echo "Minecraft debug launcher binary installed successfully."
# Application launcher (/usr/share/applications/mojang-Minecraft.desktop)
FILE=/usr/share/applications/mojang-Minecraft.desktop
if [ -e $FILE ]; then
    echo "Minecraft shortcut already installed, upgrading"
    sudo rm -rf /usr/share/applications/mojang-Minecraft.desktop
fi
sudo touch /usr/share/applications/mojang-Minecraft.desktop
sudo $SHELL -c 'cat <<EOF > /usr/share/applications/mojang-Minecraft.desktop
[Desktop Entry]
Comment=Play Minecraft
Name=Minecraft
TryExec=minecraft
Exec=minecraft
Actions=Debug;
GenericName=Building Game
Icon=minecraft
Categories=Game;
Type=Application

[Desktop Action Debug]
Name=Debug Mode
Exec=minecraft-debug
EOF'
sudo chmod +x /usr/share/applications/mojang-Minecraft.desktop
echo "mojang-Minecraft.desktop written to /usr/share/applications"
sudo xdg-desktop-menu install /usr/share/applications/mojang-Minecraft.desktop
sudo xdg-desktop-menu forceupdate
echo "Registered mojang-Minecraft.desktop in the menu/Launcher."
echo ""
echo ""
# Finished!
echo "Minecraft has been successfully installed!"
read -p "Press enter to continue."
Main
}

###
# Begin function Uninstall_vanilla
###
function Uninstall_vanilla {
if [ -e /usr/share/minecraft/minecraft.jar ]; then
    echo "Removing minecraft.jar..."
    sudo rm -rf /usr/share/minecraft/minecraft.jar
    echo "Launcher removed from /usr/share/minecraft/"
    echo ""
else
    echo "Launcher already removed, skipping"
    echo ""
fi
if [ -e /usr/share/icons/minecraft.svg ]; then
    echo "Removing minecraft.svg..."
    sudo rm -rf /usr/share/icons/minecraft.svg
    echo "minecraft.svg removed from /usr/share/icons."
fi
if [ -e /usr/local/bin/minecraft ]; then
    echo "Removing Minecraft launcher binary..."
    sudo rm -rf /usr/local/bin/minecraft
    echo "Minecraft launcher binary removed from /usr/local/bin."
    echo ""
else
    echo "Minecraft launcher binary already removed, skipping"
    echo ""
fi
if [ -e /usr/share/applications/mojang-Minecraft.desktop ]; then
    echo "Removing mojang-Minecraft.desktop"
    xdg-desktop-menu uninstall /usr/share/applications/mojang-Minecraft.desktop
    sudo rm -rf /usr/share/applications/mojang-Minecraft.desktop
    echo "mojang-Minecraft.desktop removed from /usr/share/applications."
    echo ""
else
    echo "mojang-Minecraft.desktop already removed, skipping"
    echo ""
fi
cat <<EOF
Minecraft has been uninstalled from your computer.

All user preferences and save files have not been damaged.
                                               ~alfonsojon
EOF
read -p "Press enter to continue."
Main
}

###
# Begin function Troubleshoot_vanilla
###
function Troubleshoot_vanilla {
clear
cat <<EOF

   Minecraft Troubleshooter
   Select the option that applies to your problem.
1. Black screen
2. Invalid jarfile
3. Minecraft has Crashed! error screen
4. Debug Session (dumps errors to ~/minecraft_debug_log.txt)
EOF
if [ -e ~/minecraft_debug_log.txt ]; then
    echo "5. View Debug Log"
fi
echo "0. Cancel"
echo ""
if [ $BASH == /bin/bash ]; then
    shopt -s nocasematch
fi
read INPUT
case $INPUT in
    1|"Black screen")
        echo 'When the Minecraft launcher opens, click "Options", then "Force Update".'
        echo 'After the Options dialogue closes, click "Login"'
        echo ""
        read -p "Press enter to continue."
        minecraft;;
    2|"Invalid jarfile")
        echo "The Launcher will now be reinstalled."
        read -p "Press enter to continue."
        clear; Install_vanilla;;
    3|"Minecraft has Crashed! error screen")

        echo "Please open Minecraft and determine which error it is."
        echo "1. Bad Video Card Drivers!"
        echo "2. Other error"
        echo "\n0. Cancel"
        read INPUT
        case $INPUT in
            1)
                echo "Opening webpage..."
                xdg-open https://help.ubuntu.com/community/BinaryDriverHowto;;
            2)
                echo 'When the Minecraft launcher opens, click "Options", then "Force Update".'
                echo 'After the Options dialogue closes, click "Login"'
                echo "If this works, you can close Minecraft. If not, open a debug session (from the built-in troubleshooting menu)."
                echo ""
                read -p "Press enter to continue."
                minecraft;;
            0)
                Main;;
            *)
                Troubleshoot_vanilla;;
        esac;;
    4|"Debug Session")
        minecraft|tee ~/minecraft_debug_log.txt
        echo "Would you like to view the debug log?"
        echo "(yes/no)"
        read INPUT
        case $INPUT in
        1|yes|y)
            READFILE=~/minecraft_debug_log.txt
            reader
            less ~/minecraft_debug_log.txt
            Main;;
        2|no|n)
            Main;;
        esac;;
    5|"Debug Log")
        FILE=~/minecraft_debug_log.txt
        reader $FILE
        Troubleshoot_vanilla;;
    0)
        Main;;
    *)
        Troubleshoot_vanilla;;
esac
echo ""
printf "> "
if [ $BASH == /bin/bash ]; then
    shopt -u nocasematch
fi
}

###
# Begin function Install_server
###
Install_server () {
    echo null
}

###
# Fetch functions
###
fetch () {
if command -v wget >/dev/null 2>&1; then
    echo "Downloading ${FILE}..."
    wget --quiet --output-document="$2" "$1"
else
    if command -v curl >/dev/null 2>&1; then
        curl --silent --output "$2" "$1"
    else
        echo "curl/wget not found."
        echo "Please install wget or curl and try again."
        exit 1
    fi
fi
if [ "$?" -ne "0" ]; then
    echo "Download of ${FILE} failed. Returning to the Main Menu."
    sleep 3
    Main
else
    echo "${FILE} downloaded successfully."
fi
}
fetch_sudo () {
if command -v wget >/dev/null 2>&1; then
    echo "Downloading $NAME..."
    sudo wget --quiet --output-document="$2" "$1"
else
    if command -v curl >/dev/null 2>&1; then
        sudo curl --silent --output "$2" "$1"
    else
        echo "curl/wget not found."
        echo "Please install wget or curl and try again."
        exit 1
    fi
fi
if [ "$?" -ne "0" ]; then
    echo "Download of ${NAME} failed. Returning to the Main Menu."
    sleep 3
    Main
else
    echo "${NAME} downloaded successfully."
fi
}

###
# Java checking function
###
javacheck () {
if command -v java >/dev/null 2>&1; then
    echo "Java installed, continuing"
else
    if command -v apt-get >/dev/null 2>&1; then
        sudo apt-get install openjdk-7-jre
    else
        if command -v aptitude >/dev/null 2>&1; then
            sudo aptitude install openjdk-7-jre
        else
            if command -v yum >/dev/null 2>&1; then
                su -c "yum install java-1.7.0-openjdk"
            else
                echo "You are running an unsupported system."
                echo "Please install Java manually, then re-run the installer."
                exit
            fi
        fi
    fi
fi
}

###
# Begin function md5verify
###
md5verify () {
echo "$1  $2" | md5sum -c
if [ "$?" -ne "0" ]; then
    echo "MD5 verification of ${NAME} failed. Please try reinstalling."
    echo "Returning to the Main Menu."
    sleep 3
    echo ""
    Main
else
    echo "MD5 verified."
    echo ""
fi
}

###
# Begin function reader
###
function reader {
    clear
    if [ $2 != "" ]; then
        fetch $1 $2
    fi
    echo "Press Q when finished viewing."
    echo ""
    read -p "Press enter to continue."
    less $FILE
}
###
# Begin function javacheck
###
javacheck () {
if command -v java >/dev/null 2>&1; then
    echo "Java installed, continuing"
else
    if command -v apt-get >/dev/null 2>&1; then
        sudo apt-get install openjdk-7-jre
    else
        if command -v aptitude >/dev/null 2>&1; then
            sudo aptitude install openjdk-7-jre
        else
            if command -v yum >/dev/null 2>&1; then
                su -c "yum install java-1.7.0-openjdk"
            else
                if command -v pacman >/dev/null 2>&2; then
                    pacman -Sg jre7-openjdk
                else
                    echo "You are running an unsupported system."
                    echo "Please install Java manually, then re-run the installer."
                    exit
                fi
            fi
        fi
    fi
fi
}

Main
