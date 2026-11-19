
Shane's Unblocker
Change Log


Version 1.0.0 (2026-07-09)
-------------
Initial release.

Features
--------
- Adds an "Unlock PDFs" option to the Windows Explorer context menu.
- Custom application and context menu icon.
- Recursively scans the selected folder and all subfolders.
- Can scan entire drives when required.
- Warns before scanning folders containing more than 1,000 PDF files.
- Removes the Windows Mark of the Web (Zone.Identifier) from blocked PDF files.
- Unlocks only PDF files that are actually blocked.
- Displays a live scrolling progress log during scanning.
- Displays scan statistics and a completion summary.
- Automatically refreshes File Explorer when the scan is complete.
- Installs for the current user only.
- Does not require Administrator privileges.
- Automatically detects its installation folder during installation.

Version 1.1.0 (2026-07-14)
Features
--------
- Added checkbox to auto close the log page after a sucessful scan.

Version 1.2.0 (2026-11-19)
----------------------------
Features
--------
- Added an "Unlock PDF" Windows Explorer context-menu option for individual PDF files.
- Preserved the existing "Unlock PDFs" recursive folder scan.
- Single-file operations use the existing progress window, scan summary, and optional auto-close behavior.
- Updated the installer and uninstaller to add and remove both context-menu entries.
- Standardized displayed version numbers across the PowerShell script, installer, and uninstaller.
