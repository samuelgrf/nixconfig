{ config, ... }:

{
  nixpkgs.overlays = [
    (self: super: {

      ##########################################################################
      ## Channel aliases
      ##########################################################################

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


      ##########################################################################
      ## Applications
      ##########################################################################

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


      ##########################################################################
      ## Tools
      ##########################################################################

      g810-led = super.callPackage ./g810-led { };

      lux = super.callPackage ./lux { };


      ##########################################################################
      ## Misc
      ##########################################################################

      # The Vulkan Loader tries to load the default driver from $share/vulkan/icd.d/
      # Prevent loading AMDVLK by default by moving the driver to $share/amdvlk/icd.d/
      amdvlk_noDefault = super.pkgs.symlinkJoin {
        name = "amdvlk_noDefault";
        paths = [ "${super.pkgs.amdvlk}/share/vulkan" ];
        postBuild = ''
          mkdir -p $out/share/amdvlk
          mv $out/icd.d $out/share/amdvlk
        '';
      };

      mpv_sponsorblock = super.pkgs.mpv.override {
        scripts = [
          (super.callPackage ./mpv-scripts/sponsorblock.nix { })
        ];
      };

    })
  ];
}
