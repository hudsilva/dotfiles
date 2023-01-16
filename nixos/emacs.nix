{ config, lib, pkgs, ... }:

# let
#   emacsPackage = (pkgs.emacsPackagesFor pkgs.emacsNativeComp).emacsWithPackages
#     (epkgs: [ epkgs.vterm ]);
# in 
{

  environment.systemPackages = with pkgs; [
    binutils
    gnutls
    zstd
    editorconfig-core-c
    emacs-nox
  ];

  services.emacs = with pkgs; {
    enable = true;
    package = emacs-nox;
  };

}
