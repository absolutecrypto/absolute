
Debian
====================
This directory contains files used to package absoluted/absolute-qt
for Debian-based Linux systems. If you compile absoluted/absolute-qt yourself, there are some useful files here.

## absolute: URI support ##


absolute-qt.desktop  (Gnome / Open Desktop)
To install:

	sudo desktop-file-install absolute-qt.desktop
	sudo update-desktop-database

If you build yourself, you will either need to modify the paths in
the .desktop file or copy or symlink your absolute-qt binary to `/usr/bin`
and the `../../share/pixmaps/absolute128.png` to `/usr/share/pixmaps`

absolute-qt.protocol (KDE)

