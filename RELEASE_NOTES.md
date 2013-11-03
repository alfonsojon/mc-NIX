Release notes


0.1 - March 19th, 2012
-
- Added if-statements
- DOES NOT WORK :(

0.2a - March 31st, 2012
-
- First fully functional release
- Loosely based upon Alloc's installer script

0.3a - June 26th, 2012
-
- Fixed icon not showing up in Ubuntu's Unity and Elementary OS' Slingshot

0.4a - June 29th, 2012
-
- Better looking icon! (Thanks so much to ~master-of-design - http://master-of-design.deviantart.com/)
- Updated Livecraft's URL from http://www.live-craft.com to http://mc.live-craft.com/
- Install JRE6 instead of JRE7 for now due to blackscreens and Xorg errors upon quitting the game. To fix this, update LWJGL
- Began writing server install sections
- Begin implementing Verify function

0.5.0 - November 12th, 2012
-
- Going back to JRE7 since Minecraft 1.4 includes a newer LWJGL build
- Fix Verify function
- Implement Server functions
- Tidy up comments
- Clean up splashes

0.6 - December 15th, 2012
-
- Add MD5 verification of downloads to Verify function
- Tidying up some more

1.0.0 - December 22nd, 2012
-
** THE MASSIVE UPDATE **

- Separated Release Notes from shell script
- Separate the Server installer from the Client installer
- Use case for menu instead of if-then statements
- Added a debugging console (part of troubleshooter)
- Added a log viewer (part of troubleshooter)
- Added a Troubleshooter
- Trap keyboard interrupts (CTRL-C)
- Add an abort function (called by keyboard interrupts)
- Get ready for Spoutcraft/Tekkit installers! (Not added yet)
- Changed URL back to www.live-craft.com for simplistic reasons
- Added Open in Terminal quicklist item (for Unity)

1.1.0 - December 23rd, 2012
-
- Alert the user if the launcher is corrupted (Error dialogue)
- Removed the debug console in favor of a Debug mode - accessible via the Unity quicklist or via the command "minecraft-debug"

1.5.0 - January 20th, 2013
-
** THE MASSIVE UPDATE #2 **

- Rebranded to mc-NIX
- Plans to port to UNIX-based operating systems are in
- Added requirement for BASH (No more sh, zsh, etc)
- Organize the menus
- Start to work on a server installer (finally!), will be integrated.
- Added a cleanup function to remove defunct files and locations (for upgrades)
- Added a fetcher function to download the files
- Added a Vanilla Minecraft Server installer: For both GUI and servers
- Added Fedora support
- Use cat instead of a ton of tee

1.5.1 - January 21st, 2013
-
- Now compatible with most shells (bash, sh, dash, ksh, tcsh, csh, others)
- Now BSD compliant, but you must have a desktop environment installed.
- Even more cat, even less echo
- Made the troubleshoot UI match the menu

1.5.2 - January 28th, 2013
-
- Fixed MD5 verification of the launcher

2.0.0 - June 2nd, 2013
-
- Added server installation option (Vanilla, Bukkit, & Spigot)
- Redesigned menus
- Unified menu items
- Made more UNIX-compliant
- Added jar sanity check rather than overusing MD5 verifications
- Removed the now-useless MD5 verifications
- Improved Unity integration
- Added GPL v2 & improved licensing
- Use more if-elif-else instead of nesting if-then-else over and over
- Remove redundant messages
- Use cat even more where echo was used

2.1.0 - June 3rd, 2013
-
- Fixed typos
- Removed release notes (pointless, viewable online)
- Added OS compatibility check
- Corrected server installation menu option
- Fixed desktop icon

2.1.1 - June 11th, 2013
-
- Use /usr/sbin instead of /usr/local/bin
- Added support for Chrome OS (if Java is already installed)

2.1.2 - June 12th, 2013
-
- Revert "Use /usr/sbin instead of /usr/local/bin"

2.2 - July 8th, 2013
-
- Update the launcher to the new version
- All functions should be lowercase

2.3 - November 2nd, 2013
-
- Optimized for the new Minecraft launcher
- Updated icon and credits
- Automatically set proper terminal resolution
- Renamed client installer to install_client.sh to avoid confusion
- Removed redundant debug log generator as the new launcher takes care of that
- Removed troubleshooting section as the new launcher is rather smart.
- Vastly improved server configuration and uninstallation
