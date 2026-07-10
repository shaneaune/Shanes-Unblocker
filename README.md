==================================================
Shane's Unblocker
Version 1.0.0
https://www.shaneaune.com/my-projects/Shanes-Unblocker/
==================================================

Microsoft introduced a security update for Windows 10 and Windows 11 that prevents File Explorer from previewing many PDF files downloaded from the Internet. Trying to preview a PDF shows a "The file you are attempting to preview could harm your computer. If you trust the file and the source you received it from, open it to view its contents" in the preview pane. While PowerShell provides the Unblock-File command, many Windows users are unfamiliar with PowerShell or need to unlock hundreds or even thousands of PDF files at once.

Shane's Unblocker provides a simple right-click solution that removes the Windows "Mark of the Web" from blocked PDF files, restoring PDF previews in Windows Explorer without requiring PowerShell knowledge.


Installation
------------
1. Unzip the file and copy the Shanes-Unblocker folder to a permanent location on your computer.

   Recommended:
   C:\Shanes-Unblocker

   You may also place it in another permanent location, such as
   C:\Program Files\Shanes-Unblocker, provided you have permission to do so.

2. Do not move or rename the folder after installation.
   If you do, simply run Uninstall.bat, move the folder, then run Install.bat again.

3. Double-click Install.bat. ( Windows 10 - select "More info" followed by "Run anyway" to continue the installation)

4. Right-click any folder containing PDF files.

5. Windows 11 - Select Show more options (not necessary in Windows 10) 

6. Select "Unlock PDFs" and the program will run and show you the status. 

Note
----
After unlocking PDFs, File Explorer may not refresh the preview pane immediately.
If the security message still appears, click another file, press F5, or close and reopen the folder.

Features
--------
• Adds an "Unlock PDFs" option to the Windows Explorer context menu.
• Recursively scans the selected folder and all subfolders.
• Can scan an entire drive if desired (large drives may take longer).
• Unlocks only PDF files that are actually blocked.
• Displays live progress during the scan.
• Displays a summary when the scan is complete.
• Automatically refreshes File Explorer when finished.
• Installs for the current user only.
• No administrator privileges required.

Uninstall
---------
Run Uninstall-RightClick.bat.

Security
--------
Shane's Unblocker is an open-source PowerShell utility.

Because it is not digitally signed, Windows Defender SmartScreen may display a warning the first time it is run.

If you downloaded Shane's Unblocker from the official GitHub repository or shaneaune.com, select "More info" followed by "Run anyway" to continue the installation.

Source Code
-----------
The complete source code is included and may be reviewed before installation.

Support
-------
For updates, documentation and the latest version, visit:

https://www.shaneaune.com/my-projects/Shanes-Unblocker/

Developed by
------------
Shane Aune
shaneaune.com