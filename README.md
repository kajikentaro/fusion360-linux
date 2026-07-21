# Fusion 360 on Linux via Proton

Small helper scripts for running Autodesk Fusion 360 on Linux with GE-Proton.

This is not an official Autodesk setup. It is a pragmatic wrapper around a Proton prefix that already contains Fusion 360.

## Installation

The shortest working path is to keep the same directory layout used by the scripts.

### 1. Put this repo in place

```bash
cd ~
git clone https://github.com/kajikentaro/fusion360-linux
cd ~/fusion360-linux
```

The Makefile expects this repository to be run from `~/fusion360-linux`.

### 2. Install GE-Proton

Download `GE-Proton10-32.tar.gz` from the Proton-GE releases page, then extract it into Steam compatibility tools:

```bash
mkdir -p ~/.local/share/Steam/compatibilitytools.d
tar -xf ~/Downloads/fusion360-linux-install/GE-Proton10-32.tar.gz \
  -C ~/.local/share/Steam/compatibilitytools.d
```

After extraction, this file should exist:

```text
~/.local/share/Steam/compatibilitytools.d/GE-Proton10-32/proton
```

### 3. Download the Fusion installer

Download FusionClientDownloader.exe from official site and place it under ~/Download directory.

```text
ls ~/Download/FusionClientDownloader.exe
```

### 4. Install Fusion 360 into the Proton prefix

```bash
mkdir -p ~/.fusion360-proton2
export STEAM_COMPAT_DATA_PATH="$HOME/.fusion360-proton2"
export STEAM_COMPAT_CLIENT_INSTALL_PATH="$HOME/.local/share/Steam"

"$HOME/.local/share/Steam/compatibilitytools.d/GE-Proton10-32/proton" run ~/Download/FusionClientDownloader.exe
```

When the installer finishes, `Fusion360.exe` should appear under:

```text
find ~/.fusion360-proton2/pfx/drive_c/users/steamuser/AppData/Local/Autodesk/webdeploy/production/ -type f -name Fusion360.exe 
```

### 4-B. Run post-install.sh

In order to make a connection with Chrome, we need to run below.

```
cd installer
bash post-install.sh
```

### 4-C. Login with Fusion 360

Run background service to catch login request from Fusion 360

```
./background.sh
```

Run Fusion 360
```
make run
```

Click "sign in" and Chrome will open.
After logging-in, Chrome open Fusion 360 and it's authorized.

### 5. Run Fusion 360 from 2nd time

Run Fusion 360

```bash
make run
```

Check whether it is running:

```bash
make ps
```

Stop it:

```bash
make kill
```
