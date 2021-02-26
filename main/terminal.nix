{ config, flakes, lib, pkgs, ... }:

{
  # Use X keyboard configuration on console.
  console.useXkbConfig = true;

  # Set Zsh as default shell.
  users.defaultUserShell = pkgs.zsh;

  # Configure Zsh.
  programs.zsh = {
    enable = true;
    ohMyZsh.enable = true;
    ohMyZsh.plugins = [ "git" ];
    autosuggestions.enable = true;
    syntaxHighlighting.enable = true;

    # Add entries to zshrc.
    interactiveShellInit = with config.programs.zsh.shellAliases; ''
      # Setup Powerlevel10K theme.
      source ${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/powerlevel10k.zsh-theme
      source ${./p10k.zsh}

      # Load the nix-index `command-not-found` replacement.
      source ${pkgs.nix-index}/etc/profile.d/command-not-found.sh

      # Disable less history.
      export LESSHISTFILE=/dev/null

      # Define Nix & NixOS functions.
      nrs () { sudo nixos-rebuild -v "$@" switch && exec zsh }
      nrt () { sudo nixos-rebuild -v "$@" test && exec zsh }
      nsh () { NIXPKGS_ALLOW_UNFREE=1 nix shell --impure nixpkgs#"$@" }
      nshm () { NIXPKGS_ALLOW_UNFREE=1 nix shell --impure github:NixOS/nixpkgs#"$@" }
      nshu () { NIXPKGS_ALLOW_UNFREE=1 nix shell --impure nixpkgs-unstable#"$@" }
      nsd () { nix show-derivation "$@" | bat -l nix }
      nus () { ${nu} && sudo nixos-rebuild -v "$@" switch && exec zsh }
      nut () { ${nu} && sudo nixos-rebuild -v "$@" test && exec zsh }
      nw () { readlink "$(where "$@")" }
      run () { NIXPKGS_ALLOW_UNFREE=1 nix run --impure nixpkgs#"$@" }
      runm () { NIXPKGS_ALLOW_UNFREE=1 nix run --impure github:NixOS/nixpkgs#"$@" }
      runu () { NIXPKGS_ALLOW_UNFREE=1 nix run --impure nixpkgs-unstable#"$@" }

      # Define other functions.
      e () { emacsclient -c "$@" > /dev/null & disown }
      et () { emacsclient -t "$@" }
      smart () { sudo smartctl -a "$@" | less }
    '';

    # Add entries to zshenv.
    shellInit = ''
      # Disable newuser setup (runs if no ~/.zsh* files exist).
      zsh-newuser-install() {}
    '';

    # Set shell aliases.
    shellAliases = {

      # Nix & NixOS
      n = "nix";
      nb = "nix build --print-build-logs -v";
      nbd = "nix build --dry-run -v";
      nf = "nix flake";
      nfc = "nix flake check";
      nfu = "nix flake update";
      ng = "nix-collect-garbage";
      ngd = "sudo nix-collect-garbage -d";
      nlo = "nix-locate";
      np = "nix repl ${flakes.nixpkgs}";
      npp = "nix repl";
      npm = "nix repl ${flakes.nixpkgs-master}";
      npu = "nix repl ${flakes.nixpkgs-unstable}";
      nrb = "sudo nixos-rebuild -v boot";
      nrbu = "nixos-rebuild -v build";
      nse = "nix search nixpkgs";
      nsem = "nix search github:NixOS/nixpkgs";
      nseu = "nix search nixpkgs-unstable";
      nsr = "nix-store --gc --print-roots | cut -f 1 -d ' ' | grep /result$";
      nsrr = "rm -v $(nsr)";
      nu = ''
        cd $(dirname $(readlink -m /etc/nixos/flake.nix))
        nix flake update --commit-lock-file\
      '';
      nub = "nu && sudo nixos-rebuild -v boot";
      nubu = "nu && sudo nixos-rebuild -v build";
      nv = "nixos-version";
      nvr = "nixos-version --revision";

      # Other
      clean = "nsrr; ngd && nrb && ztr";
      grl = "git reflog";
      inc = ''
        [ -n "$HISTFILE" ] && {\
          echo "Enabled incognito mode"
          unset HISTFILE
        } || {\
          echo "Disabled incognito mode"
          exec zsh
        }\
      '';
      lvl = "echo $SHLVL";
      msg = "kdialog --msgbox";
      o = "xdg-open";
      qr = "qrencode -t UTF8";
      rb = "shutdown -r";
      rbc = "shutdown -c";
      rbn = "shutdown -r now";
      rld = "exec zsh";
      rldh = ''
        sudo systemctl restart home-manager-\*.service
        sudo systemctl status home-manager-\*.service\
      '';
      rldp = "kquitapp5 plasmashell && kstart5 plasmashell";
      sd = "shutdown";
      sdc = "shutdown -c";
      sdn = "shutdown now";
      t = "tree";
      wtr = "curl wttr.in";
      ztr = "sudo zpool trim rpool && watch zpool status -t rpool";
    };

    # Set Zsh options.
    setOptions = [
      "HIST_FCNTL_LOCK"
      "HIST_IGNORE_DUPS"
      "SHARE_HISTORY"
    ];
  };

  # Add entries to top of zshrc.
  environment.etc.zshrc.text = lib.mkBefore ''
    # Enable Powerlevel10k instant prompt.
    if [[ -r "''${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-''${(%):-%n}.zsh" ]]; then
      source "''${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-''${(%):-%n}.zsh"
    fi
  '';

  # Override Oh My Zsh defaults.
  environment.extraInit = "export LESS='-i -F -R'";

  # Disable the default `command-not-found` script (no flake support).
  programs.command-not-found.enable = false;
}
