###############################################################################
# Shane's Unblocker
# Version 1.1.0
#
# Removes the Windows Mark of the Web (Zone.Identifier) from blocked PDF files
# so File Explorer can preview them again.
#
# Developed by Shane Aune
# https://www.shaneaune.com/my-projects/Shanes-Unblocker/
###############################################################################

param (
    [string]$FolderPath
)

###############################################################################
# Required .NET assemblies
###############################################################################

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

###############################################################################
# Native Windows API
###############################################################################

# SHChangeNotify tells File Explorer that file metadata has changed. Explorer
# may still refresh on its own schedule, but this usually updates previews
# without requiring the user to close and reopen the folder.
Add-Type @"
using System;
using System.Runtime.InteropServices;

public class ShellRefresh {
    [DllImport("shell32.dll")]
    public static extern void SHChangeNotify(
        uint wEventId,
        uint uFlags,
        IntPtr dwItem1,
        IntPtr dwItem2);
}
"@

###############################################################################
# Application configuration
###############################################################################

$AppName = "Shane's Unblocker"
$Version = "1.0.0"
$Release = "July 2026"
$Website = "https://www.shaneaune.com/my-projects/Shanes-Unblocker/"

# Store the auto-close preference under HKEY_CURRENT_USER so the setting does
# not require administrator privileges and is remembered for the current user.
$SettingsKey = "HKCU:\Software\Shanes-Unblocker"
$AutoCloseSetting = "AutoClose"

###############################################################################
# PDF scan and unblock logic
###############################################################################

function Start-UnblockScan {
    $outputBox.Clear()

    # Stop immediately if the folder passed by the Explorer context menu no
    # longer exists or cannot be accessed.
    if (-not (Test-Path $FolderPath)) {
        $outputBox.AppendText("Folder not found: $FolderPath`r`n")
        $statusLabel.Text = "Error"
        return
    }

    $statusLabel.Text = "Counting PDF files..."
    [System.Windows.Forms.Application]::DoEvents()

    # Build the complete file list once, then reuse it for both the warning and
    # the scan. This avoids recursively enumerating a large folder twice.
    $pdfFiles = @(
        Get-ChildItem `
            -Path $FolderPath `
            -Recurse `
            -File `
            -Filter *.pdf `
            -ErrorAction SilentlyContinue
    )

    $pdfCount = $pdfFiles.Count

    # Large scans can take time, especially on network shares or entire drives.
    # Ask for confirmation only when the workload is likely to be noticeable.
    if ($pdfCount -gt 1000) {
        $confirm = [System.Windows.Forms.MessageBox]::Show(
            "This folder contains $pdfCount PDF files.`n`nThis may take a while to scan.`n`nDo you want to continue?",
            $AppName,
            [System.Windows.Forms.MessageBoxButtons]::YesNo,
            [System.Windows.Forms.MessageBoxIcon]::Warning
        )

        if ($confirm -ne [System.Windows.Forms.DialogResult]::Yes) {
            $statusLabel.Text = "Cancelled"
            $outputBox.AppendText("Scan cancelled by user.`r`n")
            return
        }
    }

    $scanned = 0
    $unblocked = 0
    $alreadyOk = 0
    $errors = 0

    $outputBox.AppendText("========================================`r`n")
    $outputBox.AppendText("$AppName`r`n")
    $outputBox.AppendText("Version $Version`r`n")
    $outputBox.AppendText("========================================`r`n")
    $outputBox.AppendText("`r`n")
    $outputBox.AppendText("Selected Folder:`r`n")
    $outputBox.AppendText("$FolderPath`r`n")
    $outputBox.AppendText("`r`n")
    $outputBox.AppendText("PDF files found: $pdfCount`r`n")
    $outputBox.AppendText("`r`n")

    $pdfFiles | ForEach-Object {
        $scanned++

        # Windows stores the Mark of the Web in the Zone.Identifier alternate
        # data stream. If the stream does not exist, the PDF is already clear.
        $blocked = Get-Item `
            -LiteralPath $_.FullName `
            -Stream Zone.Identifier `
            -ErrorAction SilentlyContinue

        if ($blocked) {
            try {
                Unblock-File -LiteralPath $_.FullName -ErrorAction Stop
                $unblocked++
                $outputBox.AppendText("Unblocked: $($_.FullName)`r`n")
            }
            catch {
                # Keep scanning other files if one PDF cannot be modified.
                $errors++
                $outputBox.AppendText("Error: $($_.FullName)`r`n")
            }
        }
        else {
            $alreadyOk++
        }

        $statusLabel.Text = "Scanned: $scanned    Unblocked: $unblocked    Already OK: $alreadyOk"

        # Keep the most recent activity visible while processing large folders.
        $outputBox.SelectionStart = $outputBox.Text.Length
        $outputBox.ScrollToCaret()

        # Allow the WinForms interface to repaint and remain responsive during
        # the synchronous scan.
        [System.Windows.Forms.Application]::DoEvents()
    }

    $outputBox.AppendText("`r`n")
    $outputBox.AppendText("Completed.`r`n")
    $outputBox.AppendText("`r`n")
    $outputBox.AppendText(("Scanned:    {0,8}" -f $scanned) + "`r`n")
    $outputBox.AppendText(("Unblocked:  {0,8}" -f $unblocked) + "`r`n")
    $outputBox.AppendText(("Already OK: {0,8}" -f $alreadyOk) + "`r`n")

    if ($errors -gt 0) {
        $outputBox.AppendText(("Errors:     {0,8}" -f $errors) + "`r`n")
    }

    $outputBox.AppendText("`r`n")

    try {
        $statusLabel.Text = "Refreshing File Explorer..."
        [System.Windows.Forms.Application]::DoEvents()

        # Send a shell-wide association/metadata refresh notification after all
        # PDFs have been processed. This is one notification per scan, not one
        # notification per file.
        [ShellRefresh]::SHChangeNotify(
            0x08000000,
            0x0000,
            [IntPtr]::Zero,
            [IntPtr]::Zero
        )

        $outputBox.AppendText("File Explorer refreshed.`r`n")
    }
    catch {
        $errors++
        $outputBox.AppendText("Could not refresh File Explorer.`r`n")
    }

    $outputBox.AppendText("`r`n")

    if ($errors -eq 0) {
        $outputBox.AppendText("Scan completed successfully.`r`n")
    }
    else {
        $outputBox.AppendText("Scan completed with one or more errors.`r`n")
    }

    $outputBox.AppendText("`r`n")
    $outputBox.AppendText("Thank you for using Shane's Unblocker!`r`n")
    $outputBox.AppendText("For updates and documentation, visit:`r`n")
    $outputBox.AppendText("shaneaune.com`r`n")

    $statusLabel.Text = "Completed - Scanned: $scanned    Unblocked: $unblocked    Already OK: $alreadyOk"

    # Auto-close only when the option is enabled, at least one PDF was changed,
    # and the scan completed without errors. Otherwise, leave the window open
    # so the user can review the result or error details.
    $successfulAutoClose = (
        $autoCloseCheckBox.Checked -and
        $unblocked -gt 0 -and
        $errors -eq 0
    )

    if ($successfulAutoClose) {
        $statusLabel.Text = "Scan completed successfully - closing automatically..."

        # Use script scope so the timer is not garbage-collected before it fires.
        $script:closeTimer = New-Object System.Windows.Forms.Timer
        $script:closeTimer.Interval = 2000

        $script:closeTimer.Add_Tick({
            $script:closeTimer.Stop()
            $script:closeTimer.Dispose()
            $form.Close()
        })

        $script:closeTimer.Start()
    }
}

###############################################################################
# Main application window
###############################################################################

$form = New-Object System.Windows.Forms.Form
$form.Text = $AppName
$form.Size = New-Object System.Drawing.Size(900, 640)
$form.StartPosition = "CenterScreen"

# Load the custom application icon when present. The program remains usable if
# the icon file is missing or damaged.
try {
    $form.Icon = New-Object System.Drawing.Icon(
        (Join-Path $PSScriptRoot "Shanes-Unblocker.ico")
    )
}
catch {
    # Continue if the icon cannot be loaded.
}

$titleLabel = New-Object System.Windows.Forms.Label
$titleLabel.Text = $AppName
$titleLabel.Location = New-Object System.Drawing.Point(10, 10)
$titleLabel.Size = New-Object System.Drawing.Size(500, 25)
$titleLabel.Font = New-Object System.Drawing.Font(
    "Segoe UI",
    12,
    [System.Drawing.FontStyle]::Bold
)
$form.Controls.Add($titleLabel)

$versionLabel = New-Object System.Windows.Forms.Label
$versionLabel.Text = "v$Version"
$versionLabel.Location = New-Object System.Drawing.Point(740, 15)
$versionLabel.Size = New-Object System.Drawing.Size(110, 20)
$versionLabel.TextAlign = "MiddleRight"
$form.Controls.Add($versionLabel)

$folderLabel = New-Object System.Windows.Forms.Label
$folderLabel.Text = "Selected Folder:`r`n$FolderPath"
$folderLabel.Location = New-Object System.Drawing.Point(10, 45)
$folderLabel.Size = New-Object System.Drawing.Size(860, 45)
$form.Controls.Add($folderLabel)

$outputBox = New-Object System.Windows.Forms.TextBox
$outputBox.Location = New-Object System.Drawing.Point(10, 100)
$outputBox.Size = New-Object System.Drawing.Size(860, 390)
$outputBox.Multiline = $true
$outputBox.ScrollBars = "Vertical"
$outputBox.ReadOnly = $true
$form.Controls.Add($outputBox)

$statusLabel = New-Object System.Windows.Forms.Label
$statusLabel.Location = New-Object System.Drawing.Point(10, 500)
$statusLabel.Size = New-Object System.Drawing.Size(860, 25)
$statusLabel.Text = "Ready"
$form.Controls.Add($statusLabel)

$footerLine = New-Object System.Windows.Forms.Label
$footerLine.BorderStyle = "Fixed3D"
$footerLine.Location = New-Object System.Drawing.Point(10, 535)
$footerLine.Size = New-Object System.Drawing.Size(860, 2)
$form.Controls.Add($footerLine)

$footerLabel = New-Object System.Windows.Forms.Label
$footerLabel.Text = "Developed by Shane Aune"
$footerLabel.Location = New-Object System.Drawing.Point(10, 548)
$footerLabel.Size = New-Object System.Drawing.Size(250, 18)
$form.Controls.Add($footerLabel)

$linkLabel = New-Object System.Windows.Forms.LinkLabel
$linkLabel.Text = "shaneaune.com"
$linkLabel.Location = New-Object System.Drawing.Point(10, 566)
$linkLabel.Size = New-Object System.Drawing.Size(150, 20)

$linkLabel.Add_Click({
    Start-Process $Website
})

$form.Controls.Add($linkLabel)

###############################################################################
# Auto-close preference
###############################################################################

$autoCloseCheckBox = New-Object System.Windows.Forms.CheckBox
$autoCloseCheckBox.Text = "Automatically close after successful scan"
$autoCloseCheckBox.Location = New-Object System.Drawing.Point(170, 565)
$autoCloseCheckBox.Size = New-Object System.Drawing.Size(300, 25)
$autoCloseCheckBox.Checked = $false
$form.Controls.Add($autoCloseCheckBox)

# Load the previously saved setting. Missing settings default to disabled.
try {
    $savedAutoClose = Get-ItemPropertyValue `
        -Path $SettingsKey `
        -Name $AutoCloseSetting `
        -ErrorAction Stop

    $autoCloseCheckBox.Checked = ($savedAutoClose -eq 1)
}
catch {
    $autoCloseCheckBox.Checked = $false
}

# Save changes immediately so the option is remembered for the next scan.
$autoCloseCheckBox.Add_CheckedChanged({
    try {
        if (-not (Test-Path $SettingsKey)) {
            New-Item -Path $SettingsKey -Force | Out-Null
        }

        $value = if ($autoCloseCheckBox.Checked) {
            1
        }
        else {
            0
        }

        New-ItemProperty `
            -Path $SettingsKey `
            -Name $AutoCloseSetting `
            -Value $value `
            -PropertyType DWord `
            -Force | Out-Null
    }
    catch {
        # Continue if the preference cannot be saved.
    }
})

###############################################################################
# Window controls and application launch
###############################################################################

$closeButton = New-Object System.Windows.Forms.Button
$closeButton.Text = "Close"
$closeButton.Location = New-Object System.Drawing.Point(770, 565)
$closeButton.Size = New-Object System.Drawing.Size(100, 30)

$closeButton.Add_Click({
    $form.Close()
})

$form.Controls.Add($closeButton)

# Start scanning automatically after the form is visible so users can see live
# progress without needing a separate Start button.
$form.Add_Shown({
    Start-UnblockScan
})

[void]$form.ShowDialog()
