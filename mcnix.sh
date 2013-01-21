#!/bin/bash
# This script does not distribute any protected Minecraft files. You can't use this to play Minecraft without buying it.
# All of the files downloaded by this script are hosted on www.minecraft.net, so this does not break Minecraft's license.
# Enjoy, alfonsojon (Problems? E-Mail me at alfonsojon1997@gmail.com)

# Trap CTRL-C
trap abort SIGINT

###
# Generic checks
###

# Make sure we're using bash and not some other shell!
if [ "$BASH" != "/bin/bash" ]; then
    echo "Please use bash and try again."
    exit
fi
# Cleanup
function cleanup {
NAME=""
LOCATION=""
URL=""
READFILE=""
MD5=""
}
###
cleanup
###
# Begin function Main
###
function Main {
clear
echo -e "\n   mc-*NIX v1.5 - 1/20/2013"
echo -e "\n   Made by alfonsojon"
echo -e "   E-Mail: alfonsojon1997@gmail.com"
echo -e "   Website: http://www.live-craft.com/"
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
echo -e "\na. Install Minecraft Server"
if [ -e /opt/minecraft_server ] && [ -e /opt/minecraft_server/minecraft_server.jar ]; then
    echo -e "b. Start Minecraft Server"
    echo -e "c. Uninstall Minecraft Server"
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
shopt -u nocasematch
}

###
# Begin function Install_vanilla
###
function Install_vanilla {
clear
javacheck
# Launcher
FILE="/usr/share/minecraft/minecraft.jar"
if [ -e $FILE ]; then
    echo -e "Launcher already installed, upgrading"
    sudo rm -rf $FILE
fi
echo -e "\nDownloading minecraft.jar"
sudo mkdir -p "/usr/share/minecraft"
fetch_sudo "https://s3.amazonaws.com/MinecraftDownload/launcher/minecraft.jar" "$FILE"
md5verify "bb99785000fdb3ebadd61a4a347fa042" "$FILE"
# Icon
FILE="/usr/share/icons/minecraft.svg"
if [ -e /usr/share/icons/minecraft.svg ]; then
    echo -e "minecraft.svg already downloaded, upgrading"
    sudo rm -rf /usr/share/icons/minecraft.svg
fi
echo -e "Downloading minecraft.svg"
fetch_sudo "https://raw.github.com/alfonsojon/mc-NIX/master/minecraft.svg" "$FILE"
md5verify "52fe4c84feb29eecb0129d1c10895ff7" "$FILE"
# /usr/local/bin/minecraft
FILE="/usr/local/bin/minecraft"
if [ -e $FILE ]; then
    echo -e "Minecraft launcher binary already exists, upgrading."
    sudo rm -rf $FILE
fi
sudo touch /usr/local/bin/minecraft
sudo $SHELL -c 'cat <<EOF > /usr/local/bin/minecraft
#!/bin/bash
cd /usr/share/minecraft
echo "bb99785000fdb3ebadd61a4a347fa042  /usr/share/minecraft/minecraft.jar" | md5sum -c
if [ "$?" -ne "0" ]; then
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
    echo -e "Minecraft debug launcher binary already exists, upgrading."
    sudo rm -rf /usr/local/bin/minecraft-debug
fi
sudo touch /usr/local/bin/minecraft-debug
sudo $SHELL -c 'cat <<EOF > /usr/local/bin/minecraft-debug
#!/bin/bash
minecraft | tee ~/minecraft_debug_log.txt && echo "Minecraft logfile stored in \"$HOME\"" &&  zenity --info --text="Minecraft logfile stored in \"$HOME\""
exit 0
EOF'
sudo chmod +x /usr/local/bin/minecraft-debug
echo -e "Minecraft debug launcher binary installed successfully.\n"
# Application launcher (/usr/share/applications/mojang-Minecraft.desktop)
FILE=/usr/share/applications/mojang-Minecraft.desktop
if [ -e $FILE ]; then
    echo -e "Minecraft shortcut already installed, upgrading"
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
Icon=minecraft"
Categories=Game;
Type=Application

[Desktop Action Debug]
Name=Debug Mode
Exec=minecraft-debug
OnlyShowIn=Unity;
EOF'
sudo chmod +x /usr/share/applications/mojang-Minecraft.desktop
echo -e "mojang-Minecraft.desktop written to /usr/share/applications"
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
shopt -s nocasematch
read INPUT
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
# Fetch functions
###
function fetch {
if command -v wget >/dev/null 2>&1; then
    echo "Downloading ${FILE}..."
    wget --quiet --output-document="$2" "$1"
else
    if command -v curl >/dev/null 2>&1; then
        curl --silent --output "$1" "$2"
    else
        echo -e "curl/wget not found."
        echo -e "Please install wget or curl and try again."
        exit 1
    fi
fi
if [ "$?" -ne "0" ]; then
    echo -e "Download of ${FILE} failed. Returning to the Main Menu."
    sleep 3
    Main
else
    echo -e "${FILE} downloaded successfully."
fi
}
function fetch_sudo {
if command -v wget >/dev/null 2>&1; then
    echo "Downloading $NAME..."
    sudo wget --quiet --output-document="$2" "$1"
else
    if command -v curl >/dev/null 2>&1; then
        sudo curl --silent --output "$1" "$2"
    else
        echo -e "curl/wget not found."
        echo -e "Please install wget or curl and try again."
        exit 1
    fi
fi
if [ "$?" -ne "0" ]; then
    echo -e "Download of ${NAME} failed. Returning to the Main Menu."
    sleep 3
    Main
else
    echo -e "${NAME} downloaded successfully."
fi
}

###
# Java checking function
###
function javacheck {
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
function md5verify {
echo "$1  $2" | md5sum -c
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
    if [ $2 != "" ]; then
        fetch $1 $2
    fi
    echo -e "Press Q when finished viewing."
    echo -e ""
    read -p "Press enter to continue."
    less $FILE
}
###
# Begin function javacheck
###
function javacheck {
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
# Begin function abort
###
function abort {
echo -e "\nKeyboard interrupt (CTRL-C), aborting."
echo -e "If you cancelled mid-installation, you may have to reinstall Minecraft."
exit 0
}

Main
