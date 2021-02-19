{ config, lib, pkgs, unstable, ... }:

{
  # System-wide packages to install.
  environment.systemPackages = with pkgs;
  let
    common = [
      bat
      dos2unix
      exiftool
      fd
      file
      git
      htop
      killall
      lm_sensors
      lolcat
      lshw
      unstable.manix # TODO Remove "unstable." on 21.05.
      ncdu
      neofetch
      nix-index
      nix-linter
      nixfmt
      nixpkgs-review
      p7zip
      patchelf
      pciutils
      python3
      qrencode
      smartmontools
      strace
      sysstat
      trash-cli
      tree
      usbutils
      wget
      whois
      youtube-dl
    ];
    X = [
      anki
      appimage-run
      ark
      caffeine-ng
      unstable.ghidra-bin
      gimp
      gwenview
      imagemagick
      kate
      kdialog
      keepassxc
      kwin-dynamic-workspaces
      libreoffice
      libstrangle
      lutris
      lxqt.pavucontrol-qt
      mpv
      multimc
      nixos-artwork.wallpapers.nineish-dark-gray
      okular
      unstable.pcsx2
      protontricks
      steam
      steam-run
      torbrowser
      ungoogled-chromium
      wineWowPackages.staging # Comes with both x64 and x86 Wine.
      winetricks
      xdotool
    ];
    noX = [ ];
  in common ++ (if config.services.xserver.enable then X else noX);

  # System-wide fonts to install.
  fonts.fonts = with pkgs; [
    # TODO Remove "unstable." on 21.05.
    unstable.meslo-lgs-nf
    noto-fonts-cjk
  ];

  # Select allowed unfree packages.
  nixpkgs.config.allowUnfreePredicate = pkg: lib.elem (lib.getName pkg) [
    "chrome-widevine-cdm"
    "chromium-unwrapped"
    "mfcl2700dnlpr"
    "steam"
    "steam-original"
    "steam-runtime"
    "ungoogled-chromium"
  ];

  # Don't install optional default packages.
  environment.defaultPackages = [ ];

  # Install ADB and fastboot.
  programs.adb.enable = true;
}
