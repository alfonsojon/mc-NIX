#!/usr/bin/env python
# This script does not distribute any protected Minecraft files. You can't use this to play Minecraft without buying it.
# All of the files downloaded by this script are hosted on www.minecraft.net, so this does not break Minecraft's license.
# Enjoy, alfonsojon (Problems? E-Mail me at alfonsojon1997@gmail.com)

# Imports
import os, signal, sys
from os import path, access, R_OK

# Functions
# File existance check
def file_exists(FILE):
	if path.exists(FILE) and path.isfile(FILE) and access(FILE, R_OK):
		print PATH,'exists.'
		file_exists = True
		pass
	else:
		print PATH,'not found.'

# Clearscreen function
def clearscreen():
	try:
		if os.name == "nt":
			os.system('cls')
		elif os.name == "os2":
			os.system('cls')
		else:
			os.system('clear')
	except IOError:
		pass

# Begin function Main
def Main():
	clearscreen()
	print '''
   mc-*NIX Python v0.01a - 1/26/2013

   Made by alfonsojon
   E-Mail: alfonsojon1997@gmail.com
   Website: http://www.live-craft.com/

   Select an option (type the number and hit enter)
   You can also type the name of the entry. To exit, type "exit" or "quit".

1. Install Minecraft
2. Uninstall Minecraft
3. Launch Minecraft
9. Troubleshoot Minecraft

a. Install Minecraft Server
0. Release Notes
'''
	raw_input('> ')
Main()
