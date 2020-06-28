{ config, lib, pkgs, ... }:

{
  ##############################################################################
  ## General
  ##############################################################################

  # Set hostname
  networking.hostName = "HPx";

  # The 32-bit host ID of this machine, formatted as 8 hexadecimal characters.
  # generated via "head -c 8 /etc/machine-id"
  # this is required by ZFS
  networking.hostId = "97e4f3b3";

  # Configure systemd-boot
  boot.loader.systemd-boot.enable = true;
  boot.loader.timeout = 1;

  # Enable weekly TRIM on ZFS
  services.zfs.trim.enable = true;


  ##############################################################################
  ## Xorg & Services
  ##############################################################################

  # Enable the X11 windowing system.
  services.xserver.enable = true;
  services.xserver.autorun = true;

  # Configure TLP
  services.tlp.enable = true;
  services.tlp.extraConfig = "RUNTIME_PM_BLACKLIST='02:00.0'"; # Blacklist wifi card

  # Undervolting
  services.undervolt = {
    enable = true;
    coreOffset = "-125";
    gpuOffset = "-105";
    uncoreOffset = "-125";
    analogioOffset = "-105";
  };


  ##############################################################################
  ## Kernel & Modules
  ##############################################################################

  # Install wifi kernel module
  boot.extraModulePackages = [ pkgs.linuxPackages.rtl8821ce ];

  # Blacklist sensor kernel modules
  boot.blacklistedKernelModules = [ "intel_ishtp_hid" "intel_ish_ipc" ];


  ##############################################################################
  ## Input devices
  ##############################################################################

  # Enable touchpad support.
  services.xserver.libinput.enable = true;

  # Enable touch scrolling in Firefox
  environment.variables = {
    "MOZ_USE_XINPUT2" = "1";
  };


  ##############################################################################
  ## Audio
  ##############################################################################

  # Create a systemd service to fix audio crackling on startup/resume
  # https://bugs.launchpad.net/ubuntu/+source/alsa-driver/+bug/1648183/comments/31
  systemd.services.fixaudio = {
    description = "Audio crackling fix for Realtek ALC295";
    script = ''
      ${pkgs.alsaTools}/bin/hda-verb /dev/snd/hwC[[:print:]]*D0 0x20 SET_COEF_INDEX 0x67
      ${pkgs.alsaTools}/bin/hda-verb /dev/snd/hwC[[:print:]]*D0 0x20 SET_PROC_COEF 0x3000
    '';
    wantedBy = [ "multi-user.target" "post-resume.target" ];
    after = [ "post-resume.target" ];
  };


  ##############################################################################
  ## GPU & Display
  ##############################################################################

  # Only enable modesetting video driver, if this isn't set other unused drivers
  # are also installed.
  services.xserver.videoDrivers = [ "modesetting" ];

  # Add custom resolutions (for playing games at lower resolutions)
  services.xserver.xrandrHeads = [
    {
      output = "eDP-1";
      monitorConfig = ''
        Modeline "1600x900"  118.25  1600 1696 1856 2112  900 903 908 934 -hsync +vsync
        Modeline "1366x768"   85.25  1366 1440 1576 1784  768 771 781 798 -hsync +vsync
        Modeline "1280x720"   74.50  1280 1344 1472 1664  720 723 728 748 -hsync +vsync
      '';
    }
    {
      output = "HDMI-1";
      monitorConfig = ''
        Modeline "1600x900"  118.25  1600 1696 1856 2112  900 903 908 934 -hsync +vsync
        Modeline "1366x768"   85.25  1366 1440 1576 1784  768 771 781 798 -hsync +vsync
      '';
    }
  ];


  ##############################################################################
  ## Other hardware
  ##############################################################################

  # Enable Bluetooth support
  hardware.bluetooth.enable = true;

  # Install libraries for VA-API
  hardware.opengl.extraPackages = [ pkgs.vaapiIntel ];
  hardware.opengl.extraPackages32 = [ pkgs.pkgsi686Linux.vaapiIntel ];

  # Enable CPU microcode updates
  hardware.cpu.intel.updateMicrocode = true;
}
