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
# Fetch functions
###
fetch () {
echo "Downloading ${FILE}..."
if command -v wget >/dev/null 2>&1; then
	wget -q --output-document="$2" "$1"
elif command -v curl >/dev/null 2>&1; then
	curl --silent --output "$2" "$1"
else
	echo "curl/wget not found."
	echo "Please install wget or curl and try again."
	exit 1
fi
if [[ "$?" -ne "0" ]]; then
	echo "Download of ${FILE} failed. Returning to the Main Menu."
	sleep 3
	Main error
else
	echo "${FILE} downloaded successfully."
fi
}
fetch_sudo () {
echo "Downloading ${FILE} as root..."
if command -v wget >/dev/null 2>&1; then
	sudo wget -q --output-document="$2" "$1"
elif command -v curl >/dev/null 2>&1; then
	sudo curl --silent --output "$2" "$1"
else
	echo "curl/wget not found."
	echo "Please install wget or curl and try again."
	exit 1
fi
if [[ "$?" -ne "0" ]]; then
	echo "Download of ${FILE} failed. Returning to the Main Menu."
	sleep 3
	Main error
else
	echo "${FILE} downloaded successfully."
fi
}

###
# Begin function reader
###
reader () {
	clear
	if [[ -e $FILE ]]; then
		rm -rf $FILE
	fi
	if [[ $2 != "" ]]; then
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
elif command -v apt-get >/dev/null 2>&1; then
	sudo apt-get install openjdk-7-jre
elif command -v aptitude >/dev/null 2>&1; then
	sudo aptitude install openjdk-7-jre
elif command -v yum >/dev/null 2>&1; then
	su -c "yum install java-1.7.0-openjdk"
elif command -v pacman >/dev/null 2>&2; then
	pacman -Sg jre7-openjdk
else
	echo "You are running an unsupported system."
	echo "Please install Java manually, then re-run the installer."
	exit
fi
}

###
# Legal Info
###
clear
cat <<EOF

   Copyright 2013 Jonathan Alfonso <alfonsojon1997@gmail.com>
   
   This program is free software; you can redistribute it and/or modify it
   under the terms of the GNU General Public License as published by the Free
   Software Foundation; either version 2 of the License, or (at your option)
   any later version.
   
   This program is distributed in the hope that it will be useful, but WITHOUT
   ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
   FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
   more details.
 
   You should have received a copy of the GNU General Public License along
   with this program; if not, write to the Free Software Foundation, Inc., 51
   Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA.

   This script does not distribute any protected Minecraft files. You cannot
   use mc-*NIX to play Minecraft without buying it! All of the files
   downloaded by mc-*NIX are provided and hosted by Mojang freely.

EOF
read -p "   Press enter to continue."

###
# Begin function Install_vanilla
###
Install_vanilla () {
clear
cat <<EOF
####################################
#  Installing Minecraft...
####################################

EOF
javacheck
# Launcher
FILE="/usr/share/minecraft/minecraft.jar"
if [[ -e $FILE ]]; then
	sudo rm -rf $FILE
fi
sudo mkdir -p "/usr/share/minecraft"
fetch_sudo "https://s3.amazonaws.com/MinecraftDownload/launcher/minecraft.jar" "$FILE"
# Icon
FILE="/usr/share/icons/minecraft.svg"
OLDFILE="/usr/share/pixmaps/minecraft.svg"
if [[ -e $FILE ]]; then
	sudo rm -rf $FILE
fi
sudo rm -rf $OLDFILE
fetch_sudo "https://raw.github.com/alfonsojon/mc-NIX/master/minecraft.svg" "$FILE"
# /usr/local/bin/minecraft
FILE="/usr/local/bin/minecraft"
if [[ -e $FILE ]]; then
	sudo rm -rf $FILE
fi
sudo touch /usr/local/bin/minecraft
sudo bash -c 'cat <<EOF > /usr/local/bin/minecraft
#!/bin/bash
cd /usr/share/minecraft
java -jar /usr/share/minecraft/minecraft.jar
if [[ "\$?" -ne "0" ]]; then
	echo "Launcher closed unsuccessfully."
	zenity --title \"Error\" --error --text="Launcher closed unsuccessfully."
	exit 1
fi
exit 0
EOF'
sudo chmod +x /usr/local/bin/minecraft
# /usr/local/bin/minecraft-debug
FILE="/usr/local/bin/minecraft-debug"
if [[ -e $FILE ]]; then
	sudo rm -rf /usr/local/bin/minecraft-debug
fi
sudo touch /usr/local/bin/minecraft-debug
sudo $SHELL -c 'cat <<EOF > /usr/local/bin/minecraft-debug
#!/bin/bash
minecraft | tee $HOME/minecraft_debug_log.txt && echo "Minecraft logfile stored in \"$HOME\"" &&  zenity --info --text="Minecraft logfile stored in \"$HOME\""
exit 0
EOF'
sudo chmod +x /usr/local/bin/minecraft-debug
# Application launcher (/usr/share/applications/mojang-Minecraft.desktop)
FILE=/usr/share/applications/mojang-Minecraft.desktop
if [[ -e $FILE ]]; then
	sudo rm -rf /usr/share/applications/mojang-Minecraft.desktop
fi
sudo touch /usr/share/applications/mojang-Minecraft.desktop
sudo $SHELL -c 'cat <<EOF > /usr/share/applications/mojang-Minecraft.desktop
[[Desktop Entry]]
Comment=Play Minecraft
Name=Minecraft
TryExec=minecraft
Exec=minecraft
Actions=Debug;Wiki;
GenericName=Building Game
Icon=minecraft
Categories=Game;
Type=Application

[[Desktop Action Debug]]
Name=Debug Mode
Exec=minecraft-debug

[[Desktop Action Wiki]]
Name=Minecraft Wiki
Exec=xdg-open http://www.minecraftwiki.net/
EOF'
sudo chmod +x /usr/share/applications/mojang-Minecraft.desktop
sudo xdg-desktop-menu install /usr/share/applications/mojang-Minecraft.desktop
sudo xdg-desktop-menu forceupdate
# Finished!
clear
cat <<EOF
####################################
#  Installation Complete
####################################

   Minecraft has been successfully installed.

   To launch Minecraft, go to your applications launcher and find Minecraft.
   
   Unity/GNOME Shell/Cinnamon:
	- Listed under Applications
	- Start a debug session by right-clicking the icon and click on
	  "Debug Mode". This will log to ~/minecraft_debug_log.txt
   GNOME 2.x/XFCE/LXDE:
	- Listed under Applications\Games
   Command Line:
	- Run "minecraft" from the command line.
	- Run "minecraft-debug" to start a debug session. This will log to
	  ~/minecraft_debug_log.txt

								~alfonsojon
EOF
read -p "Press enter to continue."
Main
}

###
# Begin function Uninstall_vanilla
###
Uninstall_vanilla () {
clear
cat <<EOF
####################################
#  Uninstall Minecraft
####################################

   You are about to uninstall Minecraft.

   Would you like to clear out minecraft.jar? This will uninstall any mods,
   but your worlds, screenshots, and texture packs will not be affected.

   [ Yes | No | Cancel (q) ]

EOF
printf "> "
read INPUT
case $INPUT in
	y|Y|yes|Yes|YES)
		echo "Removing Minecraft application data."
		rm -rf $HOME/.minecraft/bin
		rm -rf $HOME/.minecraft/crash-reports
		rm -rf $HOME/.minecraft/resources
		rm -rf $HOME/.minecraft/texturepacks-mp-cache
		rm -rf $HOME/.minecraft/debug.stitched*
		rm -rf $HOME/.minecraft/lastlogin
		rm -rf $HOME/.minecraft/options.txt
		rm -rf $HOME/.minecraft/mods
		rm -rf $HOME/.minecraft/output-client.log
		if [[ -e /usr/share/minecraft/minecraft.jar ]]; then
			sudo rm -rf /usr/share/minecraft/minecraft.jar
		fi
		if [[ -e /usr/share/icons/minecraft.svg ]]; then
			sudo rm -rf /usr/share/icons/minecraft.svg
		fi
		if [[ -e /usr/local/bin/minecraft ]]; then
			sudo rm -rf /usr/local/bin/minecraft
		fi
		if [[ -e /usr/share/applications/mojang-Minecraft.desktop ]]; then
			xdg-desktop-menu uninstall /usr/share/applications/mojang-Minecraft.desktop
			sudo rm -rf /usr/share/applications/mojang-Minecraft.desktop
		fi;;
	n|N|no|No|NO)
		if [[ -e /usr/share/minecraft/minecraft.jar ]]; then
			sudo rm -rf /usr/share/minecraft/minecraft.jar
		fi
		if [[ -e /usr/share/icons/minecraft.svg ]]; then
			sudo rm -rf /usr/share/icons/minecraft.svg
		fi
		if [[ -e /usr/local/bin/minecraft ]]; then
			sudo rm -rf /usr/local/bin/minecraft
		fi
		if [[ -e /usr/share/applications/mojang-Minecraft.desktop ]]; then
			xdg-desktop-menu uninstall /usr/share/applications/mojang-Minecraft.desktop
			sudo rm -rf /usr/share/applications/mojang-Minecraft.desktop
		fi;;
	q|Q|quit|Quit|QUIT|cancel|Cancel|CANCEL)
		Main;;
esac
clear
cat <<EOF
####################################
#  Uninstall Complete
####################################

Minecraft has been uninstalled from your computer.

All user preferences and save files have not been damaged.
								~alfonsojon
EOF
read -p "Press enter to continue."
Main
}
###
# Begin function Install_server
###
select_server () {
clear
cat <<EOF
####################################
#  Please select which type of server you would like.
####################################

1. Vanilla
   Vanilla is the "Default" Minecraft server. It provides no extra commands and
   is very limited. 
   ** If you don't know what you're doing, install Vanilla!
2. Bukkit
   Bukkit is a modification of Vanilla, but with support for plugins which allow
   you to add functionality to the server. When used by itself, it is nearly
   identical to Vanilla.
3. Spigot
   Spigot is based upon Bukkit, but adds many performance increases and a few
   other features. This is faster than Bukkit, but it may not be as stable as
   Bukkit. Most Bukkit plugins work with Spigot.

EOF
printf "> "
read INPUT
case $INPUT in
	1|"Vanilla"|"vanilla"|"VANILLA")
		Install_server vanilla; return;;
	2|"Bukkit"|"bukkit"|"BUKKIT")
		Install_server bukkit; return;;
	3|"Spigot"|"spigot"|"SPIGOT")
		Install_server spigot; return;;
esac
}
Install_server () {
clear
cat <<EOF
####################################
#  Installing Minecraft Server...
####################################

EOF
if [[ $1 == vanilla ]]; then
	NAME=minecraft_server.jar
	DIRECTORY=/opt/minecraft_server/vanilla
	FILE=/opt/minecraft_server/vanilla/minecraft_server.jar
	URL=https://s3.amazonaws.com/MinecraftDownload/launcher/minecraft_server.jar
	if [[ -e $FILE ]]; then
		echo "Upgrading $NAME."
		sudo rm -rf $FILE
	fi
	sudo mkdir -p $DIRECTORY
	fetch_sudo $URL $FILE
	sudo chmod +x $FILE
elif [[ $1 == bukkit ]]; then
	NAME=craftbukkit.jar
	DIRECTORY=/opt/minecraft_server/craftbukkit/
	FILE=/opt/minecraft_server/craftbukkit/craftbukkit.jar
	URL=http://dl.bukkit.org/downloads/craftbukkit/get/latest-beta/craftbukkit.jar
	if [[ -e $FILE ]]; then
		echo "Upgrading $NAME."
		sudo rm -rf $FILE
	fi
	sudo mkdir -p $DIRECTORY
	fetch_sudo $URL $FILE
	sudo chmod +x $FILE
elif [[ $1 == spigot ]]; then
	NAME=spigot.jar
	DIRECTORY=/opt/minecraft_server/spigot/
	FILE=/opt/minecraft_server/spigot/spigot.jar
	URL=http://ci.md-5.net/job/Spigot/lastStableBuild/artifact/Spigot-Server/target/spigot.jar
	if [[ -e $FILE ]]; then
		echo "Upgrading $NAME."
		sudo rm -rf $FILE
	fi
	sudo mkdir -p $DIRECTORY
	fetch_sudo $URL $FILE
	sudo chmod +x $FILE
else
	Main
fi
sudo touch /usr/local/bin/minecraft-server
sudo $SHELL -c 'cat <<EOF > /usr/local/bin/minecraft-server
#!/bin/bash
cd '${DIRECTORY}'

if [ "\$(id -u)" != "0" ]; then
   echo "The Minecraft server must be run as root." 1>&2
   exit 1
fi

fetch_sudo () {
echo "Downloading '$NAME' as root..."
if command -v wget >/dev/null 2>&1; then
	sudo wget -nv --output-document="\$2" "\$1"
elif command -v curl >/dev/null 2>&1; then
	sudo curl --silent --output "\$2" "\$1"
else
	echo "curl/wget not found."
	echo "Please install wget or curl and try again."
	exit 1
fi
if [[ "\$?" -ne "0" ]]; then
	echo "Download of '${NAME}' failed."
	return
else
	echo "'${NAME}' updated successfully."
fi
}

case "\$1" in
	"fixlock")
		echo "Removing invalid lockfile."
		sudo rm -rf ./server.lock;;
	"start")
		if [[ -e ./server.lock ]]; then
			echo "Server already running."
		else
			cd '${DIRECTORY}'
			sudo touch ./server.lock
			sudo java -jar '${FILE}' nogui
			if [[ \$? != 0 ]]; then
				echo "Server closed improperly."
			else
				clear
				echo "Server closed successfully."
			fi
			sudo rm -rf ./server.lock
		fi;;
	"update")
		if [[ -e ./server.lock ]]; then
			echo "Server running. Update cancelled."
		else
			echo Updating '$NAME'...
			fetch_sudo '$URL' '$FILE'
		fi;;
	*|"help")
		echo "Usage: minecraft-server [fixlock|start|update|help]"
		echo ""
		echo "  fixlock: This will remove any invalid lock files. Beware, this can remove the"
		echo "	  lock on a running server."
		echo ""
		echo "  start:  This will start the server."
		echo ""
		echo "  update: This will update the server to the latest stable build available."
		echo ""
		echo "  help:   Shows this message";;
esac		
EOF'
sudo chmod +x /usr/local/bin/minecraft-server
# Finished!
clear
cat <<EOF
####################################
#  Installation Complete
####################################

   Minecraft Server has been successfully installed.

   Information on running the server

   - Open a terminal session on the computer with the server installed
   - Enter the following command:
	"minecraft-server start"
   - For additional help, enter the following command:
	"minecraft-server help"
   - To update the Minecraft server, enter the following command:
	"minecraft-server update"
   - To remove an invalid lock file, enter the following command:
	"minecraft-server fixlock"
	
								~alfonsojon
EOF
read -p "Press enter to continue."
Main
}

###
# Begin function Uninstall_server
###
Uninstall_server () {
clear
cat <<EOF
####################################
#  Uninstall Minecraft Server
####################################

   You are about to uninstall your Minecraft server.

   Would you like to keep the server data for future use? The server files will
   be moved to your home folder.

   ** IF YOU CHOOSE TO DELETE THE SERVER DATA, IT WILL BE UNRECOVERABLE!

   [ Yes | No | Cancel (q) ]

EOF
printf "> "
read INPUT
case $INPUT in
	y|Y|yes|Yes|YES)
		echo "Moving data to '$HOME'. This may take a few moments."
		sudo cp -r /opt/minecraft_server/* $HOME
		sudo chown -hR `echo "$(id -u -n)"`:`echo "$(id -u -n)"`
		echo "Data moved to '$HOME'."
		sudo rm -rf /opt/minecraft_server
		sudo rm -rf /usr/local/bin/minecraft-server
		echo "Server files removed."
		read -p "Press enter to continue."
		Main;;
	n|N|no|No|NO)
		clear
		echo "####################################"
		echo "# CAUTION - THIS IS NOT REVERSABLE"
		echo "####################################"
		echo ""
		echo "   Are you sure you would like to delete ALL server files?"
		echo "   [ Yes | No ]"
		echo ""
		printf "> "
		read INPUT
		case $INPUT in
			y|Y|yes|Yes|YES)
				sudo rm -rf /opt/minecraft_server
				sudo rm -rf /usr/local/bin/minecraft-server
				echo "Server files removed."
				read -p "Press enter to continue."
				Main;;
			n|N|no|No|NO|q|Q|quit|Quit|QUIT|cancel|Cancel|CANCEL)
				echo "Returning to the main menu."
				sleep 1
				Main;;
		esac;;
	q|Q|quit|Quit|QUIT|cancel|Cancel|CANCEL)
		echo "Returning to the main menu."
		sleep 1
		Main;;
esac
}
###
# Begin function Troubleshoot_vanilla
###
Troubleshoot_vanilla () {
clear
cat <<EOF
####################################
#  Minecraft Troubleshooter
####################################

   Select the option that applies to your problem.

   1. Black screen
   2. Invalid jarfile
   3. Minecraft has Crashed! error screen
   4. Debug Session (dumps errors to ~/minecraft_debug_log.txt)
EOF
if [[ -e ~/minecraft_debug_log.txt ]]; then
cat <<EOF
   5. View Debug Log
EOF
fi
cat <<EOF

   0. Cancel

EOF
printf "> "
read INPUT
case $INPUT in
	1)
		cat <<EOF

   When the Minecraft launcher opens, click "Options", then "Force Update".
   After the Options dialogue closes, click "Login"

EOF
		read -p "Press enter to continue."
		minecraft;;
	2)
		echo "The Launcher will now be reinstalled."
		read -p "Press enter to continue."
		clear; Install_vanilla;;
	3)
		cat <<EOF
   Please open Minecraft and determine which error it is."
   1. Bad Video Card Drivers!"
   2. Other error"

   0. Cancel
EOF
		read INPUT
		case $INPUT in
			1)
				echo "Opening webpage..."
				xdg-open https://help.ubuntu.com/community/BinaryDriverHowto;;
			2)
				cat <<EOF
####################################
# Minecraft Troubleshooter
####################################

   When the Minecraft launcher opens, click "Options", then "Force Update".
   After the Options dialogue closes, click "Login"
   If this works, you can close Minecraft. If not, open a debug session (from the built-in troubleshooting menu).

EOF
				read -p "Press enter to continue."
				minecraft;;
			0)
				Main;;
			q|Q|quit|Quit|QUIT|cancel|Cancel|CANCEL)
				echo "Returning to the main menu."
				sleep 1
				Main;;
			*)
				Troubleshoot_vanilla;;
		esac;;
	4)
		minecraft|tee ~/minecraft_debug_log.txt
		cat <<EOF
####################################
# Minecraft Troubleshooter
####################################

   Would you like to view the debug log?
   [ Yes | No ]

EOF
		printf "> "
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
	5)
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
}

###
# Begin function Main
###
Main () {
clear
if [[ $1 = error ]]; then
cat <<EOF
####################################
#  mc-*NIX v2.0 *PREVIEW* - 6/2/2013
####################################
      > Installation failed <

EOF
else
cat <<EOF
####################################
#  mc-*NIX v2.0 *PREVIEW* - 6/2/2013
####################################

EOF
fi
cat <<EOF
   Made by alfonsojon
   E-Mail: alfonsojon1997@gmail.com
   Website: http://www.live-craft.com/

   Select an option (type the number and hit enter)
   You can also type the name of the entry. To exit, type "exit" or "quit".

   1. Install Minecraft
EOF
if [[ -e /usr/local/bin/minecraft ]] && [[ -e /usr/share/minecraft/minecraft.jar ]]
then
INSTALLED_VANILLA=1
cat <<EOF
   2. Uninstall Minecraft
   3. Launch Minecraft
   9. Troubleshoot Minecraft

   a. Install Minecraft Server
EOF
fi
if [[ -e /opt/minecraft_server ]]; then
	INSTALLED_SERVER=1
cat <<EOF
   b. Uninstall Minecraft Server
   c. Launch Minecraft Server
EOF
fi
echo "   0. Release Notes"
echo ""
printf "> "
read INPUT
case $INPUT in
	1)
		Install_vanilla; Main; return;;
	2)
		if [[ $INSTALLED_VANILLA -eq 1 ]]; then
			Uninstall_vanilla; Main; return;
		else
			Main
		fi;;
	3)
		if [[ $INSTALLED_VANILLA -eq 1 ]]; then
			minecraft
		else
			Main	
		fi;;

	9)
		if [[ $INSTALLED_VANILLA -eq 1 ]]; then
			Troubleshoot_vanilla
		else
			Main
		fi;;
	a)
		select_server; Main; return;;
	b)
		if [[ $INSTALLED_SERVER -eq 1 ]]; then
			Uninstall_server
		else
			Main
		fi;;
	c)
		if [[ $INSTALLED_SERVER -eq 1 ]]; then
			sudo minecraft-server start
		else
			Main
		fi;;
	0)
		FILE="/tmp/mcnix_notes.txt"
		reader "https://raw.github.com/alfonsojon/mc-NIX/master/RELEASE_NOTES.md" $FILE
		Main;;
	q|Q|quit|Quit|QUIT|cancel|Cancel|CANCEL) clear; exit 0;;
	*) Main;;
esac
}

Main
