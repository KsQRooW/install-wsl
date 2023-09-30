$MAIN_COLOR = "DarkMagenta"
$SCRIPT_INFO_COLOR = "Cyan"
$SPECIAL_COLOR = "DarkYellow"
$SUCCESS_COLOR = "DarkGreen"
$FAIL_COLOR = "DarkRed"
$ERROR_MSG_COLOR = "Red"

$MoveLinuxWSLScriptFile = "install_linux_wsl.ps1"


function Assert-Script-Executed-By-Administrator {
    $СurrentUser = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
    $RunnedAsAdmin = $СurrentUser.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
    if (-Not $RunnedAsAdmin) {
        Write-Host "Run the script as administrator!" -ForegroundColor $ERROR_MSG_COLOR
        Exit 1
    }
}

function Write-Command-Status {
    Param(
        $Command,
        $Description
    )

    Write-Host "$Description " -ForegroundColor $MAIN_COLOR -NoNewline
    try {
        Invoke-Expression $Command | Out-Null
        Write-Host "<OK> " -ForegroundColor $SUCCESS_COLOR -NoNewline
        Write-Host "====" -ForegroundColor $MAIN_COLOR
    }
    catch {
        Write-Host "<FAIL> " -ForegroundColor $FAIL_COLOR -NoNewline
        Write-Host "==" -ForegroundColor $MAIN_COLOR
        Write-Host $_ -ForegroundColor $ERROR_MSG_COLOR
        Exit 1
    }
}

function Search-Move-Linux-WSL-File {
    $FastSearch = Get-ChildItem -Path $PSScriptRoot -Filter $MoveLinuxWSLScriptFile -File
    if ($FastSearch) {
        $MoveLinuxWSLScriptFilePath = "$PSScriptRoot\$FastSearch"
    }
    else {
        $MoveLinuxWSLScriptFilePath = "<your_path>\$FastSearch"
    }
    return $MoveLinuxWSLScriptFilePath
}


Assert-Script-Executed-By-Administrator
$MoveLinuxWSLScriptFilePath = Search-Move-Linux-WSL-File

Write-Host "====== Activating Windows Components ======" -ForegroundColor $MAIN_COLOR
Write-Command-Status -Command "dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart" -Description "==== WSL ........................"
Write-Command-Status -Command "dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart" -Description "==== Virtual Machine Platform ..."
Write-Host "===========================================" -ForegroundColor $MAIN_COLOR

Write-Host "The system needs to reboot." -ForegroundColor $SCRIPT_INFO_COLOR
Write-Host "After reboot be sure to run" -ForegroundColor $SCRIPT_INFO_COLOR
Write-Host $MoveLinuxWSLScriptFilePath -ForegroundColor $SPECIAL_COLOR
Write-Host "Reboot system? " -ForegroundColor $SCRIPT_INFO_COLOR -NoNewLine
Write-Host "[Y/n]" -ForegroundColor $SPECIAL_COLOR -NoNewLine
Write-Host ": " -ForegroundColor $SCRIPT_INFO_COLOR -NoNewLine
$input = (Read-Host).ToLower()
switch ($input) {
    'y' {
        Write-Host "Restarting..." -ForegroundColor $SUCCESS_COLOR
        Start-Sleep -Seconds 2
        Restart-Computer
    }
    'n' {
        Write-Host "Okay, but don't forget to restart later before running " -ForegroundColor $SCRIPT_INFO_COLOR -NoNewline
        Write-Host $MoveLinuxWSLScriptFilePath -ForegroundColor $SPECIAL_COLOR
    }
    Default {
        Write-Host "Invalid Input" -ForegroundColor $FAIL_COLOR
        Write-Host "Don't forget to restart later before running " -ForegroundColor $SCRIPT_INFO_COLOR -NoNewline
        Write-Host $MoveLinuxWSLScriptFilePath -ForegroundColor $SPECIAL_COLOR
    }
}
