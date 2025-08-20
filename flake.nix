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
      env = zig2nix.outputs.zig-env.${system} { zig = zig2nix.outputs.packages.${system}.zig-0_14_1; };
      pkgs = env.pkgs;
    in {
      packages.default = env.package rec {
        src = pkgs.fetchFromGitHub {
          owner = "ghostty-org";
          repo = "ghostty";
          rev = "b52879b467a1e335b83593ebef1c92abb4fe1b63";
          hash = "sha256-RWGoaDrsVCGf/y31oiFun1lsw8eibGwAXNBErXcffbk=";
        };

        nativeBuildInputs = with env.pkgs; [
          git
          ncurses
          pandoc
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
          libxml2
          oniguruma
          simdutf
          zlib

          glslang
          spirv-cross

          libxkbcommon

          libadwaita
          gtk4
          glib
          gobject-introspection
          gsettings-desktop-schemas

          gst_all_1.gst-plugins-base
          gst_all_1.gst-plugins-good
          gst_all_1.gstreamer

          xorg.libX11
          xorg.libXcursor
          xorg.libXi
          xorg.libXrandr

          gtk4-layer-shell
          wayland
        ];

        zigWrapperLibs = buildInputs;

        zigBuildZonLock = ./build.zig.zon2json-lock;

        zigBuildFlags = [ "-Doptimize=ReleaseFast" "-Dgtk-x11=true" "-Dgtk-wayland=true" ];
      };
    }));
}
