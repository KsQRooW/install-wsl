param(
    [alias("Dist")]
    [ValidateSet("Ubuntu", "Debian", "kali-linux", "Ubuntu-18.04", "Ubuntu-20.04", "Ubuntu-22.04", "OracleLinux_7_9", "OracleLinux_8_7", "OracleLinux_9_1", "openSUSE-Leap-15.5", "SUSE-Linux-Enterprise-Server-15-SP4", "SUSE-Linux-Enterprise-15-SP5", "openSUSE-Tumbleweed")]
    $Distribution = "Ubuntu",
    [parameter(Mandatory=$true, HelpMessage="Specify the path where you want to install the Linux distribution")]
    [alias("Path")]
    $InstallPath
)

$MAIN_COLOR = "DarkMagenta"
$SCRIPT_INFO_COLOR = "Cyan"
$SUCCESS_COLOR = "DarkGreen"
$SPECIAL_COLOR = "DarkYellow"
$SKIP_COLOR = "DarkGray"
$FAIL_COLOR = "DarkRed"
$ERROR_MSG_COLOR = "Red"

$MAX_STRING_LENGTH = 48


function Resolve-Backup-Path {
    try {
        $ParrentPath = $(Split-Path $InstallPath)
        if (-Not (Test-Path $ParrentPath)) {
            Write-Host "To install to `"$InstallPath`", `"$ParrentPath`" must exist!" -ForegroundColor $ERROR_MSG_COLOR
            Exit 1
        }

        if ($ParrentPath[-1] -eq "\") {
            $BackupPath = "${ParrentPath}backup"
        }
        else {
            $BackupPath = "${ParrentPath}\backup"
        }
    }
    catch {
        Write-Host "Invalid path entered! " -ForegroundColor $ERROR_MSG_COLOR
        Write-Host "Example " -ForegroundColor $ERROR_MSG_COLOR -NoNewline
        Write-Host "$(Split-Path $PSCommandPath)" -ForegroundColor $SPECIAL_COLOR
        Exit 1
    }
    if ($BackupPath -eq "\backup") {
        Write-Host "Invalid path entered! " -ForegroundColor $ERROR_MSG_COLOR
        Write-Host "Example " -ForegroundColor $ERROR_MSG_COLOR -NoNewline
        Write-Host "$(Split-Path $PSCommandPath)" -ForegroundColor $SPECIAL_COLOR
        Exit 1
    }
    if (Test-Path $BackupPath) {
        $BackupPath = "${BackupPath}$(Get-Random -Minimum 666666 -Maximum 999999)"
    }
    return $BackupPath
}

function Get-Dots-Count {
    Param($Val)
    $DotsCount = $MAX_STRING_LENGTH - $Val.Length
    return $DotsCount
}

function Write-Command-Status {
    Param(
        $Command,
        $MainColoredDescription,
        $SpecialColoredDescription = "",
        $Skip = $false
    )

    $DotsCount = $(Get-Dots-Count "$MainColoredDescription $SpecialColoredDescription")
    $Dots = "." * $DotsCount

    Write-Host "==== $MainColoredDescription " -ForegroundColor $MAIN_COLOR -NoNewline
    Write-Host "$SpecialColoredDescription " -ForegroundColor $SPECIAL_COLOR -NoNewline
    Write-Host "$Dots " -ForegroundColor $MAIN_COLOR -NoNewline
    if ($Skip){
        Write-Host "<SKIP> " -ForegroundColor $SKIP_COLOR -NoNewline
        Write-Host "==" -ForegroundColor $MAIN_COLOR
    }
    else {
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
}

$BackupPath = Resolve-Backup-Path

Write-Host "$("=" * 19) Install Linux with WSL 2 $("=" * 19)" -ForegroundColor $MAIN_COLOR
Write-Command-Status -Command "wsl --update" -MainColoredDescription "Updating WSL"
Write-Command-Status -Command "wsl --set-default-version 2" -MainColoredDescription "Activating WSL2"
Write-Command-Status -Command "wsl --install $Distribution -n" -MainColoredDescription "Downloading" -SpecialColoredDescription $Distribution -Skip $($(wsl --list --quiet) -contains $Distribution)
Write-Command-Status -Command "Start-Process powershell.exe -ArgumentList `"-NoExit wsl --install $Distribution`"" -MainColoredDescription "Start installing" -SpecialColoredDescription $Distribution
Write-Host $("=" * 64) -ForegroundColor $MAIN_COLOR

Write-Host "Now the " -ForegroundColor $SCRIPT_INFO_COLOR -NoNewline
Write-Host "$Distribution " -ForegroundColor $SPECIAL_COLOR -NoNewline
Write-Host "installation will open in a new window." -ForegroundColor $SCRIPT_INFO_COLOR
Write-Host "After installation - setup " -ForegroundColor $SCRIPT_INFO_COLOR -NoNewline
Write-Host "USERNAME " -ForegroundColor $SPECIAL_COLOR -NoNewline
Write-Host "and " -ForegroundColor $SCRIPT_INFO_COLOR -NoNewline
Write-Host "PASSWORD" -ForegroundColor $SPECIAL_COLOR
Write-Host "Then press " -ForegroundColor $SCRIPT_INFO_COLOR -NoNewline
Write-Host "<Enter> " -ForegroundColor $SPECIAL_COLOR -NoNewline
Write-Host "to continue..." -ForegroundColor $SCRIPT_INFO_COLOR -NoNewline
$_ = $(Read-Host)
while (-Not $($(wsl --list --quiet) -contains $Distribution)) {
    Write-Host "Please! Take your time and wait for $Distribution to install!" -ForegroundColor $ERROR_MSG_COLOR
    Write-Host "Or make sure $Distribution is present among your distributions " -ForegroundColor $ERROR_MSG_COLOR -NoNewline
    Write-Host "(wsl --list --quiet)" -ForegroundColor $SPECIAL_COLOR -NoNewline
    $_ = $(Read-Host)
}

Write-Host $("=" * 64) -ForegroundColor $MAIN_COLOR
Write-Command-Status -Command "wsl --shutdown" -MainColoredDescription "Shutdown WSL2"
Write-Command-Status -Command "New-Item -Path `"$BackupPath`" -ItemType Directory; wsl --export $Distribution `"$BackupPath\${Distribution}.tar`"" -MainColoredDescription "Backuping to" -SpecialColoredDescription $BackupPath
Write-Command-Status -Command "wsl --unregister $Distribution" -MainColoredDescription "Unregistering old distribution path"
Write-Command-Status -Command "New-Item -Path `"$InstallPath`" -ItemType Directory" -MainColoredDescription "Create directory" -SpecialColoredDescription $InstallPath -Skip $(Test-Path $InstallPath)
Write-Command-Status -Command "wsl --import $Distribution `"$InstallPath`" `"$BackupPath\${Distribution}.tar`"" -MainColoredDescription "Registering new distribution path"
Write-Command-Status -Command "Remove-Item -Path `"$BackupPath`" -Recurse" -MainColoredDescription "Remove" -SpecialColoredDescription $BackupPath

if ($Distribution -eq "Ubuntu") {
    Write-Host $("=" * 64) -ForegroundColor $MAIN_COLOR
    Write-Host "Do you want to set a default user other than root? " -ForegroundColor $SCRIPT_INFO_COLOR -NoNewline
    Write-Host "[Y\n]" -ForegroundColor $SPECIAL_COLOR -NoNewline
    Write-Host ": " -ForegroundColor $SCRIPT_INFO_COLOR -NoNewline
    $input = (Read-Host).ToLower()
    if ($input -eq "y") {
        Write-Host "Enter the " -ForegroundColor $SCRIPT_INFO_COLOR -NoNewline
        Write-Host "USERNAME " -ForegroundColor $SPECIAL_COLOR -NoNewline
        Write-Host "you set for " -ForegroundColor $SCRIPT_INFO_COLOR -NoNewline
        Write-Host $Distribution -ForegroundColor $SPECIAL_COLOR -NoNewline
        Write-Host ": " -ForegroundColor $SCRIPT_INFO_COLOR -NoNewline
        $DefaultUsername = Read-Host
        ubuntu config --default-user $DefaultUsername
    }
    Write-Host $("=" * 64) -ForegroundColor $MAIN_COLOR
    Write-Command-Status -Command "Start-Process ubuntu" -MainColoredDescription "Starting" -SpecialColoredDescription "Ubuntu"
}
else {
    Write-Command-Status -Command "Start-Process wsl -Wait -ArgumentList `"-d $Distribution`"" -MainColoredDescription "Starting" -SpecialColoredDescription $Distribution
}
Write-Host $("=" * 64) -ForegroundColor $MAIN_COLOR
