Automatically connect to calibre server using USBNet
====================================================

This plugin starts calibre connection using USBNet

Prequisite
----------

USBNet between kindle and computer should be correctly configured. Example
udev rules for automatic configuration are in conntrib folder.

Purpose
-------

This package is for paranoid users, who don't want to enable WiFi for file
transfer. If you are using WiFi to transfer files, it's uselesss for you.

Install
-------

Upload ``calibre_usb_autoconnect.koplugin`` to ``koreader/plugins``

Restart KOReader.

Setup
-----

Go to calibre share menu, click on Start wireless device connection and set
static port.

Go to koreader settings / calibre / wireless settings / server address and set
static address of computer on which runs calibre and port configured on calibre.

Then set indbox folder. Now you can connect USB cable.

![Calibre connect start](https://raw.github.com/wiki/mireq/KOReader-usbnet-connect-to-calibre/calibre.png?v=2023-04-04)
![Calibre connect start](https://raw.github.com/wiki/mireq/KOReader-usbnet-connect-to-calibre/calibre_2.png?v=2023-04-04)
![Koreader settings](https://raw.github.com/wiki/mireq/KOReader-usbnet-connect-to-calibre/koreader.png?v=2023-04-04)

Windows
-------

To install windows drivers follow [this link](https://www.mobileread.com/forums/showthread.php?p=3283986).

Video
-----

[![Calibre connected to KOReader using USBNet](https://img.youtube.com/vi/qPahONVbgzo/maxresdefault.jpg)](http://www.youtube.com/watch?v=qPahONVbgzo "Calibre connected to KOReader using USBNet")

