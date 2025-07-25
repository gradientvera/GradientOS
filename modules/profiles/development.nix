{ config, lib, pkgs, ... }:
let
  cfg = config.gradient;
in 
{

  options = {
    gradient.profiles.development.enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = ''
        Whether to enable the GradientOS development profile.
        Includes a couple IDEs/editors and support for a couple languages I use.
      '';
    };
  };

  config = lib.mkMerge [
    (lib.mkIf cfg.profiles.development.enable {
      environment.systemPackages = with pkgs; [
        stable.jetbrains.rust-rover
        stable.jetbrains.rider
        sqlitebrowser
        cargo-watch
        godot-mono
        smartgithg
        pre-commit
        ansible
        blender
        rustfmt
        poetry
        clippy
        rustup
        rustc
        cargo
        gcc
        (vscode-with-extensions.override {
            vscodeExtensions = with vscode-extensions; [

              # dotnet/csharp
              ms-dotnettools.vscodeintellicode-csharp
              ms-dotnettools.vscode-dotnet-runtime
              ms-dotnettools.csdevkit
              ms-dotnettools.csharp

              # rust
              rust-lang.rust-analyzer
              tamasfe.even-better-toml

              # nushell
              thenuprojectcontributors.vscode-nushell-lang

              # nix
              jnoortheen.nix-ide

              # astro
              astro-build.astro-vscode

              # c/c++
              llvm-vs-code-extensions.vscode-clangd
              ms-vscode.cpptools-extension-pack
              ms-vscode.cpptools

              # github
              github.vscode-github-actions

              # direnv
              mkhl.direnv

              # editorconfig
              editorconfig.editorconfig

              # python
              ms-python.vscode-pylance
              ms-pyright.pyright
              ms-python.debugpy
              ms-python.pylint
              ms-python.python

              # vscode remote & live-share
              ms-vscode-remote.remote-ssh-edit
              ms-vscode-remote.remote-ssh
              ms-vsliveshare.vsliveshare

              # catppuccin
              catppuccin.catppuccin-vsc-icons
              catppuccin.catppuccin-vsc


            ] ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [
              {
                name = "excalidraw-editor";
                publisher = "pomdtr";
                version = "3.7.4";
                sha256 = "848f90a3c2be80b42ecca91a4aaf3d0fcbc8c6562af6d322df50e0162473c741";
              }
              {
                name = "code-runner";
                publisher = "formulahendry";
                version = "0.12.2";
                sha256 = "4c8e4aea7dd07c9c20173e71869759fb2ce2f55b9819c4b374172467af03b144";
              }
              {
                name = "vscode-just-syntax";
                publisher = "nefrob";
                version = "0.8.0";
                sha256 = "cee0df23186250a469551c69f4171e5ba58f06ae4d342b92d528b4ffa91fa85f";
              }
            ];
          })
      ];
    })
  ];

}