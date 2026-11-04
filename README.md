# Simly dots
> My work in progress ansible driven dotfiles on Arch Hyprland

## Current state (v0.1.0)
The project is currently work in progress and may not work even on a correct setup. I am currently adding more feature and testing it.

For the moment these dotfiles are intended to be used on a fresh minimal installation of Archlinux.

Current setup handle:
- Audio setup (Pipewire)
- Login screen (SDDM)
- Terminal (Kitty)
- Shell (Fish)
- WindowManger/DesktopEnvironment (Hyprland)
- Firewall (Firewalld)
- Networking with NetworkManager
- Flatpak setup to install apps
- Install some default apps that I use

## Todo for v1.0.0

### Hardware and drivers
[] Hardware video acceleration (Intel)
[] Firmware updates (fwupd?)
[] Laptop extras
[] Peripherals - controllers

### Security
- [] Fingerprint
- [] Snapshots and rollback
- [] Secure boot
- [] TPM

### Features
- [] pacman configuration (mirrors, multilib)
- [] AUR helper and trust policy (yay)
- [] Swap (zram?)
- [] keyring (seahorse)
    - [] autologin nextcloud
- [] Screen Locking
- [] Clipboard copyq configuration
- [] Wireguard
- [] Portals and screen sharing (xdg-desktop-portal)
- [] Screenshots stack
- [] Fishshell config
- [] Kitty config
- [] Dev tools (javascript, java, python, rust)
- [] Docker
- [] Neovim
- [] Git
- [] SSD care
- [] Time sync
- [] Monitoring
- [] Dynamic system theme (qt, gtk, terminal, other... matugen)

### Quickshell additions
- [] Input methods and keyboard layouts (switching layout)
- [] Fix wallpaper sliding from the top on first launch
- [] Settings
    - [] Managing monitors
    

### Project specific
- [] User agnostic configuration
- [] Update README.md to add
    - [] Details about what's installed/configured
    - [] Screenshots of the dotfiles's visuals
    - [] Using github projects and PR's instead of raw TODOs

## License
This project in under the (MIT License)[LICENSE.md]