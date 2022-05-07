{ config, pkgs, lib, options, ... }:

{
  imports = [
    ./factorio.nix
  ];

  config = {
    nixpkgs.config.allowUnfree = true;

    services.openssh.passwordAuthentication = false;
    services.openssh.challengeResponseAuthentication = false;

    security.sudo.wheelNeedsPassword = false;

    environment.systemPackages = with pkgs; [ vim rsync ];

    programs.zsh.enable = true;

    users.extraUsers.lorne = {
      isNormalUser = true;
      uid = 1000;
      extraGroups = [ "wheel" ];
      shell = pkgs.zsh;
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJG2Q4/TvD9uwkY4YLfl+KO7uLnYdyw6J4cDlITzx+hA lorne@illumination"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOIcPDy7c02Sd9AqLmVPjpFxr0j2U3dibAWTxF3CEa41 lorne@tourou.cons.org.nz"
      ];
    };
  };
}
