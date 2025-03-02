# Copyright (C) 2015 davidak

# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:

# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

{ pkgs, ... }:

# UwU Style for NixOS

let
  nixowo = pkgs.fetchFromGitHub {
    owner = "TilCreator";
    repo = "NixOwO";
    rev = "d2bc0591d78f95d1659da9d9f5e2f07615075fd7";
    sha256 = "sha256-5H9PRSY77oMABvgNDZ/wBayEBXJTzE9sGeAjkFAqYIQ=";
  };

  nixowo-icons = pkgs.runCommandLocal "nixowo-icons" {  }
  ''
    install -m644 ${nixowo}/NixOwO_plain.svg -D $out/share/icons/hicolor/scalable/apps/nix-snowflake.svg
  '';
  
  meta.priority = 10;

  nixowo-icon = pkgs.runCommandLocal "nixowo-icon"
  { nativeBuildInputs = [ pkgs.imagemagick ]; }
  ''
    mkdir $out
    # convert logo to png
    convert -background none ${nixowo}/NixOwO_plain.svg logo.png
    # resize logo
    convert logo.png -resize 256x256 $out/logo.png
  '';
in
{
  boot.plymouth.logo = "${nixowo-icon}/logo.png";

  environment.systemPackages = [
    nixowo-icons
  ];
}