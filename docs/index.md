## Clone project

=== "https"

    ```
    git clone https://github.com/KsQRooW/Easy-Install-WSL-Linux.git
    ```

=== "ssh"

    ```
    git@github.com:KsQRooW/Easy-Install-WSL-Linux.git
    ```

=== "GitHub CLI"

    ```
    gh repo clone KsQRooW/Easy-Install-WSL-Linux
    ```
??? note
    If for some reason you cannot use git, then you can simply download the [.zip archive](https://github.com/KsQRooW/Easy-Install-WSL-Linux/archive/refs/heads/main.zip) and unzip it.

## Preparing Windows Components

```powershell
~\Easy-Install-WSL-Linux\src\prepare_win_components.ps1  # (1)!
```

1. This PowerShell script will activate [WSL](https://learn.microsoft.com/en-us/windows/wsl/) and [Virtual Machine Platform](https://support.microsoft.com/en-us/windows/enable-virtualization-on-windows-11-pcs-c5578302-6e43-4b4b-a449-8ced115f58e1)

??? example "Example output after running prepare_win_components.ps1"
    
    ![Image title](./examples/prepare_win_components.png){ align=left }

## Installing Linux

```powershell title="Installing Ubuntu in directory E:\Ubuntu"
~\Easy-Install-WSL-Linux\src\install_linux_wsl.ps1 -Path E:\Ubuntu -Dist Ubuntu
```

| Param                   |      Required      |     Default      |                Description |
|-------------------------|:------------------:|:----------------:|---------------------------:|
| `Path`/`InstallPath`    |  :material-check:  | :material-close: |  _Linux installation path_ |
| `Dist`/`Distribution`   |  :material-close:  |      Ubuntu      |        _Distribution name_ |

!!! warning "Valid values for `Dist`/`Distribution`"

    `Ubuntu`, `Ubuntu-18.04`, `Ubuntu-20.04`, `Ubuntu-22.04`, `Debian`, `kali-linux`, `OracleLinux_7_9`, `OracleLinux_8_7`, `OracleLinux_9_1`, `openSUSE-Leap-15.5`, `SUSE-Linux-Enterprise-Server-15-SP4`, `SUSE-Linux-Enterprise-15-SP5`, `openSUSE-Tumbleweed`

### Downloading and Installing

!!! note

    In general, everything that will be described below will only tell you what the script does. If you are a confident person, then you don’t need to read further, just [run the script](#installing-linux).

First of all, the script will download the selected Linux distribution and begin installing it. 

Do not worry! 

You will definitely notice the installation in a separate window, and you will know exactly where you need to enter the _username_ and _password_.

??? example "Example of the 1-st part of the output after running install_linux_wsl.ps1"
    
    ![Image title](./examples/install_linux_wsl_1.png){ align=left }

### Moving

Next, a couple of manipulations will be carried out with your distribution so that it ends up in the directory you need.

??? example "Example of the 2-nd part of the output after running install_linux_wsl.ps1"

    ![Image title](./examples/install_linux_wsl_2.png){ align=left }

### Starting

!!! note "Bonus for Ubuntu"
    
    If you are installing the `Ubuntu` distribution, then as a bonus (1) you will be asked to set a default user _(so as not to constantly log in as root)_.
    { .annotate }    
    
    1. In fact, at the moment the default custom setting only works correctly for the Ubuntu distribution.
    
    Of course, you should enter the user that was created when installing the distribution.


And finally, your distribution will be launched.

My pleasure.

??? example "Example of the final part of the output after running install_linux_wsl.ps1"

    ![Image title](./examples/install_linux_wsl_final.png){ align=left }

??? example "Example of the full output after running install_linux_wsl.ps1"

    ![Image title](./examples/install_linux_wsl.png){ align=left }