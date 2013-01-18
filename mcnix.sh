#!/bin/bash

# Fully rewritten by alfonsojon :)
# Thank you Alloc for writing the first version and giving me an easy way to install Minecraft on Debian and Ubuntu.
#
# This script does not distribute any protected Minecraft files. You can't use this to play Minecraft without buying it.
# All of the files downloaded by this script are hosted on www.minecraft.net, so this does not break Minecraft's license.
#
# Enjoy, alfonsojon (Problems? E-Mail me at alfonsojon1997@gmail.com)
#
# Last edited on January 17th, 2013

# Begin Script

# Make sure we're using bash and not some other shell!
if [ "$BASH" != "/bin/bash" ]; then
    echo "Please use bash and try again."
    exit
fi

# Trap CTRL-C
trap abort SIGINT

# Debian compatibility checks
if ! which apt-get > /dev/null; then
    echo -e "This system must have aptitude!"
    read -p "Press enter to quit."
fi

# Begin function Main
function Main {
INSTALLED_VANILLA=0
INSTALLED_SPOUTCRAFT=0
INSTALLED_TEKKIT=0
clear
echo -e "\n   mc-*NIX v1.0"
echo -e "     (For Debian-based Systems)"
echo -e "\n   Made by alfonsojon"
echo -e "   E-Mail: alfonsojon1997@gmail.com"
echo -e "   Website: http://www.live-craft.com/"
echo -e "\n                                                                  12/22/2012"
echo -e "\n   Select an option (type the number and hit enter)"
echo -e '   You can also type the name of the entry. To exit, type "exit" or "quit".'
echo -e "\n1. Install Minecraft"
if [ -e /usr/local/bin/minecraft ] && [ -e /usr/share/minecraft/minecraft.jar ]
then
    INSTALLED_VANILLA=1
    echo -e "2. Uninstall Minecraft"
    echo -e "3. Launch Minecraft"
    echo -e "9. Troubleshoot Minecraft"
fi
echo -e "\n0. Release Notes"
echo -e "> \c"
read INPUT
shopt -s nocasematch
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
    9|Troubleshoot)
        if [ $INSTALLED_VANILLA -eq 1 ]; then
            Troubleshoot_vanilla
        else
            Main
        fi;;
    0|"Release Notes")
        wget --quiet --output-document "/tmp/mifu_releasenotes.txt" "https://raw.github.com/alfonsojon/mifu--Minecraft-Installer-for-Ubuntu-/master/RELEASE_NOTES.md
        READFILE=/tmp/mifu_releasenotes.txt"
        reader
        Main;;
    exit|q|quit) clear; exit 0;;
    *) Main;;
esac
shopt -u nocasematch
}

###
# Begin function Install_vanilla
###
function Install_vanilla {
# Java check
clear
echo -e "The installer will now look for Java."

if ! which java > /dev/null; then
    echo -e "Java not installed, installing"
    sudo apt-get install openjdk-7-jre -y
    echo -e "\nJava has been installed."
    clear
else
    echo -e "Java is installed, continuing."
fi
# Launcher
NAME="minecraft.jar"
LOCATION="/usr/share/minecraft"
MD5="bb99785000fdb3ebadd61a4a347fa042"
if [ -e /usr/share/minecraft/launcher.jar ]; then
    echo -e "Invalid launcher found, removing"
    sudo rm -rf /usr/share/minecraft/launcher.jar
fi
if [ -e /usr/share/minecraft/minecraft.jar ]; then
    echo -e "Launcher already installed, upgrading"
    sudo rm -rf /usr/share/minecraft/minecraft.jar
fi
echo -e "\nDownloading minecraft.jar"
sudo mkdir -p "/usr/share/minecraft"
sudo wget --quiet --output-document /usr/share/minecraft/minecraft.jar https://s3.amazonaws.com/MinecraftDownload/launcher/minecraft.jar
dlverify
md5verify
# Icon
NAME="minecraft.svg"
LOCATION="/usr/share/icons"
MD5="52fe4c84feb29eecb0129d1c10895ff7"
if [ -e /usr/share/icons/minecraft.svg ]; then
    echo -e "minecraft.svg already downloaded, upgrading"
    sudo rm -rf /usr/share/icons/minecraft.svg
fi
echo -e "Downloading minecraft.svg"
sudo wget --quiet --output-document "/usr/share/icons/minecraft.svg" "https://raw.github.com/alfonsojon/MIFU--Minecraft-Installer-for-Ubuntu/master/minecraft.svg"
dlverify
md5verify
# /usr/local/bin/minecraft
NAME="minecraft"
LOCATION="/usr/local/bin"
MD5="null"
if [ -e /usr/local/bin/minecraft ]; then
    echo -e "Minecraft launcher binary already exists, upgrading."
    sudo rm -rf /usr/local/bin/minecraft
fi
echo -e "---------------"
echo -e "#!/bin/bash" | sudo tee -a  /usr/local/bin/minecraft
echo -e "cd /usr/share/minecraft" | sudo tee -a /usr/local/bin/minecraft
echo -e "echo \"bb99785000fdb3ebadd61a4a347fa042  /usr/share/minecraft/minecraft.jar\" | md5sum -c" | sudo tee -a /usr/local/bin/minecraft
echo -e "if [ "\$?" -ne "0" ]; then" | sudo tee -a /usr/local/bin/minecraft
echo -e "   zenity --title \"Error\" --error --text='Launcher not installed properly.\nPlease reinstall Minecraft.'" | sudo tee -a /usr/local/bin/minecraft
echo -e "   exit 1" | sudo tee -a /usr/local/bin/minecraft
echo -e "else" | sudo tee -a /usr/local/bin/minecraft
echo -e "   java -jar /usr/share/minecraft/minecraft.jar" | sudo tee -a  /usr/local/bin/minecraft
echo -e "fi" | sudo tee -a /usr/local/bin/minecraft
echo -e "exit 0" | sudo tee -a  /usr/local/bin/minecraft
echo -e "---------------"
echo -e "Minecraft launcher binary installed successfully."
# /usr/local/bin/minecraft-debug
NAME="minecraft-debug"
LOCATION="/usr/local/bin"
MD5="null"
if [ -e /usr/local/bin/minecraft-debug ]; then
    echo -e "Minecraft debug launcher binary already exists, upgrading."
    sudo rm -rf /usr/local/min/minecraft-debug
fi
echo -e "---------------"
echo -e "#!/bin/bash" | sudo tee -a  /usr/local/bin/minecraft-debug
echo -e "minecraft|tee ~/minecraft_debug_log.txt &&  zenity --info --text='Minecraft logfile stored in \"$HOME\"'" | sudo tee -a  /usr/local/bin/minecraft-debug
echo -e "exit 0" | sudo tee -a  /usr/local/bin/minecraft-debug
echo -e "---------------"
sudo chmod +x /usr/local/bin/minecraft
sudo chmod +x /usr/local/bin/minecraft-debug
echo -e "Minecraft debug launcher binary installed successfully."
echo -e ""
# Application icon (/usr/share/applications/mojang-Minecraft.desktop)
if [ -e /usr/share/applications/mojang-Minecraft.desktop ]; then
    echo -e "Minecraft shortcut already installed, upgrading"
    sudo rm -rf /usr/share/applications/mojang-Minecraft.desktop
fi
echo -e "Writing mojang-Minecraft.desktop..."
echo -e "---------------"
echo -e "[Desktop Entry]" | sudo tee -a  /usr/share/applications/mojang-Minecraft.desktop
echo -e "Comment=Play Minecraft" | sudo tee -a  /usr/share/applications/mojang-Minecraft.desktop
echo -e "Name=Minecraft" | sudo tee -a  /usr/share/applications/mojang-Minecraft.desktop
echo -e "TryExec=minecraft" | sudo tee -a  /usr/share/applications/mojang-Minecraft.desktop
echo -e "Exec=minecraft" | sudo tee -a  /usr/share/applications/mojang-Minecraft.desktop
echo -e "Actions=Debug;" | sudo tee -a  /usr/share/applications/mojang-Minecraft.desktop
echo -e "GenericName=Building Game" | sudo tee -a  /usr/share/applications/mojang-Minecraft.desktop
echo -e "Icon=minecraft" | sudo tee -a  /usr/share/applications/mojang-Minecraft.desktop
echo -e "Categories=Game;" | sudo tee -a  /usr/share/applications/mojang-Minecraft.desktop
echo -e "Type=Application" | sudo tee -a  /usr/share/applications/mojang-Minecraft.desktop
echo -e "" | sudo tee -a  /usr/share/applications/mojang-Minecraft.desktop
echo -e "[Desktop Action Debug]" | sudo tee -a  /usr/share/applications/mojang-Minecraft.desktop
echo -e "Name=Debug Mode" | sudo tee -a  /usr/share/applications/mojang-Minecraft.desktop
echo -e "Exec=minecraft-debug" | sudo tee -a  /usr/share/applications/mojang-Minecraft.desktop
echo -e "OnlyShowIn=Unity;" | sudo tee -a  /usr/share/applications/mojang-Minecraft.desktop
echo -e "---------------"
echo -e "mojang-Minecraft.desktop written to /usr/share/applications"
sudo chmod +x /usr/share/applications/mojang-Minecraft.desktop
echo -e "Marked mojang-Minecraft.desktop as executable."
sudo xdg-desktop-menu install /usr/share/applications/mojang-Minecraft.desktop
sudo xdg-desktop-menu forceupdate
echo -e "Registered mojang-Minecraft.desktop in the menu/Launcher."
echo -e ""
echo -e ""
# Finished!
echo -e "Minecraft has been successfully installed!"
read -p "Press enter to continue."
Main
}

###
# Begin function Uninstall_vanilla
###
function Uninstall_vanilla {
if [ -e /usr/share/minecraft/minecraft.jar ]; then
    echo -e "Removing minecraft.jar..."
    sudo rm -rf /usr/share/minecraft/minecraft.jar
    echo -e "Launcher removed from /usr/share/minecraft/"
    echo -e ""
else
    echo -e "Launcher already removed, skipping"
    echo -e ""
fi
if [ -e /usr/share/icons/minecraft.svg ]; then
    echo -e "Removing minecraft.svg..."
    sudo rm -rf /usr/share/icons/minecraft.svg
    echo -e "minecraft.svg removed from /usr/share/icons."
fi
if [ -e /usr/local/bin/minecraft ]; then
    echo -e "Removing Minecraft launcher binary..."
    sudo rm -rf /usr/local/bin/minecraft
    echo -e "Minecraft launcher binary removed from /usr/local/bin."
    echo -e ""
else
    echo -e "Minecraft launcher binary already removed, skipping"
    echo -e ""
fi
if [ -e /usr/share/applications/mojang-Minecraft.desktop ]; then
    echo -e "Removing mojang-Minecraft.desktop"
    xdg-desktop-menu uninstall /usr/share/applications/mojang-Minecraft.desktop
    sudo rm -rf /usr/share/applications/mojang-Minecraft.desktop
    echo -e "mojang-Minecraft.desktop removed from /usr/share/applications."
    echo -e ""
else
    echo -e "mojang-Minecraft.desktop already removed, skipping"
    echo -e ""
fi
echo -e ""
echo -e "Minecraft has been uninstalled from your computer."
echo -e ""
echo -e "All user preferences and save files have not been damaged."
echo -e "                                               ~alfonsojon"
echo -e ""
read -p "Press enter to continue."
echo -e ""
Main
}

###
# Begin function Troubleshoot_vanilla
###
function Troubleshoot_vanilla {
clear
echo -e "\n   Minecraft Troubleshooter"
echo -e "   Select the option that applys to your problem.\n"
echo -e "1. Black screen"
echo -e "2. Invalid jarfile"
echo -e "3. Minecraft has Crashed! error screen"
echo -e "4. Debug Session (dumps errors to ~/minecraft_debug_log.txt)"
if [ -e ~/minecraft_debug_log.txt ]; then
    echo -e "5. View Debug Log"
fi
echo -e "\n0. Cancel"
read INPUT
shopt -s nocasematch
case $INPUT in
    1|"Black screen")
        echo -e 'When the Minecraft launcher opens, click "Options", then "Force Update".'
        echo -e 'After the Options dialogue closes, click "Login"'
        echo -e ""
        read -p "Press enter to continue."
        minecraft;;
    2|"Invalid jarfile")
        echo -e "The Launcher will now be reinstalled."
        read -p "Press enter to continue."
        clear; Install_vanilla;;
    3|"Minecraft has Crashed! error screen")

        echo -e "Please open Minecraft and determine which error it is."
        echo -e "1. Bad Video Card Drivers!"
        echo -e "2. Other error"
        echo -e "\n0. Cancel"
        read INPUT
        case $INPUT in
            1)
                echo -e "Opening webpage..."
                xdg-open https://help.ubuntu.com/community/BinaryDriverHowto;;
            2)
                echo -e 'When the Minecraft launcher opens, click "Options", then "Force Update".'
                echo -e 'After the Options dialogue closes, click "Login"'
                echo -e "If this works, you can close Minecraft. If not, open a debug session (from the built-in troubleshooting menu)."
                echo -e ""
                read -p "Press enter to continue."
                minecraft;;
            0)
                Main;;
            *)
                Troubleshoot_vanilla;;
        esac;;
    4|"Debug Session")
        minecraft|tee ~/minecraft_debug_log.txt
        echo -e "Would you like to view the debug log?"
        echo -e "(yes/no)"
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
        READFILE=~/minecraft_debug_log.txt
        reader
        Troubleshoot_vanilla;;
    0)
        Main;;
    *)
        Troubleshoot_vanilla;;
esac
shopt -u nocasematch
}

###
# Begin function dlverify
###
function dlverify {
if [ "$?" -ne "0" ]; then
    echo -e "Download of ${NAME} failed. Returning to the Main Menu."
    echo -e ""
    Main
else
    echo -e "${NAME} downloaded successfully." 
    echo -e ""
fi
}

###
# Begin function md5verify
###
function md5verify {
echo "$MD5  $LOCATION/$NAME" | md5sum -c
if [ "$?" -ne "0" ]; then
    echo -e "MD5 verification of ${NAME} failed. Please try reinstalling."
    echo -e "Returning to the Main Menu."
    sleep 3
    echo -e ""
    Main
else
    echo -e "MD5 verified."
    echo -e ""
fi
}

###
# Begin function reader
###
function reader {
    clear
    echo -e "Press Q when finished viewing."
    echo -e ""
    read -p "Press enter to continue."
    less $READFILE
}
###
# Begin function abort
###
function abort {
echo -e "\nKeyboard interrupt (CTRL-C), aborting."
echo -e "If you cancelled mid-installation, you may have to reinstall Minecraft."
exit $?
}

Main
