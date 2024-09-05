{  # https://nixcademy.com/2024/01/15/nix-on-macos/
  description = "Example Darwin system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs@{ self, nix-darwin, nixpkgs }:
  let
    configuration = { pkgs, ... }: {
      nixpkgs.config.allowUnfree = true;  # 1password

      # List packages installed in system profile. To search by name, run:
      # $ nix-env -qaP | grep wget
      environment.systemPackages =
        [ pkgs.nushell
          pkgs.starship
          pkgs.carapace
          pkgs.rustup
          pkgs.fnm
          pkgs.pandoc
          pkgs.delta
          pkgs.jaq
          pkgs.gitAndTools.gh
          pkgs.git-lfs
          pkgs.cmake
          # ['gfortran'], ['flang'], ['nvfortran'], ['pgfortran'], ['ifort'], ['ifx'], ['g95']]
          pkgs.gfortran
          pkgs.just
          #pkgs._1password
          #pkgs._1password-gui
          # package/tool managers
          pkgs.pipx
          pkgs.micromamba
          # system libs
          pkgs.pkg-config
          pkgs.openssl.dev
          pkgs.zlib.dev
          pkgs.openblas.dev
        ];

      #launchd.user.envVariables.PATH = config.environment.systemPath;
      launchd.user.envVariables.PKG_CONFIG_PATH = nixpkgs.lib.strings.concatMapStringsSep ":" (pkg: pkg.dev + /lib/pkgconfig) [pkgs.openssl pkgs.zlib pkgs.openblas];
      #"${pkgs.openssl.dev}/lib/pkgconfig:${pkgs.zlib.dev}/lib/pkgconfig";

      # Auto upgrade nix package and the daemon service.
      services.nix-daemon.enable = true;
      #nix.package = pkgs.nix;

      # Necessary for using flakes on this system.
      nix.settings.experimental-features = "nix-command flakes";

      # Create /etc/zshrc that loads the nix-darwin environment.
      programs.zsh.enable = true;  # default shell on catalina
      # programs.nushell.enable = true;

      # Set Git commit hash for darwin-version.
      system.configurationRevision = self.rev or self.dirtyRev or null;

      security.pam.enableSudoTouchIdAuth = true;

      # Used for backwards compatibility, please read the changelog before changing.
      # $ darwin-rebuild changelog
      system.stateVersion = 4;

      # https://github.com/MatthiasBenaets/nixos-config/blob/master/darwin/macbook.nix
      system.defaults = {
        #dock.autohide = true;
        #dock.mru-spaces = false;
        finder.AppleShowAllExtensions = true;
        finder.FXPreferredViewStyle = "clmv";
      };

      # The platform the configuration will be used on.
      nixpkgs.hostPlatform = "aarch64-darwin";
    };
  in
  {
    # Build darwin flake using:
    # $ darwin-rebuild switch --flake .
    # ???
    # $ darwin-rebuild build
    # (if hostname doesn’t match: $ darwin-rebuild build --flake .#MBXC7VYCV7C6)
    darwinConfigurations."MBXC7VYCV7C6" = nix-darwin.lib.darwinSystem {
      modules = [ configuration ];
    };

    # Expose the package set, including overlays, for convenience.
    darwinPackages = self.darwinConfigurations."MBXC7VYCV7C6".pkgs;
  };
}
