{ config, lib, pkgs, ... }:

{
  nixpkgs.overlays = [
    (self: super: {
      # Alias for unstable channel
      unstable = import <nixos-unstable> {
        config = config.nixpkgs.config;
        overlays = config.nixpkgs.overlays;
        localSystem = config.nixpkgs.localSystem;
        crossSystem = config.nixpkgs.crossSystem;
      };

      # Experimental Qt 5.14.2 channel, needed for newer versions of RPCS3
      # can be downloaded as tarball from:
      # https://github.com/petabyteboy/nixpkgs/archive/feature/qt-5-14-2.tar.gz
      qt-5-14-2 = import <qt-5-14-2> {
        config = config.nixpkgs.config;
        overlays = config.nixpkgs.overlays;
        localSystem = config.nixpkgs.localSystem;
        crossSystem = config.nixpkgs.crossSystem;
      };

      ### APPLICATIONS

      emacs-nox = pkgs.emacs.override {
        withX = false;
        withGTK2 = false;
        withGTK3 = false;
      };

      pcsx2_nativeOptimizations = super.pkgs.pkgsi686Linux.pcsx2.override {
        stdenv = super.pkgs.pkgsi686Linux.impureUseNativeOptimizations super.pkgs.pkgsi686Linux.stdenv;
      };

      # Update to newest version, needs Qt version >5.14 to work
      rpcs3 = self.qt-5-14-2.libsForQt5.callPackage ./rpcs3 { };

      rpcs3_nativeOptimizations =
        let
          pkgs = self.qt-5-14-2;
        in
        (self.rpcs3.override {
          mkDerivation = (pkgs.impureUseNativeOptimizations pkgs.stdenv).mkDerivation;
        })
          .overrideAttrs (oldAttrs: {
            # Enable native optimizations in CMake
            cmakeFlags = [
              "-DUSE_SYSTEM_LIBPNG=ON"
              "-DUSE_SYSTEM_FFMPEG=ON"
              "-DUSE_NATIVE_INSTRUCTIONS=ON"
            ];

            # Add QT wrapper, this is needed because we are using stdenv.mkDerivation
            # instead of mkDerivation
            nativeBuildInputs = oldAttrs.nativeBuildInputs ++ [ pkgs.qt5.wrapQtAppsHook ];
      });

      # RPCS3 fork with higher VRAM limits, required by some texture upscaling mods
      rpcs3_extraVram = self.qt-5-14-2.libsForQt5.callPackage ./rpcs3_extraVram { };

      rpcs3_extraVram_nativeOptimizations =
        let
          pkgs = self.qt-5-14-2;
        in
        (self.rpcs3_extraVram.override {
          mkDerivation = (pkgs.impureUseNativeOptimizations pkgs.stdenv).mkDerivation;
        })
          .overrideAttrs (oldAttrs: {
            # Enable native optimizations in CMake
            cmakeFlags = [
              "-DUSE_SYSTEM_LIBPNG=ON"
              "-DUSE_SYSTEM_FFMPEG=ON"
              "-DUSE_NATIVE_INSTRUCTIONS=ON"
            ];

            # Add QT wrapper, this is needed because we are using stdenv.mkDerivation
            # instead of mkDerivation
            nativeBuildInputs = oldAttrs.nativeBuildInputs ++ [ pkgs.qt5.wrapQtAppsHook ];
      });

      ### TOOLS

      g810-led = super.callPackage ./g810-led { };

      gamemode32 = super.callPackage_i686 ./gamemode32 { };
      gamemode = super.callPackage ./gamemode { };

      inih = super.callPackage ./inih { }; # GameMode dependency

      lux = super.callPackage ./lux { };

      w7zip = super.callPackage ./w7zip { };

      ### MISC

      amdvlk = super.callPackage ./amdvlk { };

      linuxPackages = super.linuxPackages.extend (self: super: {
        rtl8821ce = super.callPackage ./rtl8821ce { };
      });

      # Copied from https://github.com/cleverca22/nixos-configs/blob/master/overlays/qemu/default.nix
      qemu-user-arm = if self.stdenv.system == "x86_64-linux"
        then self.pkgsi686Linux.callPackage ./qemu-user { user_arch = "arm"; }
        else self.callPackage ./qemu-user { user_arch = "arm"; };
      qemu-user-x86 = self.callPackage ./qemu-user { user_arch = "x86_64"; };
      qemu-user-arm64 = self.callPackage ./qemu-user { user_arch = "aarch64"; };
      qemu-user-riscv32 = self.callPackage ./qemu-user { user_arch = "riscv32"; };
      qemu-user-riscv64 = self.callPackage ./qemu-user { user_arch = "riscv64"; };
    })
  ];
}
