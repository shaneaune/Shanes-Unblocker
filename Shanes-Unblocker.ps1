param (
    [string]$FolderPath
)

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

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

$AppName = "Shane's Unblocker"
$Version = "1.0.0"
$Release = "July 2026"
$Website = "https://www.shaneaune.com/my-projects/Shanes-Unblocker/"

function Start-UnblockScan {
    $outputBox.Clear()

    if (-not (Test-Path $FolderPath)) {
        $outputBox.AppendText("Folder not found: $FolderPath`r`n")
        $statusLabel.Text = "Error"
        return
    }

    $statusLabel.Text = "Counting PDF files..."
    [System.Windows.Forms.Application]::DoEvents()

    $pdfFiles = @(Get-ChildItem $FolderPath -Recurse -File -Filter *.pdf -ErrorAction SilentlyContinue)
    $pdfCount = $pdfFiles.Count

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

        $blocked = Get-Item $_.FullName -Stream Zone.Identifier -ErrorAction SilentlyContinue

        if ($blocked) {
            Unblock-File -Path $_.FullName
            $unblocked++
            $outputBox.AppendText("Unblocked: $($_.FullName)`r`n")
        }
        else {
            $alreadyOk++
        }

        $statusLabel.Text = "Scanned: $scanned    Unblocked: $unblocked    Already OK: $alreadyOk"
        $outputBox.SelectionStart = $outputBox.Text.Length
        $outputBox.ScrollToCaret()
        [System.Windows.Forms.Application]::DoEvents()
    }

    $outputBox.AppendText("`r`n")
    $outputBox.AppendText("Completed.`r`n")
    $outputBox.AppendText("`r`n")
    $outputBox.AppendText(("Scanned:    {0,8}" -f $scanned) + "`r`n")
    $outputBox.AppendText(("Unblocked:  {0,8}" -f $unblocked) + "`r`n")
    $outputBox.AppendText(("Already OK: {0,8}" -f $alreadyOk) + "`r`n")
    $outputBox.AppendText("`r`n")

    try {
        $statusLabel.Text = "Refreshing File Explorer..."
        [System.Windows.Forms.Application]::DoEvents()

        [ShellRefresh]::SHChangeNotify(0x08000000, 0x0000, [IntPtr]::Zero, [IntPtr]::Zero)

        $outputBox.AppendText("File Explorer refreshed.`r`n")
        $outputBox.AppendText("`r`n")
        $outputBox.AppendText("Scan completed successfully.`r`n")
        $outputBox.AppendText("`r`n")
        $outputBox.AppendText("Thank you for using Shane's Unblocker!`r`n")
        $outputBox.AppendText("For updates and documentation, visit:`r`n")
        $outputBox.AppendText("shaneaune.com`r`n")       

    }
    catch {
        $outputBox.AppendText("Could not refresh File Explorer.`r`n")
    }

    $statusLabel.Text = "Completed - Scanned: $scanned    Unblocked: $unblocked    Already OK: $alreadyOk"
}

$form = New-Object System.Windows.Forms.Form
$form.Text = $AppName
$form.Size = New-Object System.Drawing.Size(900, 640)
$form.StartPosition = "CenterScreen"

# Set the application icon
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
$titleLabel.Font = New-Object System.Drawing.Font("Segoe UI", 12, [System.Drawing.FontStyle]::Bold)
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
$linkLabel.Size = New-Object System.Drawing.Size(200, 20)
$linkLabel.Add_Click({
    Start-Process $Website
})
$form.Controls.Add($linkLabel)

$closeButton = New-Object System.Windows.Forms.Button
$closeButton.Text = "Close"
$closeButton.Location = New-Object System.Drawing.Point(395, 575)
$closeButton.Size = New-Object System.Drawing.Size(100, 30)
$closeButton.Add_Click({ $form.Close() })
$form.Controls.Add($closeButton)

$form.Add_Shown({
    Start-UnblockScan
})

$form.ShowDialog()