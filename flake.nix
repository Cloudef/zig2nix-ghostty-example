{
  description = "ghostty flake";

  inputs = {
    zig2nix.url = "github:Cloudef/zig2nix";
  };

  outputs = { zig2nix, ... }: let
    flake-utils = zig2nix.inputs.flake-utils;
  in (flake-utils.lib.eachDefaultSystem (system: let
      # Zig flake helper
      # Check the flake.nix in zig2nix project for more options:
      # <https://github.com/Cloudef/zig2nix/blob/master/flake.nix>
      env = zig2nix.outputs.zig-env.${system} { zig = zig2nix.outputs.packages.${system}.zig."0.13.0".bin; };
      pkgs = env.pkgs;
      system-triple = env.lib.zigTripleFromString system;
    in with builtins; with env.lib; with env.pkgs.lib; rec {
      # nix build .#target.{zig-target}
      # e.g. nix build .#target.x86_64-linux-gnu
      packages.target = genAttrs allTargetTriples (target: env.packageForTarget target {
        src = pkgs.fetchFromGitHub {
          owner = "ghostty-org";
          repo = "ghostty";
          rev = "a2445359c40ba66f36157359c0ae92509b7f005d";
          hash = "sha256-JGvxWgyrZqo86/8LMJbiu/MlB0I+rEzlP+Kcp1QMpbY=";
        };

        nativeBuildInputs = with env.pkgs; [
          git
          ncurses
          pandoc
          wrapGAppsHook4

          wayland-scanner
          wayland-protocols
        ];

        buildInputs = with env.pkgsForTarget target; [
          libGL
          bzip2
          expat
          fontconfig
          freetype
          harfbuzz
          libpng
          oniguruma
          zlib

          gtk4
          glib
          gsettings-desktop-schemas

          xorg.libX11
          xorg.libXcursor
          xorg.libXi
          xorg.libXrandr

          wayland
        ];

        zigBuildZonLock = ./build.zig.zon2json-lock;

        zigBuildFlags = [ "-Doptimize=ReleaseFast" "-Dgtk-x11=true" "-Dgtk-wayland=true" "-Dgtk-adwaita=false" ];
      });

      # nix build .
      packages.default = packages.target.${system-triple};
    }));
}
