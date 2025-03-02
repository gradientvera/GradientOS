{ pkgs, ... }:
{

  programs.nushell = {
    enable = true;
    package = pkgs.nushell;
    extraConfig = ''
      $env.config = {
        show_banner: false
      }
      $env.PATH = (
        $env.PATH
        | split row (char esep)
        | append ($env.HOME | path join bin)
        | append ($env.HOME | path join .cargo bin)
        | uniq # filter so the paths are unique
      )
    '';
  };

  programs.carapace.enableNushellIntegration = true;
  programs.direnv.enableNushellIntegration = true;

}