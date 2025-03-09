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
      env = zig2nix.outputs.zig-env.${system} { zig = zig2nix.outputs.packages.${system}.zig-0_13_0; };
      pkgs = env.pkgs;
    in {
      packages.default = env.package rec {
        src = pkgs.fetchFromGitHub {
          owner = "ghostty-org";
          repo = "ghostty";
          rev = "d3fd2b02e71f3eaecd310b246ee64a26a59b78e3";
          hash = "sha256-H+rS9UDb1Qd0bTUxppNgiIHLzr4sR/LnDox4VhR5Q1w=";
        };

        nativeBuildInputs = with env.pkgs; [
          git
          ncurses
          pandoc
          pkg-config
          gobject-introspection
          wrapGAppsHook4
          blueprint-compiler
          libxml2
          gettext

          wayland-scanner
          wayland-protocols
        ];

        buildInputs = with env.pkgs; [
          libGL
          bzip2
          expat
          fontconfig
          freetype
          harfbuzz
          libpng
          oniguruma
          zlib

          libadwaita
          gtk4
          glib
          gsettings-desktop-schemas

          xorg.libX11
          xorg.libXcursor
          xorg.libXi
          xorg.libXrandr

          gtk4-layer-shell
          wayland
        ];

        zigWrapperLibs = buildInputs;

        zigBuildZonLock = ./build.zig.zon2json-lock;

        zigBuildFlags = [ "-Doptimize=ReleaseFast" "-Dgtk-x11=true" "-Dgtk-wayland=false" ];
      };
    }));
}
